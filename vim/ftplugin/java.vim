" ALE: set up the google-java-format fixer in tanuki
let path = expand("%:p:h")
if path =~# 'botify\|tanuki\|olf'
    let b:ale_java_google_java_format_options = '--skip-sorting-imports'
    let b:ale_fixers = ['google_java_format']
    set sw=2 ts=2 sts=2 et tw=100 colorcolumn=100
endif
