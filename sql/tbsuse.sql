/*
      File: tbsuse.sql
      Date: Thu Apr  5 12:46:49 CEST 2012
      What: get tablespace space usage information
            based on SGA structures (V_$ views)

       Who: Gert J. Willems

  Revision: 1.1b

      Copyright (c) 2012 Trivento / SIDN
*/

-- :: show graphical tablespace usage

COMPUTE SUM OF mb_maxsize mb_alloc mb_fsize mb_free ON REPORT
BREAK ON REPORT
DEFINE scriptinfo='tbsuse.sql, Revision 1.1b, Tue Mar 10 14:37:30 CET 2015'
DEFINE HR = "==================== ================ ============== =============== =============== ===== ===================================================================================================="

SET FEEDBACK OFF
SET UNDERLINE '-'
SET LINES    300
SET PAGESIZE  80
SET TRIMSPOOL ON
SET VERIFY OFF

COL mb_alloc     FORMAT 999G999G990D90 HEADING 'MB ALLOC'
COL mb_maxsize   FORMAT 999G999G990D90 HEADING 'MB MAXSIZE'
COL mb_fsize     FORMAT 999G999G990D90 HEADING 'MB FSIZE'
COL mb_free      FORMAT 999G999G990D90 HEADING 'MB FREE'
COL NAME         FORMAT A20
COL pct_used     FORMAT 9990 HEADING 'PCT|USED'
COL pct_used_bar FORMAT a100 HEADING 'PERCENTAGE USED BAR                                                                                1|         1         2         3         4         5         6         7         8         9         0|1   .    0    .    0    .    0    .    0    .    0    .    0    .    0    .    0    .    0    .    0'


PROMPT &scriptinfo
PROMPT &HR
WITH filename AS
     ( SELECT ts#, 
              rfile#, 
              block_size bsize,
              name 
       FROM v$datafile
       UNION
       SELECT ts#, 
              rfile#, 
              block_size,
              name 
       FROM v$tempfile ),
       fileinfo AS
     ( SELECT tablespace_id tbs_id,
              rfno,
              allocated_space  allocated,
              file_size        fsize,
              file_maxsize     maxsize
       FROM   v$filespace_usage ),
     tbsinfo AS
     ( SELECT ts#,
              name
       FROM   v$tablespace ),
     tsfree as
     ( SELECT tablespace_name,
              round( sum( bytes ) / 1024/1024, 0) as mbfree
       from   dba_free_space 
       group  by tablespace_name )
SELECT ti.name,
       tsf.mbfree            as mb_free,
       SUM( ags.mb_alloc )   as mb_alloc,
       SUM( ags.mb_fsize )   as mb_fsize,
       SUM( ags.mb_maxsize ) as mb_maxsize,
       case 
          when ( sum( ags.mb_alloc ) - tsf.mbfree ) <= 0 then
             ROUND(( SUM( ags.mb_alloc ) / SUM( ags.mb_maxsize ) ) * 100, 0)
          else
             ROUND((( SUM( ags.mb_alloc ) - tsf.mbfree ) / SUM( ags.mb_maxsize ) ) * 100, 0) 
       end as PCT_USED,
       case 
          when ( sum( ags.mb_alloc ) - tsf.mbfree ) <= 0 then
             RPAD( '|', ROUND(( SUM( ags.mb_alloc ) / SUM( ags.mb_maxsize ) ) * 100, 0), '|') 
          else
             RPAD( '|', ROUND((( SUM( ags.mb_alloc ) - tsf.mbfree ) / SUM( ags.mb_maxsize ) ) * 100, 0), '|') 
       end  as PCT_USED_BAR
FROM   ( SELECT ( fn.bsize * fi.allocated ) / 1024/1024 mb_alloc,
                ( fn.bsize * fi.fsize ) / 1024/1024 mb_fsize,
                ( fn.bsize * fi.maxsize ) / 1024/1024 mb_maxsize,
                fn.ts#
         FROM   filename fn,
                fileinfo fi
         WHERE  fi.rfno   = fn.rfile# 
           AND  fi.tbs_id = fn.ts# ) ags,
       tbsinfo ti
left outer
join   tsfree tsf
on     tsf.tablespace_name = ti.name
WHERE  ags.ts# = ti.ts#
GROUP  BY ti.name,
          tsf.mbfree
ORDER  BY 1;

PROMPT &HR
PROMPT 
SET FEEDBACK OFF
SET UNDERLINE '-'

/* ===== end of tbsuse.sql ===== */


