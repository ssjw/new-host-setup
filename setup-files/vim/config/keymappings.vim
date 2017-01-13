" Easier moving between windows
nnoremap <C-l> <C-W>l<CR>
nnoremap <C-k> <C-W>k<CR>
nnoremap <C-h> <C-W>h<CR>
nnoremap <C-j> <C-W>j<CR>

" Use <leader>l to clear the highlighting of :set hlsearch.
if maparg('<leader>l', 'n') ==# ''
  nnoremap <silent> <leader>l :nohlsearch<CR><leader>l
endif

" make the cursor stay in the middle of the screen.
nnoremap <Leader>zz :let &scrolloff=999-&scrolloff<CR> 

" Tabs 
nnoremap <silent> <LocalLeader>[ :tabprev<CR>
nnoremap <silent> <LocalLeader>] :tabnext<CR>

" Buffers
nnoremap <silent> <LocalLeader>- :bd<CR>

" Tabs
nnoremap <Tab> :tabnext<CR>
nnoremap <S-Tab> :tabprevious<CR>

" List buffers in a window, and allow user to choose a buffer to switch
" to by buffer number.
" Using bufferexplorer plugin
"nnoremap <F5> :buffers<CR>:buffer<Space>

" Map to close a buffer but keep the window and switch to an alternate
" buffer.
nmap <C-W>! <Plug>Kwbd

" Open the filename under the cursor.
nnoremap gf :e <cfile><CR>

" Split line(opposite to S-J joining line)
nnoremap <silent> <leader>j gEa<CR><ESC>ew 

" show/Hide hidden Chars
map <silent> <F12> :set invlist<CR>     

" Edit vimrc file.
nnoremap <leader>ev :split $MYVIMRC<cr>
nnoremap <leader>vev :vsplit $MYVIMRC<cr>
" Source vimrc file
"nnoremap <leader>sv :source $MYVIMRC<cr>

" Copy the full path of the file being edited to the system clipboard.
nnoremap <leader>cp :let @* = expand("%:p")<cr>

" Make the current file's directory the current directory
nnoremap <leader>cd :cd %:p:h<cr>

" Toggle NERDTree
map <C-n> :NERDTreeToggle<cr>

" Tagbar
nnoremap <leader>t :TagbarToggle<cr>

" Unite
" split window
" Unite proved to be far too slow and unresponsive.
"nnoremap <leader>ra :<C-u>Unite -buffer-name=files -start-insert file_rec/async:!<cr>
"nnoremap <leader>rd :<C-u>UniteWithInputDirectory -buffer-name=files -start-insert file_rec/async:!<cr>
"nnoremap <leader>r :<C-u>Unite -buffer-name=files -start-insert file_rec<cr>
"nnoremap <leader>f :<C-u>Unite -buffer-name=files -start-insert file<cr>
"nnoremap <leader>m :<C-u>Unite -buffer-name=mru -start-insert file_mru<cr>
"nnoremap <leader>o :<C-u>Unite -buffer-name=outline -start-insert outline<cr>
"nnoremap <leader>y :<C-u>Unite -buffer-name=yank history/yank<cr>
"nnoremap <leader>b :<C-u>Unite -buffer-name=buffer buffer<cr>

"nnoremap <leader>ra :<C-u>Unite -no-split -buffer-name=files   -start-insert file_rec/async:!<cr>
"nnoremap <leader>r :<C-u>Unite -no-split -buffer-name=files   -start-insert file_rec<cr>
"nnoremap <leader>f :<C-u>Unite -no-split -buffer-name=files   -start-insert file<cr>
"nnoremap <leader>m :<C-u>Unite -no-split -buffer-name=mru     -start-insert file_mru<cr>
"nnoremap <leader>o :<C-u>Unite -no-split -buffer-name=outline -start-insert outline<cr>
"nnoremap <leader>y :<C-u>Unite -no-split -buffer-name=yank    history/yank<cr>
"nnoremap <leader>b :<C-u>Unite -no-split -buffer-name=buffer  buffer<cr>

" CtrlP
nnoremap <leader>b :CtrlPBuffer<cr>
nnoremap <leader>p :CtrlP<cr>
nnoremap <leader>m :CtrlPMRU<cr>
" Allow entry of starting directory
nnoremap <leader>d :CtrlP 

" Toggle startofline setting.  startofline controls whether the cursor is
" sent to the beginning of a line during cursor movements (Ctrl-B for
" instance.
nnoremap gs :set sol!<cr>

