/*

   file: dbareg.sql

*/

-- :: contents of dba_registry

col comp_id format a15 trunc
col comp_name format a40 trunc
col status format a10
col modified format a20
col version format a10

set linesize 120

select comp_id
, comp_name
, version
, status
, modified
from dba_registry
/

