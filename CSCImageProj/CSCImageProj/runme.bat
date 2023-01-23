if not defined DBLDIR call "%SYNERGYDE32%dbl\dblvars32.bat">nul

dbr WND:script -c dtk -i dtk.wsc -o errlog.txt

dbl test
dblink test WND:tklib.elb

dbr test