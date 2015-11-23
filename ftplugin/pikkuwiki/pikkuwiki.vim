if !exists('g:pikkuwiki_map_keys')
    let g:pikkuwiki_map_keys = 1
endif

if g:pikkuwiki_map_keys
    nnoremap <buffer> <Leader>g :PWOpen<CR>
endif

command! -buffer -nargs=? PWShow call pikkuwiki#Show(<f-args>)
