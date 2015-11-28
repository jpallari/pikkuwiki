if !$PIKKUWIKI_DIR
    let $PIKKUWIKI_DIR = $HOME . '/pikkuwiki'
endif
au BufRead,BufNewFile $PIKKUWIKI_DIR/*.txt set filetype=pikkuwiki
