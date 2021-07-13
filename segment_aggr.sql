/*

    File: segment_aggr.sql
    Date: Wed Apr 24 08:11:54 CEST 2019

*/

-- :: argv: [owner] show segment aggregation

SET lines 200
SET pagesize 60
SET VERIFY OFF
COL segment_name FORMAT a30
COL tablespace_name FORMAT A20
COL MB FORMAT 9999990D90

PROMPT Enter the segment owner:
SET TERMOUT OFF
DEFINE p_owner='&1';
SET TERMOUT ON

BREAK ON REPORT SKIP 1
COMPUTE SUM OF mb ON REPORT

SELECT segment_type
,      tablespace_name     
,      round( sum( bytes )/1024/1024, 2 ) AS mb
,      count(1) AS segment#
FROM   dba_segments 
WHERE  owner = UPPER( '&p_owner' )
GROUP BY segment_type
,      tablespace_name;


UNDEFINE p_owner
