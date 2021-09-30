let s:curl = 'curl "https://avoscloud.com/1.1/call/searchWorks"
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

function! SearchGsc(query)
    try
        let l:curl_ = substitute(s:curl, 'SEARCH_PLACEHOLDER', a:query, '')
        let l:result = system(l:curl_.' | jq')
        let l:result = substitute(l:result, '^.*result', '', 'g')
        let l:json_res = json_decode('{"result'.l:result)
        for item in l:json_res['result']
            let l:title = substitute(item['title'], '\r', '', 'g')
            let l:author = item['authorName']
            let l:dynasty = '['.item['dynasty'].']'
            let l:object_id = item['objectId']
            let l:content = substitute(item['content'], '\r', '', 'g')
            if g:search_gsc_show_url
                execute "normal! Go".join([l:title, l:dynasty.l:author, l:content."\n", 'http://lib.xcz.im/work/'.l:object_id."\n"], "\n")
            else
                execute "normal! Go".join([l:title, l:dynasty.l:author, l:content."\n"], "\n")
            endif
        endfor
      execute 'go 1'
    catch
        echo '搜索出错, 请稍后再试:('
    endtry
endfunction

command! -nargs=+  SearchGSC call SearchGsc(<q-args>)
