MYSQL_CONNECT="mysql -h hostname -u username -ppassword -D database"; $MYSQL_CONNECT -Bne "show tables;" | awk '{print "set foreign_key_checks=0; drop table `" $1 "`;"}' | $MYSQL_CONNECT unset MYSQL 
