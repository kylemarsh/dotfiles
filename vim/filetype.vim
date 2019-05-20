" my filetype file
if exists("did_load_filetypes")
	finish
endif
augroup filetypedetect
	au! BufNewFile,BufRead *.mako,*.mak	setfiletype mako
	au! BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
	au! BufNewFile,BufRead *.applescript setlocal filetype=applescript
augroup END

