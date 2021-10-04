let s:curl = 'curl -s "https://avoscloud.com/1.1/call/searchWorks2"
            \ -H "authority: avoscloud.com"
            \ -H "x-lc-ua: LeanCloud-JS-SDK/3.15.0 (Browser)"
            \ -H "dnt: 1"
            \ -H "sec-ch-ua-mobile: ?0"
            \ -H "user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36"
            \ -H "content-type: application/json;charset=UTF-8"
            \ -H "x-lc-sign: 8e33bfbb3625e1b6a261487dc7f38dca,1633015485114"
            \ -H "x-lc-session: saxj96gey4hqsy7wxp4zrnywp"
            \ -H "x-lc-id: 9pq709je4y36ubi10xphdpovula77enqrz27idozgry7x644"
            \ -H "x-lc-prod: 1"
            \ -H "accept: */*"
            \ -H "origin: http://lib.xcz.im"
            \ -H "sec-fetch-site: cross-site"
            \ -H "sec-fetch-mode: cors"
            \ -H "sec-fetch-dest: empty"
            \ -H "referer: http://lib.xcz.im/"
            \ -H "accept-language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7"
            \ --data "{\"q\":\"SEARCH_PLACEHOLDER\"}"'

if !exists('g:gsc_show_url')
    let g:gsc_show_url = 0
endif

if !exists('g:gsc_show_item_serial')
    let g:gsc_show_item_serial = 1
endif

if !exists('g:gsc_cache')
    let g:gsc_cache = 1
endif

if !exists('g:gsc_highlight')
    let g:gsc_highlight = 1
endif

if !exists('g:gsc_cache_path')
    let g:gsc_cache_path = expand('<sfile>:p:h').'/cache'
endif

if g:gsc_cache
    if !isdirectory(g:gsc_cache_path)
        call mkdir(g:gsc_cache_path)
    endif
endif


function! GscAppend(query)
    try
        let l:search = 1
        let l:start_time = reltime()
        let l:query = substitute(a:query, '\s', '', 'g')
        echo '正在搜索"'.l:query.'" 🔍...'
        let l:buf = ''
        let l:query_md5 = gsc#md5(l:query)
        let l:cache_path = g:gsc_cache_path.'/'.l:query_md5.'.xcz.'.g:gsc_cache_comp_algo[0:1].'.cache'
        if g:gsc_cache
            if filereadable(l:cache_path)
                try
                    let l:buf = system('cat "' .l:cache_path.'" | '.g:gsc_cache_comp_algo.' -d')
                    let l:search = 0
                catch
                    let l:search = 1
                    let l:buf = ''
                endtry
            endif
        endif
        if l:search
            let l:curl_ = substitute(s:curl, 'SEARCH_PLACEHOLDER', l:query, '')
            let l:result = system(l:curl_)
            let l:result = substitute(l:result, '^.*result', '', 'g')
            let l:result = '{"result'.l:result
            let l:json_res = gsc#json_decode(l:result)
            let l:num_serial = 0
            for item in l:json_res['result']
                let l:num_serial = l:num_serial + 1
                let l:title = substitute(item['work']['title'], '\r', '', 'g')
                if g:gsc_show_item_serial
                    let l:title = l:num_serial.'.'.l:title
                endif
                let l:author = item['work']['authorName']
                let l:dynasty = '['.item['work']['dynasty'].'] '
                let l:object_id = item['work']['objectId']
                let l:url = '🔗 http://lib.xcz.im/work/'.l:object_id
                let l:content = substitute(item['work']['content'], '\r', '', 'g')
                let l:author = l:dynasty.l:author
                if g:gsc_highlight
                    let l:title = nr2char(2).l:title.nr2char(2)
                    let l:content = nr2char(1).join(split(l:content, "\n"), "\n".nr2char(1))
                endif
                if g:gsc_show_url
                    let l:buf = l:buf.(join([l:title, l:author, l:content."\n", l:url."\n"], "\n"))."\n"
                else
                    let l:buf = l:buf.(join([l:title, l:dynasty, l:content."\n"], "\n"))."\n"
                endif
            endfor
            let l:buf = l:buf.'GgGg'.len(l:json_res['result'])
            if g:gsc_cache
                try
                    let l:buf = substitute(l:buf, "'", "‘", 'g')
                    call system("echo '".l:buf."' | ".g:gsc_cache_comp_algo." --best > ".l:cache_path)
                catch
                    call delete(l:cache_path)
                endtry
            endif
        endif
        let l:total_num = l:buf[match(l:buf, 'GgGg'):][4:]
        call gsc#write_to_buffer(l:buf)
        call gsc#clear_echo_output()
        normal! dd
        echo '搜索"'.l:query.'"，共'.(l:total_num + 0).'条相关结果，用时'.reltimestr(reltime(l:start_time)).'s'
        normal gg
        setlocal filetype=gsc
    catch
        call gsc#clear_echo_output()
        echo '搜索"'.l:query.'"出错, 请稍后再试:('
    endtry
endfunction

function! Gsc(query)
    call gsc#clear()
    call GscAppend(a:query)
    normal! dd
endfunction

function! GscClearCache(key_word)
    if len(a:key_word) > 0
        let l:res = system('rm -rf '.g:gsc_cache_path.'/'.gsc#md5(substitute(a:key_word, '\s', '', 'g')).'.xcz*')
    else
        let l:res = system('rm -rf '.g:gsc_cache_path.'/*.xcz*')
    endif
    if len(l:res) > 0
        echo '清除失败, '.l:res
    else
        echo '清除成功'
    endif
endfunction

function! GscSearchSelect()
    let l:selected = gsc#get_visual_selection()
    if len(l:selected) > 0
        call Gsc(l:selected)
    endif
endfunction

au Filetype gsc set isprint=@,161-255,1-7
au BufWinEnter,Filetype gsc match  Conceal /[\u0001\u0002\u0003\u0004\u0005\u0006\u0007]/
au BufNewFile,BufRead *.gsc set filetype=gsc
command! -nargs=+  GscAppend call GscAppend(<q-args>)
command! -nargs=+ Gsc call Gsc(<q-args>)
command! -nargs=?  GscClearCache call GscClearCache(<q-args>)
