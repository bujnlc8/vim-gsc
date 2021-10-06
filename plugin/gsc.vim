let s:curl_option = ' -H "authority: avoscloud.com" -H "x-lc-ua: LeanCloud-JS-SDK/3.15.0 (Browser)" -H "dnt: 1" -H "sec-ch-ua-mobile: ?0" -H "user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36" -H "content-type: application/json;charset=UTF-8" -H "x-lc-sign: 8e33bfbb3625e1b6a261487dc7f38dca,1633015485114" -H "x-lc-session: saxj96gey4hqsy7wxp4zrnywp" -H "x-lc-id: 9pq709je4y36ubi10xphdpovula77enqrz27idozgry7x644" -H "x-lc-prod: 1"  -H "accept: */*"  -H "origin: http://lib.xcz.im" -H "sec-fetch-site: cross-site"  -H "sec-fetch-mode: cors" -H "sec-fetch-dest: empty" -H "referer: http://lib.xcz.im/"  -H "accept-language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7" '

" 统一搜索
let s:curl = 'curl -s "https://avoscloud.com/1.1/call/searchWorks2" '.s:curl_option.'--data "{\"q\":\"SEARCH_PLACEHOLDER\"}"'

" 根据work_id搜索
let s:curl_by_id = 'curl -s "https://avoscloud.com/1.1/call/getWorkById"'.s:curl_option.'--data "{\"workId\":\"WORK_ID\"}"'

" 获取作者信息
let s:curl_get_author = 'curl -s "https://avoscloud.com/1.1/call/getAuthorById2"'.s:curl_option.'--data "{\"authorId\":\"AUTHOR_ID\"}"'

" 根据作者搜索
let s:curl_get_works_by_author = 'curl -s "https://avoscloud.com/1.1/call/getWorksByAuthor"'.s:curl_option.'--data "{\"authorId\":\"AUTHOR_ID\", \"page\": _PAGE, \"perPage\": _PERPAGE}"'

" 获取名句
let s:curl_get_quotes = 'curl -s "https://avoscloud.com/1.1/call/getQuotesIncludeCount"'.s:curl_option.'--data "{\"authorId\": \"AUTHOR_ID\",\"kind\":null,\"dynasty\":null,\"collectionId\":null,\"page\":_PAGE,\"perPage\":_PERPAGE}"'

" 获取合集
let s:curl_get_collections = 'curl -s "https://avoscloud.com/1.1/call/getWorksByCollection"'.s:curl_option.'--data "{\"collectionId\":\"COLLECTION_ID\", \"page\": _PAGE, \"perPage\": _PERPAGE}"'

" 根据朝代搜索
let s:curl_get_works_by_dynasty = 'curl -s "https://avoscloud.com/1.1/call/getWorksIncludeCountByDynasty"'.s:curl_option.'--data "{\"dynasty\":\"_DYNASTY\", \"page\": _PAGE, \"perPage\": _PERPAGE}"'

" 根据体裁搜索
let s:curl_get_works_by_kind = 'curl -s "https://avoscloud.com/1.1/call/getWorksIncludeCountByGenreKind"'.s:curl_option.'--data "{\"kind\":\"_KIND\", \"page\": _PAGE, \"perPage\": _PERPAGE}"'

" 根据work_id 搜索igsc
let s:curl_get_by_id_wx = 'curl -s https://igsc.wx.haihui.site/songci/index/WORK_ID/vim -H "User-Agent:vim-plugin"'

" 体裁
let s:kinds = {'诗': 'shi',
            \'词': 'ci',
            \'曲': 'fu',
            \'赋': 'fu',
            \'古文': 'wen',
            \'文言文': 'wen',
            \'歌': 'fu',
            \}

let s:dynasties = ['商','周','秦','汉','三国','晋','南北朝','隋','唐','五代十国','宋','金','元','明','清','现代']


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

let g:gsc_plugin_path = expand('<sfile>:p:h')

let g:gsc_map_cache = g:gsc_plugin_path.'/.map'

if !isdirectory(g:gsc_map_cache)
    call mkdir(g:gsc_map_cache)
endif

if !exists('g:gsc_cache_path')
    let g:gsc_cache_path = g:gsc_plugin_path.'/cache'
endif

if !exists('g:gsc_collect_path')
    let g:gsc_collect_path = expand('~/.vim_gsc_collect', ':p')
endif

if g:gsc_cache
    if !isdirectory(g:gsc_cache_path)
        call mkdir(g:gsc_cache_path)
    endif
endif

function! GscAppend(query)
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
        let l:json_res = gsc#json_decode(l:result)
        let l:num_serial = 0
        for item in l:json_res['result']
            let l:num_serial = l:num_serial + 1
            let l:ll = gsc#process_item(s:process_item(item['work']['objectId'], '#'), l:num_serial, '#')
            let l:buf = l:buf.join(l:ll, "\n")."\n"
        endfor
        let l:buf = l:buf.'GgGg'.len(l:json_res['result'])
        if g:gsc_cache
            try
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
endfunction

function! GscCollect(words)
    let l:words = substitute(a:words, '\s', '', 'g')
    let l:words_md5 = gsc#md5(l:words)
    let l:prefix = '#'
    let l:map_file = g:gsc_map_cache.'/'.l:prefix.l:words_md5[:1]
    if !isdirectory(l:map_file)
        let l:prefix = '@'
        let l:map_file = g:gsc_map_cache.'/'.l:prefix.l:words_md5[:1]
        if !isdirectory(l:map_file)
            echo '找不到id'
            return
        else
            let l:map_file = l:map_file.'/'.l:words_md5[2:3]
            if !filereadable(l:map_file)
                echo '找不到id'
                return
            endif
        endif
    else
        let l:map_file = l:map_file.'/'.l:words_md5[2:3]
        if !filereadable(l:map_file)
            echo '找不到id'
            return
        endif
    endif
    let l:data = readfile(l:map_file)
    let l:object_id = ''
    for item in l:data
        if match(item, l:words_md5) != -1
            let l:object_id = split(item, ':')[1]
            break
        endif
    endfor
    if len(l:object_id) == 0
        echo '找不到id'
        return
    endif
    try
        if filereadable(g:gsc_collect_path)
            for x in readfile(g:gsc_collect_path)
                if x == l:prefix.l:object_id
                    echo '收藏成功'
                    return
                endif
            endfor
        endif
        call writefile([l:prefix.l:object_id.':'.strftime('%Y%m%d%H%M%S').l:words], g:gsc_collect_path, 'a')
        echo '收藏成功'
    catch
        echo '收藏失败'
    endtry
endfunction

function! s:process_item(work_id, work_type)
    let l:work_md5 = gsc#md5(a:work_type.a:work_id)
    if a:work_type == '#'
        let l:cache_path = g:gsc_cache_path.'/'.l:work_md5.'.xcz.'.g:gsc_cache_comp_algo[0:1].'.cache'
        let l:res = ''
        if g:gsc_cache
            if filereadable(l:cache_path)
                try
                    let l:res = system('cat "' .l:cache_path.'" | '.g:gsc_cache_comp_algo.' -d')
                catch
                    let l:res = ''
                endtry
            endif
        endif
        if len(l:res) == 0
            let l:curl = substitute(s:curl_by_id, 'WORK_ID', a:work_id, 'g')
            let l:result = system(l:curl)
            let l:result = gsc#json_decode(l:result)['result']
            let l:res = {
                        \'id': a:work_id,
                        \'work_title': l:result['title'],
                        \'content': l:result['content'],
                        \'audio_id': 0,
                        \'work_author': l:result['authorName'],
                        \'work_dynasty': l:result['dynasty'],
                        \'translation': l:result['translation'],
                        \'intro': l:result['intro'],
                        \'annotation': l:result['annotation'],
                        \'appreciation': l:result['appreciation'],
                        \'master_comment': l:result['masterComment'],
                        \}
            if g:gsc_cache
                try
                    let l:buf = gsc#json_encode(l:res)
                    call system("echo '".l:buf."' | ".g:gsc_cache_comp_algo." --best > ".l:cache_path)
                catch
                    call delete(l:cache_path)
                endtry
            endif
            return l:res
        else
            return gsc#json_decode(l:res)
        endif
    else
        let l:cache_path = g:gsc_wx_cache_path.'/'.l:work_md5.'.wx.'.g:gsc_cache_comp_algo[0:1].'.cache'
        let res = ''
        if g:gsc_wx_cache
            if filereadable(l:cache_path)
                try
                    let l:res = system('cat "' .l:cache_path.'" | '.g:gsc_cache_comp_algo.' -d')
                catch
                    let l:res = ''
                endtry
            endif
        endif
        if len(l:res) == 0
            let l:res = system(substitute(s:curl_get_by_id_wx, 'WORK_ID', a:work_id, 'g'))
            if g:gsc_wx_cache
                try
                    call system("echo '".l:buf."' | ".g:gsc_cache_comp_algo." --best > ".l:cache_path)
                catch
                    call delete(l:cache_path)
                endtry
            endif
            return gsc#json_decode(l:res)['data']['data']
        else
            return gsc#json_decode(l:res)['data']['data']
        endif
    endif
endfunction

function! GscCollectList(num)
    let l:filter_str = ''
    if len(a:num) > 0
        let l:num = a:num + 0
        if l:num < 0
            echo '请输入正确的数量'
            return
        elseif l:num == 0
            let l:filter_str = a:num
            let l:num = 100000
        endif
    else
        let l:num = 100000
    endif
    let l:start_time = reltime()
    if filereadable(g:gsc_collect_path)
        let l:num_serial = 0
        let l:buf = ''
        for x in readfile(g:gsc_collect_path)
            if l:num_serial >= l:num
                break
            endif
            let l:num_serial = l:num_serial + 1
            let l:tmp = split(x, ':')[0]
            let l:ll = s:process_item(l:tmp[1:], l:tmp[0])
            let l:tmp = join(gsc#process_item(l:ll, l:num_serial, x[0]), "\n")
            if len(l:filter_str) > 0
                if match(l:tmp, l:filter_str) == -1
                    let l:num_serial = l:num_serial - 1
                    continue
                endif
            endif
            let l:buf = l:buf.l:tmp."\n"
        endfor
        if len(l:buf) == 0
            if len(l:filter_str) > 0
                echo '未根据 '.l:filter_str.' 筛选出结果, 你可以执行 :GscCollect `$title$author$content[:2]来添加!'
            else
                echo '当前没有收藏，你可以执行 :GscCollect `$title$author$content[:2]来添加!'
            endif
            return
        endif
        call gsc#clear()
        call gsc#write_to_buffer(l:buf)
        call gsc#clear_echo_output()
        normal! ggdd
        setlocal filetype=gsc
        echo '总共取回'.l:num_serial.'条收藏记录，用时'.reltimestr(reltime(l:start_time)).'s'
    else
        echo '当前没有收藏，请检查文件'.g:gsc_collect_path.'的读写权限，或者你可以尝试执行 :GscCollect `$title$author$content[:2]来添加!'
    endif
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

function! GscSearchSelect(work_type)
    let l:selected = gsc#get_visual_selection()
    if len(l:selected) > 0
        if a:work_type == '#'
            call Gsc(l:selected)
        else
            call GscWx(l:selected)
        endif
    else
        echo '请选择搜索词'
    endif
endfunction

function! GscAuthorInfo(author_name)
    let l:author_name = substitute(a:author_name, '\s', '', 'g')
    if !has_key(g:author#map, l:author_name)
        echo '找不到作者 '.a:author_name
        return
    endif
    let l:curl = substitute(s:curl_get_author, 'AUTHOR_ID', g:author#map[author_name], '')
    let l:res = gsc#json_decode(system(l:curl))['result']
    let l:name = nr2char(1).l:res['name'].nr2char(1).'('.l:res['birthYear'].'~'.l:res['deathYear'].')'
    let l:desc = nr2char(5).l:res['desc'].nr2char(5)
    let l:url = ''
    if has_key(l:res, 'baiduWiki')
        let l:url = l:res['baiduWiki']
    endif
    let l:buf = join([l:name, l:desc, l:url], "\n\n")
    call gsc#clear()
    call gsc#write_to_buffer(l:buf)
    normal ggdd
    setlocal ft=gsc
endfunction

function! s:render_by_page(page, page_size, name, url, depth=1)
    echo '正在获取 '.a:name.' 第'.abs(a:page).'页作品🔥 ...'
    if a:depth == 2
        let l:res = gsc#json_decode(system(a:url))['result']['works']
    else
        let l:res = gsc#json_decode(system(a:url))['result']
    endif
    if a:page <= 0
        let l:num_serial = 0
    else
        let l:num_serial  = (a:page - 1) * a:page_size
    endif
    let l:buf = ''
    for item in l:res
        let l:num_serial = l:num_serial + 1
        let l:work_md5 = gsc#md5('#'.item['objectId'])
        let l:cache_path = g:gsc_cache_path.'/'.l:work_md5.'.xcz.'.g:gsc_cache_comp_algo[0:1].'.cache'
        let l:item = {
                    \'id': item['objectId'],
                    \'work_title': item['title'],
                    \'content': item['content'],
                    \'audio_id': 0,
                    \'work_author': item['authorName'],
                    \'work_dynasty': item['dynasty'],
                    \'translation': item['translation'],
                    \'intro': item['intro'],
                    \'annotation': item['annotation'],
                    \'appreciation': item['appreciation'],
                    \'master_comment': item['masterComment'],
                    \}
        if g:gsc_cache && !filereadable(l:cache_path)
            try
                call system("echo '".gsc#json_encode(l:item)."' | ".g:gsc_cache_comp_algo." --best > ".l:cache_path)
            catch
                call delete(l:cache_path)
            endtry
        endif
        let l:buf = l:buf.join(gsc#process_item(l:item, l:num_serial, '#'), "\n")."\n"
    endfor
    call gsc#write_to_buffer(l:buf)
    if a:page <= 1
        normal! ggdd
    endif
    call gsc#clear_echo_output()
    setlocal ft=gsc
    return len(l:res)
endfunction

function! s:render_quote_by_page(author_id, page, page_size, author_name)
    let l:curl = substitute(s:curl_get_quotes, 'AUTHOR_ID', a:author_id, '')
    let l:curl = substitute(l:curl, '_PAGE', abs(a:page), '')
    let l:curl = substitute(l:curl, '_PERPAGE', a:page_size, '')
    echo '正在获取'.a:author_name.'第'.abs(a:page).'页名句🔥 ...'
    let l:res = gsc#json_decode(system(l:curl))['result']['quotes']
    let l:buf = ''
    if a:page <= 0
        let l:num_serial = 0
    else
        let l:num_serial  = (a:page - 1) * a:page_size
    endif
    for item in l:res
        let l:num_serial = l:num_serial + 1
        if a:page_size != 1
            if has_key(item, 'work')
                let l:buf = l:buf.nr2char(4).l:num_serial.'.'.item['quote'].nr2char(4)."\n".nr2char(1).'---'.item['dynasty'].'·'.item['authorName'].'  《'.item['work']['title'].'》'.nr2char(1)."\n\n"
            else
                let l:buf = l:buf.nr2char(4).l:num_serial.'.'.item['quote'].nr2char(4)."\n".nr2char(1).'---'.item['dynasty'].'·'.item['authorName'].nr2char(1)."\n\n"
            endif
        else
            if has_key(item, 'work')
                let l:buf = l:buf.nr2char(4).item['quote'].nr2char(4)."\n".nr2char(1).'---'.item['dynasty'].'·'.item['authorName'].'  《'.item['work']['title'].'》'.nr2char(1)."\n\n"
            else
                let l:buf = l:buf.nr2char(4).item['quote'].nr2char(4)."\n".nr2char(1).'---'.item['dynasty'].'·'.item['authorName'].nr2char(1)."\n\n"
            endif
        endif
    endfor
    call gsc#write_to_buffer(l:buf)
    if a:page <= 1
        normal! ggdd
    endif
    call gsc#clear_echo_output()
    setlocal ft=gsc
    return len(l:res)
endfunction

function! GscAuthorWorks(author_name, ...)
    let l:author_name = a:author_name
    if !has_key(g:author#map, l:author_name)
        echo '找不到作者 '.a:author_name
        return
    endif
    let l:author_id = g:author#map[l:author_name]
    let l:page = 1
    let l:page_size = 20
    if len(a:000) >= 2
        let l:page = a:000[0] + 0
        let l:page_size = a:000[1] + 0
    endif
    if len(a:000) >= 1
        let l:page = a:000[0] + 0
    endif
    let l:start_time = reltime()
    call gsc#clear()
    let l:total_num = 0
    if l:page < 0
        let l:curl = substitute(s:curl_get_works_by_author, 'AUTHOR_ID', l:author_id, '')
        let l:curl = substitute(l:curl, '_PAGE', abs(l:page), '')
        let l:curl = substitute(l:curl, '_PERPAGE', l:page_size, '')
        let l:total_num = l:total_num + s:render_by_page(l:page, l:page_size, l:author_name, l:curl)
    else
        for page in range(l:page)
            let l:curl = substitute(s:curl_get_works_by_author, 'AUTHOR_ID', l:author_id, '')
            let l:curl = substitute(l:curl, '_PAGE', page, '')
            let l:curl = substitute(l:curl, '_PERPAGE', l:page_size, '')
            let l:total_num = l:total_num + s:render_by_page(page + 1, l:page_size, l:author_name, l:curl)
        endfor
    endif
    echo '总共获取'.l:total_num.'条记录，用时'.reltimestr(reltime(l:start_time)).'s'
endfunction


function! GscDynastyWorks(dynasty, ...)
    let l:dynasty = substitute(a:dynasty, '\s', '', 'g')
    if index(s:dynasties, l:dynasty) < 0
        echo '朝代 '.l:dynasty. ' 不存在， 你可以输入以下朝代: '.join(s:dynasties, ', ')
        return
    endif
    let l:page = 1
    let l:page_size = 20
    if len(a:000) >= 2
        let l:page = a:000[0] + 0
        let l:page_size = a:000[1] + 0
    endif
    if len(a:000) >= 1
        let l:page = a:000[0] + 0
    endif
    let l:start_time = reltime()
    call gsc#clear()
    let l:total_num = 0
    if l:page < 0
        let l:curl = substitute(s:curl_get_works_by_dynasty, '_DYNASTY', l:dynasty, '')
        let l:curl = substitute(l:curl, '_PAGE', abs(l:page()), '')
        let l:curl = substitute(l:curl, '_PERPAGE', l:page_size, '')
        let l:total_num = l:total_num + s:render_by_page(l:page, l:page_size, l:dynasty, l:curl, 2)
    else
        for page in range(l:page)
            let l:curl = substitute(s:curl_get_works_by_dynasty, '_DYNASTY', l:dynasty, '')
            let l:curl = substitute(l:curl, '_PAGE', page, '')
            let l:curl = substitute(l:curl, '_PERPAGE', l:page_size, '')
            let l:total_num = l:total_num + s:render_by_page(page + 1, l:page_size, l:dynasty, l:curl, 2)
        endfor
    endif
    echo '总共获取'.l:total_num.'条记录，用时'.reltimestr(reltime(l:start_time)).'s'
endfunction

function! GscCollectionWorks(collection_name, ...)
    let l:collection_name = a:collection_name
    if !has_key(g:collection#map, l:collection_name)
        echo '找不到合集 '.a:collection_name.':GscCollectionList 查看合集列表'
        return
    endif
    let l:collection_id = g:collection#map[l:collection_name]
    let l:page = 1
    let l:page_size = 20
    if len(a:000) >= 2
        let l:page = a:000[0] + 0
        let l:page_size = a:000[1] + 0
    endif
    if len(a:000) >= 1
        let l:page = a:000[0] + 0
    endif
    let l:start_time = reltime()
    call gsc#clear()
    let l:total_num = 0
    if l:page < 0
        let l:total_num = l:total_num + s:render_collection_by_page(l:collection_id, l:page, l:page_size, l:collection_name)
    else
        for page in range(l:page)
            let l:total_num = l:total_num + s:render_collection_by_page(l:collection_id, page + 1, l:page_size, l:collection_name)
        endfor
    endif
    echo '总共获取'.l:total_num.'条记录，用时'.reltimestr(reltime(l:start_time)).'s'
endfunction

function! s:render_collection_by_page(collection_id, page, page_size, collection_name)
    let l:curl = substitute(s:curl_get_collections, 'COLLECTION_ID', a:collection_id, '')
    let l:curl = substitute(l:curl, '_PAGE', abs(a:page), '')
    let l:curl = substitute(l:curl, '_PERPAGE', a:page_size, '')
    echo '正在获取合集'.a:collection_name.'第'.abs(a:page).'页作品🔥 ...'
    let l:res = gsc#json_decode(system(l:curl))['result']
    let l:buf = ''
    if a:page <= 0
        let l:num_serial = 0
    else
        let l:num_serial  = (a:page - 1) * a:page_size
    endif
    for item in l:res
        let l:num_serial = l:num_serial + 1
        let l:ll = gsc#process_item(s:process_item(item['objectId'], '#'), l:num_serial, '#')
        let l:buf = l:buf.join(l:ll, "\n")."\n"
    endfor
    call gsc#write_to_buffer(l:buf)
    if a:page <= 1
        normal! ggdd
    endif
    call gsc#clear_echo_output()
    setlocal ft=gsc
    return len(l:res)
endfunction

function! GscQuotes(...)
    let l:author_name = ''
    let l:page = 1
    let l:page_size = 20
    if len(a:000) >= 3
        let l:page = a:000[0] + 0
        let l:page_size = a:000[1] + 0
        let l:author_name = a:000[2]
    elseif len(a:000) >= 2
        let l:page = a:000[0] + 0
        let l:page_size = a:000[1] + 0
    elseif len(a:000) >= 1
        let l:page = a:000[0] + 0
    endif
    let l:author_id = ''
    if len(l:author_name) >0
        if !has_key(g:author#map, l:author_name)
            echo '找不到作者 '.l:author_name
            return
        else
            let l:author_id = g:author#map[l:author_name]
        endif
    endif
    let l:start_time = reltime()
    call gsc#clear()
    let l:total_num = 0
    if l:page != -1
        if l:page < 0
            let l:total_num = l:total_num + s:render_quote_by_page(l:author_id, l:page, l:page_size, l:author_name)
        else
            for page in range(l:page)
                let l:total_num = l:total_num + s:render_quote_by_page(l:author_id, page + 1, l:page_size, l:author_name)
            endfor
        endif
    else
        if len(l:author_name) > 0
            let l:num = 50
        else
            let l:num = 4200
        endif
        let l:page = -float2nr(l:num / l:page_size * gsc#random())
        if l:page == 0
            let l:page = 1
        endif
        let l:total_num = l:total_num + s:render_quote_by_page(l:author_id, l:page, l:page_size, l:author_name)
    endif
    echo '总共获取'.l:total_num.'条记录，用时'.reltimestr(reltime(l:start_time)).'s'
endfunction

function! GscKindWorks(kind, ...)
    let l:page = 1
    let l:page_size = 20
    if len(a:000) >= 2
        let l:page = a:000[0] + 0
        let l:page_size = a:000[1] + 0
    elseif len(a:000) >= 1
        let l:page = a:000[0] + 0
    endif
    let l:kind_id = ''
    if !has_key(s:kinds, a:kind)
        echo '找不到体裁 '.a:kind.'. 你可以输入以下体裁: '.join(sort(keys(s:kinds)), ', ')
        return
    else
        let l:kind_id = s:kinds[a:kind]
    endif
    let l:start_time = reltime()
    call gsc#clear()
    let l:total_num = 0
    if l:page != -1
        if l:page < 0
            let l:curl = substitute(s:curl_get_works_by_kind, '_KIND', l:kind_id, '')
            let l:curl = substitute(l:curl, '_PAGE', abs(l:page), '')
            let l:curl = substitute(l:curl, '_PERPAGE', l:page_size, '')
            let l:total_num = l:total_num + s:render_by_page(l:page, l:page_size, a:kind, l:curl,  2)
        else
            for page in range(l:page)
                let l:curl = substitute(s:curl_get_works_by_kind, '_KIND', l:kind_id, '')
                let l:curl = substitute(l:curl, '_PAGE', page, '')
                let l:curl = substitute(l:curl, '_PERPAGE', l:page_size, '')
                let l:total_num = l:total_num + s:render_by_page(page + 1, l:page_size, a:kind, l:curl, 2)
            endfor
        endif
    else
        if l:kind_id == 'shi'
            let l:num = 761778
        elseif l:kind_id == 'ci'
            let l:num = 72945
        elseif l:kind_id == 'fu'
            let l:num = 235
        else
            let l:num = 7406
        endif
        let l:page = -float2nr(l:num / l:page_size * gsc#random())
        if l:page == 0
            let l:page = 1
        endif
        let l:curl = substitute(s:curl_get_works_by_kind, '_KIND', l:kind_id, '')
        let l:curl = substitute(l:curl, '_PAGE', abs(l:page), '')
        let l:curl = substitute(l:curl, '_PERPAGE', l:page_size, '')
        let l:total_num = l:total_num + s:render_by_page(l:page, l:page_size, a:kind, l:curl, 2)
    endif
    echo '总共获取'.l:total_num.'条记录，用时'.reltimestr(reltime(l:start_time)).'s'
endfunction

function! GscCollectEdit()
    execute 'tabnew '.g:gsc_collect_path
endfunction

function! GscCollectionList(arg)
    if len(a:arg) > 0
        if !has_key(g:collection#map, a:arg)
            echo '找不到合集 '.a:arg
        else
            echo '合集 '.a:arg.' 存在'
        endif
        return
    endif
    let l:buf = ''
    for key in sort(keys(g:collection#map))
        let l:buf = l:buf .nr2char(4).key..nr2char(4)."\n"
    endfor
    call gsc#clear()
    call gsc#write_to_buffer(l:buf)
    call gsc#clear_echo_output()
    normal ggdd
    setlocal ft=gsc
endfunction


command! -nargs=+  GscAppend call GscAppend(<q-args>)
command! -nargs=+ Gsc call Gsc(<q-args>)
command! -nargs=?  GscClearCache call GscClearCache(<q-args>)
command! -nargs=+ GscCollect call GscCollect(<q-args>)
command! -nargs=? GscCollectList call GscCollectList(<q-args>)
command! -narg=+ GscAuthorInfo call GscAuthorInfo(<q-args>)
command! -nargs=+  GscAuthorWorks call GscAuthorWorks(<f-args>)
command! -nargs=+  GscDynastyWorks call GscDynastyWorks(<f-args>)
command! -nargs=+  GscKindWorks call GscKindWorks(<f-args>)
command! -nargs=*  GscQuotes call GscQuotes(<f-args>)
command! -nargs=?  GscCollectEdit call GscCollectEdit()
command! -nargs=+  GscCollectionWorks call GscCollectionWorks(<f-args>)
command! -nargs=? GscCollectionList call GscCollectionList(<q-args>)
