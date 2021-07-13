/*

   File: blocker.sql
   Date: Tue Nov  1 07:18:22 CET 2016

*/

-- :: argv: none, show blocker an waiter for objects

set pages 1000
set lines 159
set heading off
column w_proc format a50 tru
column instance format a20 tru
column inst format a28 tru
column wait_event format a50 tru
column p1 format a16 tru
column p2 format a16 tru
column p3 format a15 tru
column Seconds format a50 tru
column sincelw format a50 tru
column blocker_proc format a50 tru
column fblocker_proc format a50 tru
column waiters format a50 tru
column chain_signature format a100 wra
column blocker_chain format a100 wra
 
SELECT * 
FROM ( SELECT 'Current Process: '||osid W_PROC, 'SID '||i.instance_name INSTANCE, 
       'INST #: '||instance INST,'Blocking Process: '||
          decode( blocker_osid,null,'<none>',blocker_osid )|| 
       ' from Instance '||blocker_instance BLOCKER_PROC,
       'Number of waiters: '||num_waiters waiters,
       'Final Blocking Process: '||
          decode( p.spid,null,'<none>', p.spid )||
       ' from Instance '||s.final_blocking_instance FBLOCKER_PROC, 
       'Program: '||p.program image,
       'Wait Event: ' ||wait_event_text wait_event, 'P1: '||wc.p1 p1, 'P2: '||wc.p2 p2, 'P3: '||wc.p3 p3,
       'Seconds in Wait: '||in_wait_secs Seconds, 'Seconds Since Last Wait: '||time_since_last_wait_secs sincelw,
       'Wait Chain: '||chain_id ||': '||chain_signature chain_signature,'Blocking Wait Chain: '||
          decode( blocker_chain_id,null, '<none>',blocker_chain_id ) blocker_chain
FROM v$wait_chains wc,
     gv$session s,
     gv$session bs,
     gv$instance i,
     gv$process p
WHERE wc.instance = i.instance_number (+)
AND   (wc.instance = s.inst_id (+) and wc.sid = s.sid (+)
AND   wc.sess_serial# = s.serial# (+))
AND   (s.inst_id = bs.inst_id (+) and s.final_blocking_session = bs.sid (+))
AND   (bs.inst_id = p.inst_id (+) and bs.paddr = p.addr (+))
AND   ( num_waiters > 0
OR    ( blocker_osid IS NOT NULL
AND   in_wait_secs > 10 ) )
ORDER BY chain_id,
         num_waiters DESC)
WHERE ROWNUM < 101;

set pagesize 70 head on
col SESS     format a12
col action  format a30 trunc
-- set lines 132

SELECT DECODE(request,0,'Holder: ','Waiter: ')||sid as sess,
       id1, 
       id2, 
       lmode, 
       request, 
       type
FROM   V$LOCK
WHERE  (id1, id2, type) IN
     ( SELECT id1, 
              id2, 
              type 
       FROM   V$LOCK 
       WHERE  request>0 )
ORDER  BY id1, 
       request;

select distinct holding_session 
from   dba_waiters 
where  holding_session not in 
     ( select waiting_session 
       from   dba_waiters );

select s.sid, 
       s.serial#, 
       s.action, 
       s.module, 
       s.status, 
       s.last_call_et,
       s.logon_time
from   v$session s
where  s.sid in 
     ( select sid 
       from   v$lock 
       where block >0 )
order  by sid;


-- end of blocker.sql
