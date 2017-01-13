" If you want each buffer to have its OWN Result buffer, you can define: >
"        let g:dbext_default_use_sep_result_buffer = 1 (default=0)
let g:dbext_default_display_cmd_line = 1

" Delete temp files (created in a subdirectory of $TEMP)
let g:dbext_default_delete_temp_file = 1

" Turn on debugging output for dbext
let g:dbext_dbi_debug = 0

let g:dbext_default_DBI_split_on_pattern = "\n".'\s*\<go\>\s*'."\n".'\|'."\n".'\s*\/\s*'."\n"

" FIXME: use autocommand to change for ft=plsql, and then
" dbext_default_DBI_cmd_terminator can be left as the default ;
"let g:dbext_default_DBI_cmd_terminator = "/"

" Hack for now... integrate this into the dbext variable system.
"let g:dbext_default_DBI_cmd_terminator_pattern = '^\s*\zs\/\s*$'

let g:dbext_default_query_statements = "select,update,delete,insert,create,grant,alter,call,exec,merge,with,declare"

" Don't strip out the INTO keyword.  This can be set with DBSetOption
" strip_into = 1
" You'd want to turn this on if you want to run a SQL statement inside of a
" PL/SQL procedure definition, for instance, and want to see what the query
" returns to the variables.
" This can be added to a profile as well:
" let g:dbext_default_profile_IDDDEV = 'type=DBI:user=appa088:passwd=somepass:driver=Oracle:conn_parms=IDDDEV.world:driver_parms=AutoCommit=0:strip_into=0'
"let g:dbext_default_strip_into = 0

" New variables introduced:
" - DBI_sqlscript_cmd_terminator_Oracle
" - sqlscript_mode
"
" JHW: Changes to implement
"
" FIXME: DBI_split_on_pattern: different for Oracle?
"
" Set sqlscript_mode function that sets strip_into to 0 (and back to 1).
"  (and strip_at?)
"  OR
" Also if sqlscript_mode = 1 then set b:dbext_strip_into = 0
"
" DBI_sqlscript_cmd_terminator_Oracle instead of cmd_terminator_pattern.  Make
" the pattern in the code, just like is done with cmd_terminator.
"
" sqlscript_cmd_terminator is '/' for Oracle.
" 
" - This mostly affects the dbext#DB_getQueryUnderCursor() function in
"   autoload/dbext.vim
"
" DBMS output...
" In DBD::Oracle use
"   @dbms_output = $dbh->func( 'dbms_output_get' );
" to get all of the output currently in the DBMS_OUTPUT buffer.
" Then write it into the result buffer.
" Calling dbms_output_get in a scalar context gets just one line.  In an array
" context it gets all lines.
"
