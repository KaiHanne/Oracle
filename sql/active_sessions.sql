Rem /*****************************************************************
Rem
Rem $Header: /opt/apps/oracle/local/omx/mon/RCS/ses.sql,v 1.1 2000/03/30 13:42:15 oracle Exp $
Rem
Rem  Copyright (c) 1999 by Pragma Computing Servies
Rem    NAME
Rem      session.sql
Rem
Rem    DESCRIPTION
Rem      Show session information
Rem
Rem    RETURNS
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     gjwillems  25/03/1999 - Creation
Rem     gjwillems  26/10/1999 - OS pid, module added
Rem
Rem ******************************************************************/

-- :: argv: [user] [application] (l) {sn: as}

def omx_prog   = 'session.sql'
def omx_title  = 'Session Information'
def omx_comment1 = 'Information about active and inactive sessions'
def omx_comment2 = ''

column sid                              format 9999    heading 'SID'           justify c
column spid                             format A10     heading 'OSpid (DB)'    justify c
column loggedon                         format A16     heading 'logon time'    justify c
column status                           format A1      heading 'S'             justify c
column username                         format A15     heading 'schema'        justify c
column process                          format A12     heading 'process-id|(midtier)'  justify c
column program                          format a15     heading 'program'       justify c trunc
column module                           format a30     heading 'module'        justify c trunc
column latchspin                        format 999990  heading 'latch|spin'
column latchwait                        format 999990  heading 'latch|wait'
column pga_used_mem                     format 999G999G990  heading 'KBytes used'        justify l
column pga_alloc_mem                    format 999990  heading 'KBytes alloc'       justify l
column pga_freeable_mem                 format 999990  heading 'KBytes reloc'       justify l
column pga_max_mem                      format 999990  heading 'KBytes max'         justify l
column schemaname                       format a17
column machine                          format a10     heading 'machine' trunc
column osuser                           format a18     heading 'OS user' trunc

set termout on
set lines 200
set pages 60
set trimspool on
set recsep off

set verify off

col pv_uname  new_value uname
col pv_module new_value module

set termout on
prompt Enter the name of the user (=like, e.g. JAN) :
set termout off
define p1='&1';
set termout on
prompt Enter the application name (=like, e.g. SDE) :
set termout off
define p2='&2';
select nvl ( '&p1', '%' ) pv_uname
,      nvl ( '&p2', '%' ) pv_module
from   dual;
set termout on

select nvl( a.osuser, 'N.A.' ) || decode (a.status,
            'ACTIVE',' (a)',
            'KILLED',' (k)',
            'SNIPED',' (s)',
            'INACTIVE', '',
            '')                                           as osuser,
       a.sid,
       a.process,
       upper( p.spid )                                    as spid,
       nvl( a.username, b.name )                          as schemaname,
       decode( a.program,
               'ORACLE.EXE', b.description,
               'ifweb90.exe', 'Web Forms',
               'javaw.exe', 'Reports',
               a.program)                                 as program,
       decode( a.module,
               'PL/SQL Developer', replace( a.action, ' ', '' ),
               replace(a.module, '_',' '))                as module,
       substr( a.machine, 1, instr( machine, '.' )-1 )    as machine,
       p.pga_used_mem/1024                                as pga_used_mem,
--       p.pga_alloc_mem/1024                             as pga_alloc_mem,
--       p.pga_freeable_mem/1024                          as pga_freeable_mem,
--       p.pga_max_mem/1024                               as pga_max_mem,
       to_char( a.logon_time, 'dd-mm-yyyy hh24:mi' )      as loggedon
from   v$session a,
       v$bgprocess b,
       v$process   p
where  b.paddr (+) = a.paddr
and    p.addr      = a.paddr
and    a.username like upper( '%&uname%' )
and    ( upper( a.module )   like upper( '&module%' )
                 or ('&module' is null
          and a.module is null ))
and    a.status = 'ACTIVE'
/


