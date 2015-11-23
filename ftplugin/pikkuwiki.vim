if exists("g:pikkuwiki_plugin_loaded")
    finish
endif
let g:pikkuwiki_plugin_loaded = 1

function! s:PWOpen(...)
    let link = a:0 >= 1 ? a:1 : expand('<cfile>')
    let currentfile = expand('%:p')
    let result = system('pikkuwiki resolve ' . l:currentfile . ' ' . l:link)
    execute 'edit ' . l:result
endfunction

command! -nargs=? PWOpen call s:PWOpen(<f-args>)

nnoremap <buffer> <Leader>g :PWOpen<CR>
