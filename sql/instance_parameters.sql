
-- ///////////////////////////////////////////////////////////////////
-- /
-- ///////////////////////////////////////////////////////////////////
-- /
-- /$Header: /opt/apps/oracle/local/omx/mon/RCS/ip.sql,v 1.1 2000/03/30 13:42:07 oracle Exp $
-- /
-- /   NAME
-- /     ip.sql
-- /
-- /   REVISION
-- /     $Revision: 1.1 $
-- /
-- /   AUTHOR
-- /     Gert Jan Willems
-- /
-- /   DESCRIPTION
-- /     Instance parameter report
-- /
-- /   RETURNS
-- /
-- /   NOTES
-- /
-- /   MODIFIED   (MM/DD/YY)
-- /    gjwillems  25/03/1999 - Creation
-- /
-- /                Copyright (c) 1999-2000 by Orametrix
-- /
-- /******************************************************************/

-- :: argv: parameter_name (l) or all {sn: ip}

define omx_script = 'ip';
define omx_prog   = '&omx_script..sql'
define omx_title  = 'Instance Parameters'

-- start omxtitle

set lines 250 recsep off verify off pagesize 70

col name         format a40 heading 'Instance Parameter' justify l wrap
col value        format a80 heading 'Value'              justify l
col session_mod  format a25 heading 'modifiable?'
col system_mod   format a28 heading ''
col description  format a70 heading 'Description'

prompt Enter the parameter name or a part of it to search for:
set termout off
define like_parameter_name='&1'
set termout on

select
   name
,  value
,  'is ' || decode (isses_modifiable, 'TRUE', 'session modifiable'
,  'FALSE', 'NOT session modifiable', 'Not modifiable') session_mod
,  'and is ' || decode (issys_modifiable, 'FALSE', 'NOT system modifiable' ,  issys_modifiable || ' modifiable') system_mod
,  description
from
  v$parameter
where name like lower ('%&like_parameter_name%')
order by
  name,
  value
/

