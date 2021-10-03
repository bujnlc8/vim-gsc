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
    let l:selected = substitute(l:selected, '\s', '', 'g')
    let l:selected = matchstr(l:selected, '[\u4e00-\u9fa5 , ，。？；? ！! ：‘ “ 《 》 1-9 a-z A-Z ·]*')
    return l:selected
endfunction

function! gsc#clear()
    execute 'normal gg100000dd'
endfunction

function! gsc#clear_echo_output()
    execute 'redraw!'
endfunction

function! gsc#md5(s)
    if executable('md5')
        return matchstr(system('echo '.a:s.' | md5'), '[a-z 0-9]*')
    endif
    return a:s
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
