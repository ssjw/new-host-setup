" CtrlP options
let g:ctrlp_clear_cache_on_exit = 0
" CtrlP Extensions
let g:ctrlp_extensions = ['buffertag']
						", 'quickfix', 'dir', 'rtscript',
						" \ 'undo', 'line', 'changes', 'mixed', 'bookmarkdir']
" Change default file listing command.  Hopefully faster.
let g:ctrlp_user_command = 'dir %s /-n /b /s /a-d'  " Windows
" Tell ctrlp to set the language for filetype=plsql
let g:ctrlp_buftag_types = {
		\ 'plsql'	: '--language-force=SQL'
	\ }

