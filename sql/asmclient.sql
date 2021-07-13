/*
    File: asmcl.sql
    Date: 2014-09-16
*/

-- :: show contents from v\\\$asm_client

set lines 200

col SOFTWARE_VERSION    format A20
col COMPATIBLE_VERSION  format a20
col instance_name       format a10

select *
from   v$asm_client
/

