set modelines=0

runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

""" Basic operation settings
set nocompatible
set history=1000
filetype on
filetype plugin on
filetype indent on
set clipboard+=unnamed
set showmode
set ruler
set laststatus=2
set number
set autowrite
set ignorecase
set smartcase
let mapleader = ","
set mouse=a
set mousemodel=popup_setpos
set ttymouse=xterm2
set lz  ""Don't redraw while running macros
set whichwrap+=<,>,h,l  ""Backspace and cursors wrap.
set backspace=indent,eol,start
set scrolloff=5 " no more scrolling from the bottom
set hlsearch
set incsearch

" Tweak how file completion works
set wildmenu
set wildignorecase
set wildmode=list:longest,full

runtime! macros/matchit.vim

" Line  width settings
"set textwidth=76 "causes code to wrap. Do not want.
if exists('+colorcolumn')
    set colorcolumn=80  " if vim is new enough, highlight a column
else  " otherwise hilight text that extends past 85 chars
    au BufWinEnter * let w:m2=matchadd('Folded', '\%>85v.\+', -1)
endif

""" Tab settings.  Normally, <tab> inserts 4 spaces (use crtl-v<tab> to
""" insert a tab).  Also, backspace deletes spaces 4 at a time.
set expandtab
set tabstop=4
set softtabstop=4
set smarttab
" Turn off the setting in a makefile
au FileType make setlocal noexpandtab

""" Use latex-suite
set grepprg=grep\ -nH\ $*

""" Language-specific settings
au BufEnter *.py set ai sw=4 ts=4 tw=76 sta et fo=croql
au BufEnter *.pm,*.pl,*.tp set tw=0
"au BufEnter *.js set sw=2 ts=2 et tw=0

""" Stop windows resizing when you close other windows.
set winfixwidth
set winfixheight

""" Coding Syntax Settings for autoindenting and bracket matching
set autoindent
set smartindent
"set cindent
set shiftwidth=4
set showmatch
set showfulltag
syntax on

" no magic outdent for comments
inoremap # X<C-H>#|
" no shift magic on comments
nnoremap <silent> >> :call ShiftLine()<cr>|
function! ShiftLine()
	set nosmartindent
	normal! >>
	set smartindent
endfunction

" make syntax hilighting always right, even in the middle of a big
" javascript inside an html file
" EDIT: I think this causes massive lag for huge files.
"autocmd BufEnter * :syntax sync fromstart

" Press <Space> to toggle search highlighting in command mode
map <silent> <Space> :silent set hlsearch!<bar>:echo ""<CR>

nnoremap <silent> <F5> :silent setlocal spell! spelllang=en_us<CR>
nnoremap <silent> <F3> :silent set number!<CR>

" term colors
set background=dark
colorscheme kmslate
hi Search ctermbg=124 ctermfg=White
hi IncSearch ctermbg=red ctermfg=White
hi ColorColumn ctermbg=darkgray
hi TRACK_PERL_VAR_LOCKED term=standout ctermfg=14 ctermbg=242 guifg=Cyan guibg=Grey
"hi def link TRACK_PERL_VAR_LOCKED SignColumn

" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
	set t_Co=16
endif

" set up hilighting for trailing whitespace
hi ExtraWhitespace ctermbg=magenta guibg=magenta
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=magenta guibg=magenta
match ExtraWhitespace /\[^\t]\zs\t\+/
match ExtraWhitespace /\s\+$\| \+\ze\t/

"autocmd WinEnter * setlocal cursorline
"autocmd WinLeave * setlocal nocursorline
"set cursorline

if &listchars ==# 'eol:$' " make whitespace visualization nicer
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif


autocmd FileType gitcommit DiffGitCached | wincmd L | wincmd p | vertical resize 83
augroup markdown
	au!
	au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup end

" quicker window navigation
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" quicker buffer navigation
nnoremap <C-n> :next<CR>
nnoremap <C-p> :prev<CR>

" get the commandline more quickly
" note...this aliases ; which turns out to be really handy!
"nnoremap ; :

" movement makes sense across wrapped lines
nnoremap j gj
nnoremap k gk
inoremap <up> <c-o>gk
inoremap <down> <c-o>gj

if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j " Delete comment character when joining commented lines
endif

" make F1 just another esc key
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" nuke shifted up/down arrow keys in insert mode
inoremap <S-Up> <nop>
inoremap <S-Down> <nop>

" prevent showmarks plugin from turning on automatically
let g:showmarks_enable=0

set statusline=%2*%M%*%f:%3l\ (%P)%=[%n%R%Y]\ c:%02c%03V\ 0x%02B
hi User1 term=inverse,bold cterm=inverse,bold ctermfg=blue
hi User2 term=inverse,bold cterm=inverse,bold ctermfg=124

""" ALE settings
let g:ale_echo_msg_format = '[%linter%] %code: %%s [%severity%]'
let g:ale_linters = {
\ 'php' : ['langserver', 'phan', 'php', 'phpmd', 'phpstan', 'psalm']
\}
noremap <Leader>t :ALEFix<CR>
"""


let g:jsx_ext_required = 0 " allow jsx in normal JS files

function! SuperTab()
	if (strpart(getline('.'),col('.')-2,1) =~ '^\W\?$')
		return "\<Tab>"
	else
		return "\<C-n>"
	endif
endfunction
imap <Tab> <C-R>=SuperTab()<CR>


""" PERL Stuff
" Run perltidy on selection with \dt
"if filereadable('/home/kylem/ndn/etc/perltidyrc') && filereadable('/home/kylem/ndn/perl/bin/partialtidy.pl')
	":map <Leader>t :!/home/kylem/ndn/perl/bin/partialtidy.pl /home/kylem/ndn/etc/perltidyrc<CR>
"endif


" update file searching so `gf` can properly find etsy php class definitions
if !empty(glob('~/development/Etsyweb/'))
    set path+=~/development/Etsyweb/phplib,
            \~/development/Etsyweb/phplib/EtsyModel,
            \~/development/Etsyweb/phplib,
            \~/development/Etsyweb/templates,
            \~/development/Etsyweb/htdocs/assets/js,
            \~/development/Etsyweb/htdocs/assets/css,
            \~/development/Etsyweb/phplib/Api,
            \~/development/Etsyweb/phplib/Api/Resource
    set includeexpr=substitute(v:fname,'_','/','g')
    set suffixesadd+=.php
	set suffixesadd+=.tpl
	set suffixesadd+=.js
	set suffixesadd+=.jsx
	set suffixesadd+=.mustache
endif

""" GO Stuff
" see also vim/ftplugin/go.vim
let g:go_fmt_command = "goimports"

" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
	let l:file = expand('%')
	if l:file =~# '^\f\+_test\.go$'
		call go#test#Test(0, 1)
	elseif l:file =~# '^\f\+\.go$'
		call go#cmd#Build(0)
	endif
endfunction


""""""""""""
nnoremap <Leader>f :bnext<CR>
nnoremap <Leader>d :bprev<CR>

" Running tests
nnoremap <Leader>r :!run_test %<CR>
nnoremap <Leader>c :!run_test -ng %<CR>

" Config files
command ConD :e phplib/EtsyConfig/development.php
command ConP :e phplib/EtsyConfig/production.php

" Creating Gists
"command -range=% -nargs=0 GistBlob :<line1>,<line2>w !cat | gist -t %:e "works when the file has an extension; fails otherwise
command -range=% -nargs=0 GistBlob :<line1>,<line2>w !cat | gist
command GistCurrent :w !cat % | gist -t diff
command GistDiffCurrent :w !git diff % | gist -t diff
command GistDiffAll :w !git diff | gist -t diff
command GistStaged :w !git diff --staged | gist -t diff

vnoremap <Leader>ss :GistBlob<cr>
nnoremap <Leader>sf :GistCurrent<cr>
nnoremap <Leader>sd :GistDiffCurrent<cr>
nnoremap <Leader>sa :GistDiffAll<cr>
nnoremap <Leader>st :GistStaged<cr>

" Alignment shortcuts
nnoremap <Leader>a= :Tabularize /=<cr>
vnoremap <Leader>a= :Tabularize /=<cr>
nnoremap <Leader>a> :Tabularize /=><cr>
vnoremap <Leader>a> :Tabularize /=><cr>
nnoremap <Leader>a, :Tabularize /,\zs<cr>
vnoremap <Leader>a, :Tabularize /,\zs<cr>
