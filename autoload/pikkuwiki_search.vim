function! pikkuwiki_search#PWOpenFromLine()
    call cursor(line('.'), 1)
    let parts = split(getline('.'), ':')
    if len(parts) >= 1
        wincmd p
        execute 'PWOpen ' . l:parts[0]
    endif
endfunction

