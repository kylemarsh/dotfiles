" recommended to put this at the top of every color scheme
hi clear
if exists("syntax_on")
    syntax reset
endif

" Load the 'base' color scheme to be modified
runtime bundle/gruvbox/colors/gruvbox.vim

hi clear Folded
hi link Folded Comment
