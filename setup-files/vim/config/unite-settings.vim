" Unite plugin settings

let g:unite_source_history_yank_enable = 1
call unite#filters#matcher_default#use(['matcher_fuzzy'])

" Using ack-grep as recursive command.
"let g:unite_source_rec_async_command =
"\ ['ack', '-f', '--nofilter']

let g:unite_source_rec_async_command =
            \ ['o:\bin\find', '-L']

