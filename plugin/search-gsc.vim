let s:curl = 'curl "https://avoscloud.com/1.1/call/searchWorks2"
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
            \ --data-raw "{\"q\":\"SEARCH_PLACEHOLDER\"}"
            \ --compressed'


if !exists('g:search_gsc_show_url')
    let g:search_gsc_show_url = 0
endif

if !exists('g:search_gsc_show_item_serial')
    let g:search_gsc_show_item_serial = 1
endif

function! SearchGsc(query)
    try
        let l:curl_ = substitute(s:curl, 'SEARCH_PLACEHOLDER', a:query, '')
        echo '正在搜索🔍...'
        let l:result = system(l:curl_.' | jq')
        let l:result = substitute(l:result, '^.*result', '', 'g')
        let l:json_res = json_decode('{"result'.l:result)
        let l:num_serial = 0
        for item in l:json_res['result']
            let l:num_serial = l:num_serial + 1
            let l:title = substitute(item['work']['title'], '\r', '', 'g')
            if g:search_gsc_show_item_serial
                let l:title = l:num_serial.'.'.l:title
            endif
            let l:author = item['work']['authorName']
            let l:dynasty = '['.item['work']['dynasty'].']'
            let l:object_id = item['work']['objectId']
            let l:content = substitute(item['work']['content'], '\r', '', 'g')
            if g:search_gsc_show_url
                execute "normal! Go".join([l:title, l:dynasty.l:author, l:content."\n", 'http://lib.xcz.im/work/'.l:object_id."\n"], "\n")
            else
                execute "normal! Go".join([l:title, l:dynasty.l:author, l:content."\n"], "\n")
            endif
        endfor
        execute 'normal! gg'
        "execute 'normal! 1,1g/^\s*$/d'
        call ClearEchoOuput()
        echo '共'.len(l:json_res['result']).'条相关结果'
    catch
        echo '搜索出错, 请稍后再试:('
    endtry
endfunction

function! SearchGscTidy(query)
    call Clear()
    call SearchGsc(a:query)
    normal! dd
endfunction

command! -nargs=+  SearchGsc call SearchGsc(<q-args>)
command! -nargs=+ SearchGscTidy call SearchGscTidy(<q-args>)
