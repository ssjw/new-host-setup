" Modeline
set modeline
set modelines=5

" Where to find the tags file...
" The last semicolon is the key here. When Vim tries to locate the 'tags'
" file, it first looks at the current directory, then the parent directory,
" then the parent of the parent, and so on. This setting works nicely with
" 'set autochdir', because then Vim's current directory is the same as the
" directory of the file. If you do not like using 'autochdir' but want the
" same upward search, use: 
" Here, the leading "./" tells Vim to use the directory of the current file
" rather than Vim's working directory.
set tags=./tags;

set hidden " The current buffer can be put to the background without writing to disk

set incsearch

set fo-=t " Do no auto-wrap text using textwidth (does not apply to comments)

set nowrap
set textwidth=0		" Don't wrap lines by default
set wildmode=longest,list " At command line, complete longest common string, then list alternatives.

set backspace=indent,eol,start	" more powerful backspacing

set tabstop=4    " Set the default tabstop
set softtabstop=4
set shiftwidth=4 " Set the default shift width for indents
set expandtab   " Make tabs into spaces (set by tabstop)
set smarttab " Smarter tab levels

set autoindent
"set cindent
"set cinoptions=:s,ps,ts,cs
"set cinwords=if,else,while,do,for,switch,case

set showmatch  " Show matching brackets.
set matchtime=5  " Bracket blinking.
set novisualbell  " No blinking
set noerrorbells  " No noise.
set vb t_vb= " disable any beeps or flashes on error
set number " Show line numbers
set clipboard=unnamed " Yank to the system clipboard (the * register) "
set autoread " Check for file changes outside of Vim and reload automatically.

set nolist " Display unprintable characters f12 - switches
set listchars=tab:·\ ,eol:¶,trail:·,extends:»,precedes:« " Unprintable chars mapping

set foldenable " Turn on folding
set foldmethod=marker " Fold on the marker
set foldlevel=100 " Don't autofold anything (but I can still fold manually)
set foldopen=block,hor,mark,percent,quickfix,tag " what movements open folds

set ssop-=options       " what does this do?

