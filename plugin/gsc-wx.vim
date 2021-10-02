let s:curl = 'curl https://igsc.wx.haihui.site/songci/query/SEARCH_PLACEHOLDER/main/0 -H "User-Agent:vim-plugin"'

if !exists('g:gsc_wx_show_audio')
    let g:gsc_wx_show_audio = 1
endif

if !exists('g:gsc_wx_translation')
    let g:gsc_wx_show_translation = 1
endif

if !exists('g:gsc_wx_show_intro')
    let g:gsc_wx_show_intro = 1
endif

if !exists('g:gsc_wx_show_annotation')
    let g:gsc_wx_show_annotation = 0
endif

if !exists('g:gsc_wx_show_appreciation')
    let g:gsc_wx_show_appreciation = 0
endif

if !exists('g:gsc_wx_show_master_comment')
    let g:gsc_wx_show_master_comment = 0
endif

if !exists('g:gsc_wx_show_item_serial')
    let g:gsc_wx_show_item_serial = 1
endif

if !exists('g:gsc_wx_cache')
    let g:gsc_wx_cache = 1
endif

if !exists('g:gsc_wx_cache_path')
    let g:gsc_wx_cache_path = expand('<sfile>:p:h').'/cache'
endif

if g:gsc_wx_cache
    if !isdirectory(g:gsc_wx_cache_path)
        call mkdir(g:gsc_wx_cache_path)
    endif
endif

function! GscWxAppend(query)
    try
        let l:query = substitute(a:query, '\s', '', 'g')
        let l:search = 1
        let l:buf = ''
        echo '正在搜索🔍...'
        let l:start_time = reltime()
        if g:gsc_wx_cache
            let l:cache_path = g:gsc_wx_cache_path.'/'.l:query.'.wx.gz.cache'
            if filereadable(l:cache_path)
                try
                    let l:buf = system('cat '.l:cache_path.' | gzip -d')
                    let l:search = 0
                catch
                    let l:search = 1
                    let l:buf = ''
                endtry
            endif
            " 尝试搜索.cache
            let l:cache_path = g:gsc_wx_cache_path.'/'.l:query.'.wx.cache'
            if l:search && filereadable(l:cache_path)
                try
                    let l:buf = readfile(l:cache_path)[0]
                    let l:search = 0
                catch
                    let l:search = 1
                    let l:buf = ''
                endtry
            endif
        endif
        if l:search
            let l:curl_ = substitute(s:curl, 'SEARCH_PLACEHOLDER', l:query, '')
            let l:result = system(l:curl_.' | jq')
            let l:result = substitute(l:result, '^.*code', '', 'g')
            let l:result = '{"code'.l:result
            let l:json_res = json_decode(l:result)
            let l:num_serial = 0
            for item in l:json_res['data']['data']
                let l:num_serial = l:num_serial + 1
                let l:title = substitute(item['work_title'], '\r', '', 'g')
                if g:gsc_wx_show_item_serial
                    let l:title = l:num_serial.'.'.l:title
                endif
                let l:author = item['work_author']
                let l:dynasty = '['.item['work_dynasty'].']'
                let l:audio_id = item['audio_id']
                let l:content = substitute(item['content'], '\r', '', 'g')
                let l:translation = item['translation']
                let l:intro = item['intro']
                let l:annotation = item['annotation']
                let l:appreciation = item['appreciation']
                let l:master_comment = item['master_comment']
                let l:ll = [l:title, l:dynasty.l:author, l:content."\n"]
                if g:gsc_wx_show_audio && l:audio_id > 0
                    let l:ll = add(l:ll, 'https://songci.nos-eastchina1.126.net/audio/'.l:audio_id.'.m4a'."\n")
                endif
                if g:gsc_wx_show_intro && len(l:intro) > 0
                    let l:ll = add(l:ll, "评析：\n".l:intro."\n")
                endif
                if g:gsc_wx_show_annotation && len(l:annotation) > 0
                    let l:ll = add(l:ll, "注释：\n".l:annotation."\n")
                endif
                if g:gsc_wx_show_translation && len(l:translation) > 0
                    let l:ll = add(l:ll, "译文：\n".l:translation."\n")
                endif
                if g:gsc_wx_show_appreciation && len(l:appreciation) > 0
                    let l:ll = add(l:ll, "赏析：\n".l:appreciation."\n")
                endif
                if g:gsc_wx_show_master_comment && len(l:master_comment) > 0
                    let l:ll = add(l:ll, "辑评：\n".l:master_comment."\n")
                endif
                let l:buf = l:buf.join(l:ll, "\n")."\n"
            endfor
            let l:buf = l:buf.'GgGg'.len(l:json_res['data']['data'])
            if g:gsc_wx_cache
                try
                    call system("echo '".l:buf."' | gzip --best > ".g:gsc_wx_cache_path.'/'.l:query.'.wx.gz.cache')
                catch
                    call delete(g:gsc_wx_cache_path.'/'.l:query.'.wx.gz.cache')
                    try
                        call writefile([l:buf], g:gsc_wx_cache_path.'/'.l:query.'.wx.cache')
                    catch
                        call delete(g:gsc_wx_cache_path.'/'.l:query.'.wx.cache')
                    endtry
                endtry
            endif
        endif
        "execute 'normal! Go'.l:buf
        "截取num
        let l:total_num = l:buf[match(l:buf, 'GgGg'):][4:]
        let @a = l:buf
        normal! G
        execute 'put a'
        normal! k2dd
        call ClearEchoOuput()
        echo '共'.(l:total_num + 0).'条相关结果，用时'.reltimestr(reltime(l:start_time)).'s'
        normal gg
    catch
        call ClearEchoOuput()
        echo '搜索出错, 请稍后再试:('
    endtry
endfunction

function! Clear()
    execute 'normal gg100000dd'
endfunction

function! ClearEchoOuput()
    execute 'redraw!'
endfunction

function! GscWx(query)
    call Clear()
    call GscWxAppend(a:query)
    normal! dd
endfunction


function! GscWxClearCache(key_word)
    if len(a:key_word) > 0
        echo system('rm -rf '.g:gsc_wx_cache_path.'/'.substitute(a:key_word, '\s', '', 'g').'.wx*')
    else
        echo system('rm -rf '.g:gsc_wx_cache_path.'/*.wx*')
    endif
endfunction

command! -nargs=+  GscWxAppend call GscWxAppend(<q-args>)
command! -nargs=+  GscWx call GscWx(<q-args>)
command! -nargs=?  GscWxClearCache call GscWxClearCache(<q-args>)