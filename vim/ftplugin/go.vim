nmap <leader>gc <PLUG>(go-coverage-toggle)<CR>
nmap <leader>gb :<C-u>call <SID>build_go_files()<CR>
nmap <leader>gt <Plug>(go-test)
nmap <leader>gl <Plug>(go-metalinter)
nmap <leader>gi <Plug>(go-info)

command! -bang A call go#alternate#Switch(<bang>0, 'edit')
command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
command! -bang AS call go#alternate#Switch(<bang>0, 'split')
command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')
