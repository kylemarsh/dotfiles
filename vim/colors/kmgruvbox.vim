" recommended to put this at the top of every color scheme
hi clear
if exists("syntax_on")
    syntax reset
endif

" Load the 'base' color scheme to be modified
runtime bundle/gruvbox/colors/gruvbox.vim

" Override the name
let g:colors_name = "kmgruvbox"

" Clear the colors for any items that you don't like
" hi clear Normal
" hi clear Visual
" TODO
" FIXME
hi clear Todo

" Set up your new, improved colors
"hi Search guibg=#9d0006 ctermbg=88 guifg=White ctermfg=White gui=italic cterm=bold
"hi Error guibg=#9d0006 ctermbg=88 guifg=White ctermfg=White gui=italic cterm=bold
"hi Todo guibg=#9d0006 ctermbg=88 guifg=White ctermfg=White gui=italic cterm=bold
