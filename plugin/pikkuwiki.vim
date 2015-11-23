if exists('g:pikkuwiki_loaded')
    finish
endif
let g:pikkuwiki_loaded = 1

if !exists('g:pikkuwiki_cmd')
    let g:pikkuwiki_cmd = 'pikkuwiki'
endif

command! -nargs=? PWOpen call pikkuwiki#PWOpen(<f-args>)

