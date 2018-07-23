col sid_serial format a10
col username format a17
col osuser format a15
col spid format 99999
col module format a15
col program format a30
col mb_used format 999999.999
col mb_total format 999999.999
col tablespace format a15
col statements format 999
col hash_value format 99999999999
col sql_text format a50
col service_name format a15

prompt 
prompt #####################################################################
prompt #######################LOCAL TEMP USAGE#############################
prompt #####################################################################
prompt 

 SELECT   A.tablespace_name tablespace, D.mb_total,
SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM     v$sort_segment A,
(
SELECT   B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
FROM     v$tablespace B, v$tempfile C
WHERE    B.ts#= C.ts#
GROUP BY B.name, C.block_size
) D
WHERE    A.tablespace_name = D.name
GROUP by A.tablespace_name, D.mb_total;

prompt 
prompt #####################################################################
prompt #######################LOCAL TEMP USERS#############################
prompt #####################################################################
prompt 

SELECT   S.sid || ',' || S.serial# sid_serial, S.username, S.osuser, P.spid, 
--S.module,
--P.program,
s.service_name,
SUM (T.blocks) * TBS.block_size / 1024 / 1024 mb_used, T.tablespace,
COUNT(*) statements
FROM     v$tempseg_usage T, v$session S, dba_tablespaces TBS, v$process P
WHERE    T.session_addr = S.saddr
AND      S.paddr = P.addr
AND      T.tablespace = TBS.tablespace_name
GROUP BY S.sid, S.serial#, S.username, S.osuser, P.spid, 
S.module,
P.program,
s.service_name,TBS.block_size, T.tablespace
ORDER BY mb_used;

--prompt 
--prompt #####################################################################
--prompt #######################LOCAL ACTIVE SQLS ############################
--prompt #####################################################################
--prompt 
--
SELECT sysdate "TIME_STAMP", vsu.username, vs.sid, vp.spid, vs.sql_id, vst.sql_text,vsu.segtype, vsu.tablespace,vs.service_name,
        sum_blocks*dt.block_size/1024/1024 usage_mb
    FROM
    (
            SELECT username, sqladdr, sqlhash, sql_id, tablespace, segtype,session_addr,
                 sum(blocks) sum_blocks
            FROM v$tempseg_usage
        group by  username, sqladdr, sqlhash, sql_id, tablespace, segtype,session_addr
    ) "VSU",
    v$sqltext vst,
    v$session vs,
    v$process vp,
    dba_tablespaces dt
 WHERE vs.sql_id = vst.sql_id
    AND vsu.session_addr = vs.saddr
    AND vs.paddr = vp.addr
    AND vst.piece = 0
    AND vs.status='ACTIVE'
    AND dt.tablespace_name = vsu.tablespace
 order by usage_mb;
--
--prompt 
--prompt #####################################################################
--prompt #######################LOCAL TEMP SQLS##############################
--prompt #####################################################################
--prompt 
SELECT  S.sid || ',' || S.serial# sid_serial, S.username, Q.sql_id, Q.sql_text,
T.blocks * TBS.block_size / 1024 / 1024 mb_used, T.tablespace
FROM    v$tempseg_usage T, v$session S, v$sqlarea Q, dba_tablespaces TBS
WHERE   T.session_addr = S.saddr
AND     T.sqladdr = Q.address
AND     T.tablespace = TBS.tablespace_name
ORDER BY mb_used;
--
--
