" Statusline should always be present
set laststatus=2

" For vim-airline, display all buffers when only one tab is open
let g:airline#extensions#tabline#enabled = 1
" tell vim-airline to use the powerline font glyphs.
let g:airline_powerline_fonts = 1
set encoding=utf-8
" Disable checking for extensions to see if this speeds up startup. (Nope)
let g:airline#extensions#disable_rtp_load = 1

