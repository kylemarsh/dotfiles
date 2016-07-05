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
"set textwidth=76 "causes code to wrap. Do not want.
set autowrite
set ignorecase
set smartcase
set mouse=a
set mousemodel=popup_setpos
set ttymouse=xterm2
set lz  ""Don't redraw while running macros
set whichwrap+=<,>,h,l  ""Backspace and cursors wrap.
set backspace=indent,eol,start
set scrolloff=5 " no more scrolling from the bottom
set hlsearch
set incsearch
set wildmenu
set wildmode=list:longest,full
runtime! macros/matchit.vim

""" Tab settings.  Normally, <tab> inserts 4 spaces (use crtl-v<tab> to
""" insert a tab).  Also, backspace deletes spaces 4 at a time.
""" set expandtab
set tabstop=4
set softtabstop=4
set smarttab
" Turn off the setting in a makefile
au FileType make setlocal noexpandtab

""" Use latex-suite
set grepprg=grep\ -nH\ $*

""" Suggested settings for python
au BufEnter *.py set ai sw=4 ts=4 tw=76 sta et fo=croql
au BufEnter *.pm,*.pl,*.tp set tw=0

""" Stop windows resizing when you close other windows.
set winfixwidth
set winfixheight

""" Coding Syntax Settings for autoindenting and bracket matching
set cindent
set shiftwidth=4
set showmatch
set showfulltag
syntax on

" make syntax hilighting always right, even in the middle of a big
" javascript inside an html file
" EDIT: I think this causes massive lag for huge files.
"autocmd BufEnter * :syntax sync fromstart

" press gi followed by a character will insert that character at cursor
map gi i<space><esc>r

" Press <Space> to toggle search highlighting in command mode
map <silent> <Space> :silent set hlsearch!<bar>:echo ""<CR>

nnoremap <silent> <F5> :silent setlocal spell! spelllang=en_us<CR>
nnoremap <silent> <F3> :silent set number!<CR>

" term colors
set background=dark
colorscheme kmslate
hi Search ctermbg=124 ctermfg=White
hi IncSearch ctermbg=red ctermfg=White
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

autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
set cursorline

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
nnoremap ; :

" movement makes sense across wrapped lines
nnoremap j gj
nnoremap k gk
imap <up> <c-o>gk
imap <down> <c-o>gj

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

set statusline=%2*%M%*%f:%3l\ (%P)%=\ %1*%{GitBranchInfoString()}%*\ %q[%n%R%Y]\ c:%02c%03V\ 0x%02B
hi User1 term=inverse,bold cterm=inverse,bold ctermfg=blue
hi User2 term=inverse,bold cterm=inverse,bold ctermfg=124
let g:git_branch_status_head_current=1
let g:git_branch_status_text=""

" Syntastic settings
let g:syntastic_python_checkers=['python', 'flake8']
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0


function! SuperTab()
	if (strpart(getline('.'),col('.')-2,1) =~ '^\W\?$')
		return "\<Tab>"
	else
		return "\<C-n>"
	endif
endfunction
imap <Tab> <C-R>=SuperTab()<CR>

" Start Vim-Helper plugin: Fennec
function! RunFennecLine()
    let cur_line = line(".")
    exe "!FENNEC_TEST='" . cur_line . "' prove -v -Ilib -I. -I/home/kylem/ndn/perl %"
endfunction

function! RunFennecLineLess()
    let cur_line = line(".")
    exe "!FENNEC_TEST='" . cur_line . "' prove -v -Ilib -I. -I/home/kylem/ndn/perl % 2>&1 | less"
endfunction

:map <F12> :w<cr>:call RunFennecLineLess()<cr>
:map <F10> :w<cr>:call RunFennecLine()<cr>

:imap <F12> <ESC>:w<cr>:call RunFennecLineLess()<cr>
:imap <F10> <ESC>:w<cr>:call RunFennecLine()<cr>
" End Vim-Helper plugin: Fennec

" Run perltidy on selection with \dt
if filereadable('/ndn/etc/perltidyrc') && filereadable('/ndn/perl/bin/partialtidy.pl')
	:map <Leader>dt :!/ndn/perl/bin/partialtidy.pl /ndn/etc/perltidyrc<CR>
endif

