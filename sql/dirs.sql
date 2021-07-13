col directory_path format a100
col directory_name format a30
set lines 200
set trimspool on
set pagesize 60

-- :: list all Oracle directories

select directory_name
,      directory_path
from   dba_directories
order  by 1;
