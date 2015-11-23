if !exists('g:pikkuwiki_map_keys')
    let g:pikkuwiki_map_keys = 1
endif

if !exists('g:pikkuwiki_cmd')
    let g:pikkuwiki_cmd = 'pikkuwiki'
endif

command! -nargs=? PWOpen call pikkuwiki#PWOpen(<f-args>)

if g:pikkuwiki_map_keys
    nnoremap <buffer> <Leader>g :PWOpen<CR>
endif

