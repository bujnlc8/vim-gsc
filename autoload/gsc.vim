function! gsc#get_visual_selection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    let l:selected = join(lines, '')
    let l:selected = substitute(l:selected, '[\s \u0001-\u0007]', '', 'g')
    let l:selected = matchstr(l:selected, '[\u4e00-\u9fa5 , ，。？；? ！! ：‘ “ 《 》 1-9 a-z A-Z ·.]*')
    return l:selected
endfunction

function! gsc#clear()
    execute 'normal gg100000dd'
endfunction

function! gsc#clear_echo_output()
    execute 'redraw!'
endfunction

function! gsc#md5(s)
    try
        if executable('md5')
            return matchstr(system('echo '.a:s.' | md5'), '[a-z 0-9]*')
        endif
        if executable('base64')
            return tolower(matchstr(system('echo '.a:s.' | base64'), '[a-z 0-9 A-Z]*'))
        endif
    catch
        return a:s
    endtry
endfunction

function! gsc#write_to_buffer(s)
    let l:origin = @a
    let @a = a:s
    normal! G
    execute 'put a'
    let @a = l:origin
endfunction


function! gsc#json_decode(s)
    let @b = a:s
    if exists('*json_decode')
        return json_decode(a:s)
    endif
    if has('python')
python << EOF
import json
import vim
res = json.loads(vim.bindeval('@b'),  encoding='utf-8', strict=False)
EOF
    elseif has('python3')
python3 << EOF
import json
import vim
res = json.loads(vim.bindeval('@b'))
EOF
    endif
    if has('python')
        return pyeval('res')
    elseif has('python3')
        return py3eval('res')
    endif
endfunction


function! gsc#json_encode(s)
    let @b = a:s
    if exists('*json_encode')
        return json_encode(a:s)
    endif
    if has('python')
python << EOF
import json
import vim
res = json.dumps(vim.bindeval('@b'))
EOF
    elseif has('python3')
python3 << EOF
import json
import vim
res = json.dumps(vim.bindeval('@b'))
EOF
    endif
    if has('python')
        return pyeval('res')
    elseif has('python3')
        return py3eval('res')
    endif
endfunction

function! gsc#process_item(item, num_serial, work_type)
    let item = a:item
    let l:title = substitute(item['work_title'], '\r', '', 'g')
    let l:author = item['work_author']
    let l:dynasty = '['.item['work_dynasty'].'] '
    let l:audio_id = item['audio_id']
    let l:content = substitute(item['content'], '\r', '', 'g')
    let l:translation = substitute(item['translation'], '\r', '', 'g')
    let l:intro = substitute(item['intro'], '\r', '', 'g')
    let l:annotation = substitute(item['annotation'], '\r', '', 'g')
    let l:appreciation = substitute(item['appreciation'], '\r', '', 'g')
    let l:master_comment = substitute(item['master_comment'], '\r', '', 'g')
    let l:title_md5 = gsc#md5(substitute(l:title.l:author.l:content[:5], '\s', '', 'g'))
    let l:map_file = g:gsc_map_cache.'/'.a:work_type.l:title_md5[:1]
    if !filereadable(l:map_file)
        call writefile([l:title_md5.':'.item['id']], l:map_file, 'a')
    else
        let l:need_write = 1
        for x in readfile(l:map_file)
            if match(x, l:title_md5) != -1
                let l:need_write = 0
                break
            endif
        endfor
        if l:need_write
            call writefile([l:title_md5.':'.item['id']], l:map_file, 'a')
        endif
    endif
    if g:gsc_wx_show_item_serial
        let l:title = a:num_serial.'.'.l:title
    endif
    if g:gsc_highlight
        let l:title = nr2char(2).l:title.nr2char(2)
        let l:content = nr2char(1).join(split(l:content, "\n"), "\n".nr2char(1))
    endif
    let l:ll = [l:title, l:dynasty.l:author, l:content."\n"]
    if g:gsc_wx_show_audio && l:audio_id > 0
        let l:ll = add(l:ll, '🔊 https://songci.nos-eastchina1.126.net/audio/'.l:audio_id.'.m4a'."\n")
    endif
    if a:work_type == '#' && g:gsc_show_url
        let l:ll = add(l:ll, '🔗 http://lib.xcz.im/work/'.item['id']."\n")
    endif
    if g:gsc_wx_show_intro && !gsc#string_is_empty(l:intro)
        if g:gsc_highlight
            let l:intro = nr2char(3).join(split(l:intro, "\n"), "\n".nr2char(3))
        endif
        let l:ll = add(l:ll, nr2char(1)."评析：".nr2char(1)."\n".l:intro."\n")
    endif
    if g:gsc_wx_show_annotation && !gsc#string_is_empty(l:annotation)
        if g:gsc_highlight
            let l:annotation = nr2char(4).join(split(l:annotation, "\n"), "\n".nr2char(4))
        endif
        let l:ll = add(l:ll, nr2char(1)."注释：".nr2char(1)."\n".l:annotation."\n")
    endif
    if g:gsc_wx_show_translation && !gsc#string_is_empty(l:translation)
        if g:gsc_highlight
            let l:translation = nr2char(5).join(split(l:translation, "\n"), "\n".nr2char(5))
        endif
        let l:ll = add(l:ll, nr2char(1)."译文：".nr2char(1)."\n".l:translation."\n")
    endif
    if g:gsc_wx_show_appreciation && !gsc#string_is_empty(l:appreciation)
        if g:gsc_highlight
            let l:appreciation = nr2char(6).join(split(l:appreciation, "\n"), "\n".nr2char(6))
        endif
        let l:ll = add(l:ll, nr2char(1)."赏析：".nr2char(1)."\n".l:appreciation."\n")
    endif
    if g:gsc_wx_show_master_comment && !gsc#string_is_empty(l:master_comment)
        if g:gsc_highlight
            let l:master_comment = nr2char(7).join(split(l:master_comment, "\n"), "\n".nr2char(7))
        endif
        let l:ll = add(l:ll,nr2char(1)."辑评：".nr2char(1)."\n".l:master_comment."\n")
    endif
    return l:ll
endfunction

function gsc#string_is_empty(s)
    if a:s == v:null || a:s == v:none
        return v:true
    endif
    if len(substitute(a:s, '\s', '', 'g')) == 0
        return v:true
    endif
    return v:false
endfunction
