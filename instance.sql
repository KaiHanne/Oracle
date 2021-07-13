/*
  
   File: i.sql
   Date: Wed Apr 23 09:55:18 CEST 2009
    Who: Gert J. Willems
   What: Display info on:
         - database 
         - instance
         - sessions
         - offline or otherwise erroneous files

History
date       author       Rev  What
---------- ------------ ---- -------------------------------------------------------
2009-04-23 gjwillems    1.0  created
2010...... gjwillems    1.1  Data guard info added
2013-10-10 gjwillems    1.2  server info added
2014-04-23 gjwillems    2.3  info on erroneous files added

====================================================================================
           (c) Copyright 2009-2014 ITassist / SIDN / Trivento
====================================================================================
*/

-- :: show instance information

prompt
@version_banner

col nl fold_after 1
set pagesize 0
set lines 200
set trimspool on

select
   'Host name            : ' || a.host_name                                        nl
,  'DBID                 : ' || b.dbid                                             nl
,  'DB Creation time     : ' || to_char(b.created, 'dd-mm-yyyy hh24:mi:ss')        nl
,  'Version              : ' || a.version                                          nl
,  'Version time         : ' || to_char(b.version_time, 'dd-mm-yyyy hh24:mi:ss')   nl
,  'Resetlogs time       : ' || to_char(b.resetlogs_time, 'dd-mm-yyyy hh24:mi:ss') nl
,  'Open resetlogs       : ' || b.open_resetlogs                                   nl
,  'Last open Incarnation: ' || b.last_open_incarnation#                           nl
,  'Instance name        : ' || a.instance_name                                    nl
,  'DB name              : ' || b.name                                             nl
,  'DB unique name       : ' || b.db_unique_name                                   nl
,  'Service names        : ' || c.value                                            nl
,  'Startup time         : ' || to_char( a.startup_time, 'dd-mm-yyyy hh24:mi')     nl
,  'Status / DB status   : ' || a.status ||' / '||a.database_status                nl
,  'Open mode            : ' || b.open_mode                                        nl
,  'Logins               : ' || a.logins                                           nl
,  'Parallel             : ' || a.parallel                                         nl
,  'Archiver             : ' || a.archiver                                         nl
,  'Log mode             : ' || b.log_mode                                         nl
,  'Platform             : ' || b.platform_name                                    nl
,  'Archivelog change#   : ' || b.archivelog_change#                               nl
,  'Current SCN          : ' || b.current_scn                                      nl
,  'Current log Sequence : ' || d.sequence#                                        nl
,  'Flashback on         : ' || b.flashback_on                                     nl
,  'Force logging        : ' || b.force_logging                                    nl
--,  'NLS Characterset     : ' || e.property_value                                   nl
,  ''                                                                              nl
,  'DATA GUARD INFO      : -------------------------------------------------------'nl
,  'DataGuard broker     : ' || b.dataguard_broker || decode( 
                                dataguard_broker, 'ENABLED', ' (Started)'
                                                , 'DISABLED', ' (Down)')           nl
,  'Remote archive       : ' || b.remote_archive                                   nl
,  'Guard status         : ' || b.guard_status                                     nl
,  'Database Role        : ' || b.database_role                                    nl
,  'Switchover status    : ' || b.switchover_status                                nl
,  'Protection mode      : ' || b.protection_mode                                  nl
,  'Protection level     : ' || b.protection_level                                 nl
,  'FSF status           : ' || b.fs_failover_status                               nl
,  'FSF current target   : ' || nvl(b.fs_failover_current_target, 'n.v.t.')        nl
,  'FSF threshold        : ' || b.fs_failover_threshold                            nl
,  'FSF observer present : ' || nvl(b.fs_failover_observer_present, 'n.v.t.')      nl
,  'FSF observer host    : ' || nvl(b.fs_failover_observer_host, 'n.v.t.')         nl
from
   v$instance a
,  v$database b
,  v$parameter c
,  v$log d
--,  database_properties e
where c.name          = 'service_names'
  and d.status     like '%CURRENT'
  --and e.property_name = 'NLS_CHARACTERSET'
/

@sqlpatch19

@file_status

set feedback on

/* ----- end of i.sql ----------------------------------------------------------- */

