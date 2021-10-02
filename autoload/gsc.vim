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
    try
        return matchstr(system('echo '.a:s.' | md5'), '[a-z 0-9]*')
    catch
        return a:s
    endtry
endfunction
