#! /bin/bash

echo "#######################################################"
echo "#             Scripted by Abhinav Kumar               #"
echo "#     abhinav.kumar.ext@boehringer-ingelheim.com      #"
echo "#######################################################"

echo -e "\nEnter schema names seperated by a space..."

read -a schemas

echo -e "\nEnter the user for whom permissions are required..."
read user

if [ -z "$user" ]; then
    echo -e "No user supplied...\nApplying BI-AS-ORACLE-ERP-DEV-PA-DBA as user...\n"
    user="BI-AS-ORACLE-ERP-DEV-PA-DBA"
    sleep 2
fi



db_name="$(cat /home/enterprisedb/.bash_profile |grep PGDATABASE|awk '{print $1}'|cut -d '=' -f2|cut -d ';' -f1)"

echo "DB: $db_name"

for schema in "${schemas[@]}"
do
    echo -e "\n"

    check_user=$(psql -d $db_name -c '\du "'$user'"' | grep "$user")
    if [ -z "$check_user" ]; then
        echo "User not found exiting..."
        exit
    fi

    echo "Granting permissions to $user on schema - $schema"

    grant_usage=$(psql -d $db_name -c 'GRANT USAGE ON SCHEMA "'$schema'" TO "'$user'";')
    echo "$grant_usage"

    grant_create=$(psql -d $db_name -c 'GRANT CREATE ON SCHEMA "'$schema'" TO "'$user'";')
    echo "$grant_create"

    grant_trigger_all_tables=$(psql -d $db_name -c 'GRANT TRIGGER ON ALL TABLES IN SCHEMA "'$schema'" TO "'$user'";')
    echo "$grant_trigger_all_tables"

    grant_privileges_all_tables=$(psql -d $db_name -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA "'$schema'" TO "'$user'";')
    echo "$grant_privileges_all_tables"

    grant_privileges_all_sequences=$(psql -d $db_name -c 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA "'$schema'" TO "'$user'";')
    echo "$grant_privileges_all_sequences"
    
    grant_execute_all_functions=$(psql -d $db_name -c 'GRANT EXECUTE ON ALL FUNCTIONS in SCHEMA "'$schema'" TO "'$user'";')
    echo "$grant_execute_all_functions"
done