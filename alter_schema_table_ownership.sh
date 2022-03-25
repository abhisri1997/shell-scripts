#! /usr/bin/bash

#Scripted by Abhinav Kumar

echo "***********************************************************************"
echo "*               Scripted By - Abhinav Kumar                           *"
echo "*     Email - abhinav.kumar.ext@boehringer-ingelheim.com              *"
echo "***********************************************************************"

echo ""

echo "Enter schemanames seperated by space : "
read -a schemas

db_name="$(cat /home/enterprisedb/.bash_profile |grep PGDATABASE|awk '{print $1}'|cut -d '=' -f2|cut -d ';' -f1)"
echo "DB: $db_name"

for schema in "${schemas[@]}"
do
	alter_schema_owner=$(psql -d "$db_name" -c "alter schema "$schema" owner to "'"BI-AS-CHEMDBS-EVA-PA-DBA"'" ;")
	echo "alter_schema_owner"
	
	table_name=$(psql -d $db_name -qAt -c "select tablename from pg_tables where schemaname = '"$schema"';")
	#echo "$table_name"
	
	for tbl in $table_name
	do
	
	alter_table_owner=$(psql -d "$db_name" -c "alter table "$schema"."$tbl" owner to "'"BI-AS-CHEMDBS-EVA-PA-DBA"'" ;")
	echo "$alter_table_owner"
	
	done
done