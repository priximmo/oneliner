for i in $(cat liste.schema );do echo "drop user ${i} cascade;" | sqlplus '/ as sysdba'; done


