" Vim syntax file
" Language:	DH template - assumes HTML content

let main_syntax = 'html'
runtime! syntax/html.vim

unlet b:current_syntax
let b:current_syntax = "dhtmpl"

syn match  dhtmplSection /^-{-{.*$/ containedin=ALL
syn match  dhtmplTag /--\w\+--/ containedin=ALL
syn match  dhtmplInclude /\[\[[A-Za-z0-9_\/\.]\+:\?[A-Za-z0-9_=, ]*\]\]/ containedin=ALL
syn match  dhtmplInclude /==[A-Za-z0-9_\/\.]\+==/ containedin=ALL
syn region dhtmplBlock matchgroup=dhtmplBlockBraces start=/{{/ end=/}}/ containedin=ALL

hi link dhtmplSection       Identifier
hi link dhtmplTag           Macro
hi link dhtmplInclude       Include
hi link dhtmplBlock         PreCondit
hi link dhtmplBlockBraces   PreCondit
