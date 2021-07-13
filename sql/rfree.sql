/*
   onderwerp ....: rfree.sql
   versie .......: 0.2
   auteur .......: Ir. R. Blok
   opmerkingen ..: gemodificeerd door Gert J. Willems

   history
   10-12-2001 rbl Eerste opzet
   15-04-2002 rbl Extent management in aparte query erbij
   19-11-2008 gjw MAXBYTES (indien gevuld) meegenomen in de berekening 
                  van de theoretisch alloceerbare ruimte (de fysiek 
                  beschikbare ruimte NIET meegenomen!)
   29-06-2021 gjw timestamp voor rapportage
*/

-- :: show used and free database space

set linesize 1000
set pagesize 1000

column TABLESPACE_NAME      heading "tablespace"        format A25
column FILE_NAME            heading "filename"          format A80
column MBYTES_ALLOC         heading "bytes|alloc [MB]"  format "999999999"
column FILE#                heading "File#"             format 99990
column MBYTES_FREE          heading "bytes|free [MB]"   format "999999999"
column PCT_FREE             heading "pct|free"          format "990D0"
column AUTOEXT              heading "aut"               format A3
column MMAXBYTES            heading "max bytes|[MB]"    format "999999999"
column KINCREMENT_BY        heading "incr|[KB]"         format "999999990"

column CONTENTS             heading "contents"          format A9
column LOGGING              heading "logging"           format A9
column EXTENT_MANAGEMENT    heading "ext. management"   format A15
column ALLOCATION_TYPE      heading "alloc. type"       format A11

prompt Enter the tablespace name (Enter for all):
set termout off
set verify off
define tsname='&1';

compute sum of MBYTES_ALLOC on REPORT
compute sum of MBYTES_FREE on REPORT
break on TABLESPACE_NAME SKIP 0 on REPORT 

column DB_BLOCK_SIZE new_value BLOCK_SIZE
column report_header FORMAT a100

SELECT   value       db_block_size
FROM     V$PARAMETER
WHERE    NAME = 'db_block_size'
/

set termout on feedback off

PROMPT
PROMPT ================= Tablespace and Data file Report ==================
SET HEADING off

SELECT   'Reporting on '|| global_name ||' @ '|| current_timestamp AS report_header
FROM     global_name;

SET HEADING on

SELECT   tablespace_name                            tablespace_name
,        file_name                                  file_name
,        file#
,        bytes_alloc / 1024 / 1024                  mbytes_alloc
,        bytes_free / 1024 / 1024                   mbytes_free
,        CASE 
         WHEN MAXBYTES > 0 THEN         
              ROUND(( 1 - (( bytes_alloc - nvl( bytes_free, 0 ) ) / maxbytes )) * 100, 2 ) 
         ELSE
              ROUND(( nvl( bytes_free, 0 ) / bytes_alloc ) * 100, 2 ) 
         END                                        pct_free
,        autoext                                    autoext
,        maxbytes / 1024 / 1024                     mmaxbytes
,        ( increment_bY * &block_size ) / 1024      kincrement_by
FROM     (
   SELECT   a.tablespace_name                       tablespace_name
   ,        a.file_name                             file_name
   ,        a.file_id                               file#
   ,        a.bytes_alloc                           bytes_alloc
   ,        f.bytes_free                            bytes_free
   ,        a.autoextensible                        autoext
   ,        a.maxbytes                              maxbytes
   ,        a.increment_by                          increment_by
   FROM     (
      SELECT   file_id
      ,        tablespace_name
      ,        file_name
      ,        autoextensible
      ,        bytes                                bytes_alloc
      ,        maxbytes                             maxbytes
      ,        increment_by                         increment_by
      FROM     dba_data_files
      WHERE    tablespace_name LIKE UPPER( '%&tsname' )
      )        a
      ,        (
      SELECT   file_id
      ,        tablespace_name
      ,        SUM( bytes )                         bytes_free
      FROM     dba_free_space
      WHERE    tablespace_name LIKE UPPER( '%&tsname' )
      GROUP BY file_id, tablespace_name
      )        F
      WHERE    a.file_id = f.file_id (+)
      UNION
      SELECT   a.tablespace_name                                         tablespace_name
      ,        a.file_name                                               file_name
      ,        a.file_id                                                 file#
      ,        a.bytes_alloc                                             bytes_alloc
      ,        a.bytes_free                                              bytes_free
      ,        a.autoextensible                                          autoext
      ,        a.maxbytes                                                maxbytes
      ,        a.increment_by                                            increment_by
      FROM     (
         SELECT   file_id
         ,        tablespace_name
         ,        file_name
         ,        autoextensible
         ,        bytes                              bytes_alloc
         ,        maxbytes                           maxbytes
         ,        increment_by                       increment_by
         ,        0                                  bytes_free
         FROM     dba_temp_files
         WHERE    tablespace_name LIKE UPPER( '%&tsname' )
         ) A
      )
ORDER BY tablespace_name, file_name
/

PROMPT

