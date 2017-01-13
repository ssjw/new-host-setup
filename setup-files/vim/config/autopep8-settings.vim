" vim-autopep8 settings
let g:autopep8_max_line_length=79
let g:autopep8_aggressive=1
autocmd FileType python map <buffer> <F3> :call Autopep8()<CR>

