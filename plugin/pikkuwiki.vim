if exists('g:pikkuwiki_loaded')
    finish
endif
let g:pikkuwiki_loaded = 1

if !exists('g:pikkuwiki_cmd')
    let g:pikkuwiki_cmd = 'pikkuwiki'
endif

if !exists('g:pikkuwiki_search_window_size')
    let g:pikkuwiki_search_window_size = 10
endif

command! -nargs=? PWOpen call pikkuwiki#Open(<f-args>)
command! -nargs=? PWFind call pikkuwiki#Find(<f-args>)

