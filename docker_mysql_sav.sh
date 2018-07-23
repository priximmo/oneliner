docker ps --format "{{ .ID }}|{{ .Names }}|{{.Image}}" | while IFS="|" read var1 var2 var3;do
var2=$(echo $var2 | sed -e 's/\(.*\)\..*$/\1/g') BACKUP_DIR="/dir_export/" DUMP_DIR=${BACKUP_DIR}${var2}/ DUMP=BACKUP_DIR="/export/sgbd-dumps/" DATEDUMP=$(date +%Y-%m-%d) DUMP=${DATEDUMP}.${var2}
	echo "---- ${DATEDUMP} / Dump du container ${var2} -----" > ${DUMP_DIR}${DUMP}.log
	echo ${DATEDUMP}"-name >>"$var2 >> ${DUMP_DIR}${DUMP}.log
	echo ${DATEDUMP}"-image >>"$var3 >> ${DUMP_DIR}${DUMP}.log
	echo ${DATEDUMP}"-dump >>"${DUMP_DIR} >> ${DUMP_DIR}${DUMP}.log
	echo ""
	echo "---- ${DATEDUMP} / Dump du container ${var2} -----" docker exec ${var1} mysqldump -u --password= --all-databases > ${DUMP_DIR}${DUMP}.sql

docker run --name testsgbd -e MYSQL_ROOT_PASSWORD= -tid $var3 | grep -vi warning sleep 40

if [ -n "$(docker exec -i testsgbd mysql -uroot -ppassRoot <${DUMP_DIR}${DUMP}.sql 2>&1 | grep -vi Warning )" ];then
 echo " >>> ${DATEDUMP} : [Error]" >> ${DUMP_DIR}${DUMP}.log echo "[Pb import]" rm -f ${DUMP_DIR}${DUMP}
else echo " >>> ${DATEDUMP} : [OK]" >> ${DUMP_DIR}${DUMP}.log echo "[Import OK]" echo "Gzip..." gzip ${DUMP_DIR}${DUMP}*.sql echo "fin"
fi

docker rm -f testsgbd
done
