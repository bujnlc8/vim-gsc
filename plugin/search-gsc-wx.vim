let s:curl = 'curl https://igsc.wx.haihui.site/songci/query/SEARCH_PLACEHOLDER/main/0'

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

function! SearchGscWx(query)
    try
        let l:curl_ = substitute(s:curl, 'SEARCH_PLACEHOLDER', a:query, '')
        let l:result = system(l:curl_.' | jq')
        let l:result = substitute(l:result, '^.*code', '', 'g')
        let l:json_res = json_decode('{"code'.l:result)
        for item in l:json_res['data']['data']
            let l:title = substitute(item['work_title'], '\r', '', 'g')
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
                let l:ll = add(l:ll, 'https://songci.nos-eastchina1.126.net/audio/'.l:audio_id.'.m4a')
            elseif g:search_gsc_wx_show_intro && len(l:intro) > 0
                let l:ll = add(l:ll, "评析：\n".l:intro)
            elseif g:search_gsc_wx_show_annotation && len(l:annotation) > 0
                let l:ll = add(l:ll, "注释：\n".l:annotation)
            elseif g:search_gsc_wx_show_translation && len(l:translation) > 0
                let l:ll = add(l:ll, "译文：\n".l:translation)
            elseif g:search_gsc_wx_show_appreciation && len(l:appreciation) > 0
                let l:ll = add(l:ll, "赏析：\n".l:appreciation)
            elseif g:search_gsc_wx_show_master_comment && len(l:master_comment) > 0
                let l:ll = add(l:ll, "辑评：\n".l:master_comment)
            endif
            execute "normal! Go".join(l:ll, "\n")."\n"
        endfor
        execute 'normal! gg'
        execute 'normal! dd'
        echo '共'.len(l:json_res['data']['data']).'条相关结果'
    catch
        echo '搜索出错, 请稍后再试:('
    endtry
endfunction

command! -nargs=+  SearchGSCWx call SearchGscWx(<q-args>)
