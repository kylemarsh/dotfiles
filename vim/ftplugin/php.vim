" ALE settings for PHP
let g:ale_linters = {'php': ['php', 'phpcs']}
let g:ale_fixers = {'php': ['phpcbf']}
"let g:ale_fix_on_save = 1

function! SetCodeSnifferStandard()
    let file_directory = expand('%:p:h')
    if file_directory =~ 'Etsyweb/tests/phpunit'
        let g:ale_php_phpcs_standard = expand('~/development/Etsyweb/tests/standards/phpunit-ruleset.xml')
    else
        let g:ale_php_phpcs_standard = expand('~/development/Etsyweb/tests/standards/stable-ruleset.xml')
    endif
endfunction

:call SetCodeSnifferStandard()

"let g:ale_linters = {'php': ['php', 'phan', 'phpcs']} " the phan daemon is being weird. I'm just gonna skip it.
"let g:ale_php_phan_use_client = 1
"let g:ale_php_phan_executable = expand('~/bin/phan_client_auto')
