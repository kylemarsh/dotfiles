set sw=2 ts=2 sts=2 noet

" ALE settings for javascript
let g:ale_linters = {
\   'javascript': ['eslint'],
\}
let g:ale_fixers = {
\   'javascript': ['prettier', 'eslint'],
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\}
let g:ale_javascript_eslint_executable='npx eslint'

let g:jsx_ext_required = 0
let g:ale_linters_explicit = 1
let g:ale_fix_on_save = 1

