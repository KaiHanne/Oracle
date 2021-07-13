/*

     File: login_attempts.sql
     Date: Fri Apr 19 11:39:32 CEST 2019
     What: report all attempts to login ORA-01017

      Who: Gert J. Willems
 

     Rev: 0.1

*/


-- :: argv none, create report ORA-01017 failed login attempts

column v1 new_value hostname
column v2 new_value instance
column v3 new_value report_date
column userid format a20
column action_timestamp format a30
column userhost format a30
column osuser format a20

set feedback off
set termout off
select host_name v1
,      instance_name v2
,      to_char(sysdate, 'dd-mm-yyyy hh24:mi') v3
from   v$instance;
set termou on

set lines 126
set trimspool on
set pagesize 70

ttitle left 'FAILED LOGIN ATTEMPT ON &instance@&hostname' -
right 'Report date &report_date' skip 3

btitle skip 3 left 'IenA RAS DBB DBB@gelderland.nl' -
right 'Page:' FORMAT 999 SQL.PNO skip 2

spool &instance._1017audit.txt

select sessionid
,      spare1 as osuser 
,      userid
,      userhost
-- ,      terminal
-- ,      action#
,      returncode
,      ntimestamp# as action_timestamp
from   aud$ 
where  returncode = 1017
and    to_char( ntimestamp#, 'YYYY') = '2019'
/

spool off

set feedback on
