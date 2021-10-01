let s:curl = 'curl https://igsc.wx.haihui.site/songci/query/SEARCH_PLACEHOLDER/main/0 -H "User-Agent:vim-plugin"'

if !exists('g:search_gsc_wx_show_audio')
    let g:search_gsc_wx_show_audio = 1
endif

if !exists('g:search_gsc_wx_translation')
    let g:search_gsc_wx_show_translation = 1
endif

if !exists('g:search_gsc_wx_show_intro')
    let g:search_gsc_wx_show_intro = 1
endif

if !exists('g:search_gsc_wx_show_annotation')
    let g:search_gsc_wx_show_annotation = 0
endif

if !exists('g:search_gsc_wx_show_appreciation')
    let g:search_gsc_wx_show_appreciation = 0
endif

if !exists('g:search_gsc_wx_show_master_comment')
    let g:search_gsc_wx_show_master_comment = 0
endif

if !exists('g:search_gsc_wx_show_item_serial')
    let g:search_gsc_wx_show_item_serial = 1
endif

function! SearchGscWx(query)
    try
        let l:query = substitute(a:query, '\s', '', 'g')
        let l:curl_ = substitute(s:curl, 'SEARCH_PLACEHOLDER', l:query, '')
        echo '正在搜索🔍...'
        let l:result = system(l:curl_.' |jq')
        let l:result = substitute(l:result, '^.*code', '', 'g')
        let l:json_res = json_decode('{"code'.l:result)
        let l:num_serial = 0
        for item in l:json_res['data']['data']
            let l:num_serial = l:num_serial + 1
            let l:title = substitute(item['work_title'], '\r', '', 'g')
            if g:search_gsc_wx_show_item_serial
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
            if g:search_gsc_wx_show_audio && l:audio_id > 0
                let l:ll = add(l:ll, 'https://songci.nos-eastchina1.126.net/audio/'.l:audio_id.'.m4a'."\n")
            endif
            if g:search_gsc_wx_show_intro && len(l:intro) > 0
                let l:ll = add(l:ll, "评析：\n".l:intro."\n")
            endif
            if g:search_gsc_wx_show_annotation && len(l:annotation) > 0
                let l:ll = add(l:ll, "注释：\n".l:annotation, "\n")
            endif
            if g:search_gsc_wx_show_translation && len(l:translation) > 0
                let l:ll = add(l:ll, "译文：\n".l:translation."\n")
            endif
            if g:search_gsc_wx_show_appreciation && len(l:appreciation) > 0
                let l:ll = add(l:ll, "赏析：\n".l:appreciation."\n")
            endif
            if g:search_gsc_wx_show_master_comment && len(l:master_comment) > 0
                let l:ll = add(l:ll, "辑评：\n".l:master_comment."\n")
            endif
            execute "normal! Go".join(l:ll, "\n")."\n"
        endfor
        "execute 'normal! 1,1g/^\s*$/d'
        call ClearEchoOuput()
        echo '共'.len(l:json_res['data']['data']).'条相关结果'
        normal gg
    catch
        echo '搜索出错, 请稍后再试:('
    endtry
endfunction

function! Clear()
    execute "normal gg100000dd"
endfunction

function! ClearEchoOuput()
    execute 'redraw!'
endfunction

function! SearchGscWxTidy(query)
    call Clear()
    call SearchGscWx(a:query)
    normal! dd
endfunction

command! -nargs=+  SearchGscWx call SearchGscWx(<q-args>)
command! -nargs=+  SearchGscWxTidy call SearchGscWxTidy(<q-args>)
