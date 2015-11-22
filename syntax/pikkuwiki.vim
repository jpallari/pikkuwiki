if exists("b:current_syntax")
    finish
endif

let b:current_syntax = "pikkuwiki"

" Header
syntax match pwHeader "\%^.*$"
highlight link pwHeader Keyword

" Links
syntax match pwLink "\(^\|\s\)\~[_/[:alnum:]]\+"
highlight link pwLink Identifier

