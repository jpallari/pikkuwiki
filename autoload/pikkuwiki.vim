function! pikkuwiki#PWOpen(...)
    if a:0 >= 1
        let result = system(g:pikkuwiki_cmd . ' resolve "" ' . a:1)
    else
        let link = expand('<cfile>')
        let currentfile = expand('%:p')
        let result = system(
            \ g:pikkuwiki_cmd . ' resolve '
            \ . l:currentfile . ' ' . l:link)
    endif
    execute 'edit ' . l:result
endfunction

