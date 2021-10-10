let s:curl = 'curl -s https://igsc.wx.haihui.site/songci/query/SEARCH_PLACEHOLDER/main/0 -H "User-Agent:vim-plugin"'
let s:rand_curl = 'curl -s https://igsc.wx.haihui.site/songci/index/all/vim -H "User-Agent:vim-plugin"'

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

if !exists('g:gsc_cache_comp_algo')
    let g:gsc_cache_comp_algo = 'gzip'
endif

if g:gsc_cache_comp_algo != 'gzip' && g:gsc_cache_comp_algo != 'bzip2'
    echo 'g:gsc_cache_comp_algo must be `gzip` or `bzip2`'
endif

if !executable(g:gsc_cache_comp_algo)
    echo g:gsc_cache_comp_algo.' is not in your path.'
endif

if g:gsc_wx_cache
    if !isdirectory(g:gsc_wx_cache_path)
        call mkdir(g:gsc_wx_cache_path)
    endif
endif

function! GscWxAppend(query)
    let l:query = substitute(a:query, '\s', '', 'g')
    let l:search = 1
    let l:buf = ''
    echo '正在搜索"'.l:query.'" 🔍...'
    let l:start_time = reltime()
    let l:query_md5 = gsc#md5(l:query)
    let l:comp_cache_path = g:gsc_wx_cache_path.'/'.l:query_md5.'.wx.'.g:gsc_cache_comp_algo[:1].'.cache'
    let l:cache_path = g:gsc_wx_cache_path.'/'.l:query_md5.'.wx.cache'
    if g:gsc_wx_cache
        let l:tmp_cache_path = g:gsc_wx_cache_path.'/'.'tmp.tmp'
        if filereadable(l:comp_cache_path)
            try
                call system(g:gsc_cache_comp_algo.' -d -c '.l:comp_cache_path.' > '.l:tmp_cache_path)
                let l:buf = join(readfile(l:tmp_cache_path), "\n")
                call delete(l:tmp_cache_path)
                let l:search = 0
            catch
                let l:search = 1
                let l:buf = ''
            endtry
        endif
        " 尝试搜索.cache
        if l:search && filereadable(l:cache_path)
            try
                let l:buf = join(readfile(l:cache_path), "\n")
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
        let l:json_res = gsc#json_decode(l:result)
        let l:num_serial = 0
        for item in l:json_res['data']['data']
            let l:num_serial = l:num_serial + 1
            let l:buf = l:buf.join(gsc#process_item(item, l:num_serial, '@'), "\n")."\n"
        endfor
        let l:buf = l:buf.'GgGg'.len(l:json_res['data']['data'])
        if g:gsc_wx_cache
            try
                call system("echo -n '".l:buf."' | ".g:gsc_cache_comp_algo.'  > '.l:comp_cache_path)
            catch
                call delete(l:comp_cache_path)
                try
                    call writefile([l:buf], l:cache_path)
                    call system(g:gsc_cache_comp_algo.'  -c '.l:cache_path.' > '.l:comp_cache_path)
                    call delete(l:cache_path)
                catch
                    call delete(l:cache_path)
                    call delete(l:comp_cache_path)
                endtry
            endtry
        endif
    endif
    "execute 'normal! Go'.l:buf
    "截取num
    let l:total_num = l:buf[match(l:buf, 'GgGg'):][4:]
    call gsc#write_to_buffer(l:buf)
    normal! k2dd
    call gsc#clear_echo_output()
    echo '搜索"'.l:query.'"，共'.(l:total_num + 0).'条相关结果，用时'.reltimestr(reltime(l:start_time)).'s'
    normal gg
    setlocal filetype=gsc
endfunction

function! GscWxRand(num)
    if !a:num
        let l:num = 1
    else
        let l:num = a:num + 0
    endif
    if l:num > 30 || l:num == 0
        echo 'arg '.l:num.' is too large, valid value is [1,30].'
        return
    endif
    let l:buf = ''
    echo '正在随机获取'.l:num.'条记录 🔥...'
    let l:start_time = reltime()
    let l:result = system(s:rand_curl)
    let l:json_res = gsc#json_decode(l:result)
    let l:num_serial = 0
    for item in l:json_res['data']['data']
        let l:num_serial = l:num_serial + 1
        if l:num_serial > l:num
            break
        endif
        if a:num == 1
            let l:num_serial = 0
        endif
        let l:buf = l:buf.join(gsc#process_item(item, l:num_serial, '@'), "\n")."\n"
        if a:num == 1
            break
        endif
    endfor
    call gsc#clear()
    call gsc#write_to_buffer(l:buf)
    normal! k2dd
    call gsc#clear_echo_output()
    echo '共获取'.l:num.'条结果，用时 '.reltimestr(reltime(l:start_time)).'s'
    normal ggdd
    setlocal filetype=gsc
endfunction

function! GscWx(query)
    call gsc#clear()
    call GscWxAppend(a:query)
    normal! dd
endfunction


function! GscWxClearCache(key_word)
    if len(a:key_word) > 0
        let l:res = system('rm -rf '.g:gsc_wx_cache_path.'/'.gsc#md5(substitute(a:key_word, '\s', '', 'g')).'.wx*')
    else
        let l:res = system('rm -rf '.g:gsc_wx_cache_path.'/*.wx*')
    endif
    if len(l:res) > 0
        echo '清除失败, '.l:res
    else
        echo '清除成功'
    endif
endfunction

command! -nargs=+  GscWxAppend call GscWxAppend(<q-args>)
command! -nargs=+  GscWx call GscWx(<q-args>)
command! -nargs=?  GscWxClearCache call GscWxClearCache(<q-args>)
command! -nargs=?  GscWxRand call GscWxRand(<q-args>)
