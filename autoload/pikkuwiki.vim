function! pikkuwiki#Open(...)
    if a:0 >= 1
        let result = system(g:pikkuwiki_cmd . ' resolve "" ' . a:1)
    else
        let link = expand('<cfile>')
        let currentfile = expand('%:p')
        let result = system(
            \ g:pikkuwiki_cmd . ' resolve "'
            \ . l:currentfile . '" "' . l:link . '"')
    endif
    execute 'edit ' . l:result
endfunction

function! pikkuwiki#MinimalWindowSize()
    let maxsize = g:pikkuwiki_search_window_size
    let buflines = line('$')
    let wsize = min([l:maxsize, &lines / 2, l:buflines])
    execute 'resize ' . l:wsize
endfunction

function! pikkuwiki#InitSearchWindow()
    let startwin = winnr()
    let findwindownr = 0

    for winnumber in range(1, winnr('$'))
        execute winnumber . 'wincmd w'
        if &filetype == 'pikkuwiki_search'
            let findwindownr = winnumber
            break
        endif
    endfor

    if !findwindownr
        execute startwin . 'wincmd w'
        botright new
        set filetype=pikkuwiki_search
    endif
endfunction

function! pikkuwiki#ReplaceContentsWithCommand(cmd)
    silent %d
    execute 'silent $read !' . a:cmd
    g/^$/d
    1
endfunction

function! pikkuwiki#Search(cmd, head, pattern)
    call pikkuwiki#InitSearchWindow()
    setl modifiable
    call pikkuwiki#ReplaceContentsWithCommand(a:cmd)
    call pikkuwiki#MinimalWindowSize()
    let &l:statusline=a:head . ': ' . a:pattern . ' %= %l/%L'
    setl nomodifiable
endfunction

function! pikkuwiki#Find(...)
    let pattern = a:0 >= 1 ? a:1 : ''
    let cmd = g:pikkuwiki_cmd . ' find -F pretty -p "' . l:pattern . '"'
    call pikkuwiki#Search(l:cmd, 'pikkuwiki pages', l:pattern)
endfunction

function! pikkuwiki#Show(...)
    let pattern = a:0 >= 1 ? a:1 : ''
    let currentfile = expand('%:p')
    let cmd = g:pikkuwiki_cmd . ' show -F pretty -l "'
        \ . l:currentfile . '" -p "'
        \ . l:pattern . '"'
    call pikkuwiki#Search(l:cmd, 'pikkuwiki links', l:pattern)
endfunction
