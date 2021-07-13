/* ================================================================================
--
--   File: invalids.sql
--   Date: Tue Oct 24 08:16:56 CEST 2017
--    Who: Gert J. Willems
--   What: show umber of invalid objects per owner, type 
--
-- History
-- Date       Author       Rev What
-- ---------- ------------ --- ----------------------------------------------------
-- 20171024   gjwillems    1.0 created
--
-- ============================================================================= */

set pagesize 80 lines 200
set trimspool on
set feedback off
set serveroutput on

col owner       format a20
col object_type format a30

-- :: list invalid objects: owner type count 

prompt +----------------------------------------------------------------------------+
prompt Number of invalid objects found on a per owner basis
prompt +----------------------------------------------------------------------------+

select owner
,      object_type
,      count(1) as invalid_objects
from   dba_objects
where  status = 'INVALID'
group  by owner
,      object_type
order  by owner
,      object_type
;

-- end of invalids
