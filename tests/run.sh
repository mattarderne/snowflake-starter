snowsql -c <your_connection_name> -f first_run_drop.sql -o friendly=false -o quiet=true
snowsql -c <your_connection_name> -f first_run.sql -o friendly=false -o quiet=true
snowsql -c <your_connection_name> -o friendly=false -o quiet=true -q "                                    
    USE ROLE ACCOUNTADMIN;
    GRANT ROLE ROLE_INGEST TO USER <USERNAME>;
    GRANT ROLE ROLE_TRANSFORM TO USER <USERNAME>;
    GRANT ROLE ROLE_REPORT TO USER <USERNAME>;
    "
snowsql -c <your_connection_name> -f first_run_permissions_test.sql -o friendly=false -o quiet=true
snowsql -c <your_connection_name> -f json_example.sql -o friendly=false -o quiet=true
snowsql -c <your_connection_name> -f first_run_drop.sql -o friendly=false -o quiet=true