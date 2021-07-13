/*

   File : patchlevel.sql
   Date : Thu Apr 26 15:05:37 CEST 2018

   History:
   Date
   ------------	---- -------------- --------------------------------------------
   26-04-2018   0.1  gjwillems      created
   26-04-2018   0.2  gjwillems      History added
   -----------------------------------------------------------------------------
*/

define script='patchlevel';

-- :: argv none, show installed patches, CPU, PUS etc.

col action_time   format a30
col comments      format a50
col namespace     format a20
set lines 300

select version latest_patch_level
from   sys.registry$history rh
where  rh.action_time =
     ( select max(action_time)
       from sys.registry$history )
/

prompt
prompt **** PATCH HISTORY ****

select * 
from   sys.registry$history
order by action_time;

prompt

