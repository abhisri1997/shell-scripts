#! /bin/bash

#####################################################
#       Script created by - Abhinav Kumar           #
#   abhinav.kumar.ext@boehringer-ingelheim.com      #
#####################################################


echo -e "Enter schema names seperated by spaces\n"

read -a schemas

if [ ! -d "./postgres_row_count" ]; then
    mkdir ./postgres_row_count
fi

db_name="$(cat /home/enterprisedb/.bash_profile |grep PGDATABASE|awk '{print $1}'|cut -d '=' -f2|cut -d ';' -f1)"
echo "$db_name"

for schema in "${schemas[@]}"
do
    count=`expr $(psql -c "SELECT nspname||'.'||relname AS full_rel_name 
            FROM pg_class, pg_namespace WHERE relnamespace = pg_namespace.oid 
            AND nspname = '$schema' AND relkind = 'r';" | wc -l) - 2`

    echo "Table Count in schema $schema : `expr $count - 2`"

    tableFile=$(psql -c "SELECT nspname||'.'||relname AS full_rel_name 
            FROM pg_class, pg_namespace WHERE relnamespace = pg_namespace.oid 
            AND nspname = '$schema' AND relkind = 'r';" | awk -v awkvar="$count" 'NR>=3 && NR<=awkvar {print}' > tableFile.txt)

    mapfile -t tables < tableFile.txt

    filename=$(date +"%d%B%y_%H%M%S")_$schema.csv

    echo -e "Table Name,Row Count" >> ./postgres_row_count/$filename

    for table in "${tables[@]}"
    do
        row_count=$(psql -c "select count(*) from $table;" | awk 'NR==3 { print }')
        echo -e "$table,$row_count" >> ./postgres_row_count/$filename

    cat ./postgres_row_count/$filename | tr -d "[:blank:]" > ./postgres_row_count/$filename
    sort -o ./postgres_row_count/$filename ./postgres_row_count/$filename

    if [ -e "./postgres_row_count/$filename" ]; then
        echo "Sending Mail..."
        SUBJECT="PostgreSQL table count for $db_name"
        MESSAGE="/tmp/Mail.out"
        TO="abhinav.kumar.ext@boehringer-ingelheim.com"
        echo "All the table counting done" >> $MESSAGE
        mailx -s "$SUBJECT" -a ./postgres_row_count/$filename "$TO"   < $MESSAGE
        rm /tmp/Mail.out
    fi

done

output_file=$(date +"%d%B%y_%H%M%S")_combined.csv
cat ./postgres_row_count/*.csv > $output_file
echo -e "Output file generated - $output_file"