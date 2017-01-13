" Run Toad's PL/SQL formatter on the file being edited in the current buffer.
command! Plsqlfmt %!plsql-formatter

" Run Toad's Script Quest Runner using the file being edited in the current
" buffer.
command! Runsql !start qsr.bat -c ^"/@idddev.world^" -f ^"%:p^"

" Run SQL*Plus using the file being edited in the current
" buffer.
command! Runsqlplus !start cmd /c (
    \^"C:\Oracle\product\11.2.0\client_1\bin\sqlplus.exe^"
    \ ^"/@idddev.world^"
    \ @^"%:p^")

