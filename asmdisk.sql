/*
 
     File: asmdisk.sql
   
*/

-- :: contents of v\\\$asm_disk

set lines 200
col path    format a50
col library format a20
col name    format a20
break on name

select g.name 
,      d.disk_number
,      d.path
,      d.os_mb / 1024 as OS_GB
,      d.total_mb / 1024 as asm_assigned_gb
,      d.library 
from   v$asm_disk d
join   v$asm_diskgroup g
on     g.group_number = d.group_number
order  by g.name 
,      d.disk_number;

