spool rebuild_all.sql;
SELECT 'ALTER INDEX ' || index_name || ' REBUILD;' FROM all_indexes WHERE OWNER='TOTO_OWNER';
spool off;
@rebuild_all.sql
