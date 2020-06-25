snowsql -c matttest -f first_run_drop.sql -o friendly=false -o quiet=true
snowsql -c matttest -f first_run.sql -o friendly=false -o quiet=true
snowsql -c matttest -o friendly=false -o quiet=true -q "                                    
    USE ROLE ACCOUNTADMIN;
    GRANT ROLE ROLE_INGEST TO USER mattarderne;
    GRANT ROLE ROLE_TRANSFORM TO USER mattarderne;
    GRANT ROLE ROLE_REPORT TO USER mattarderne;
    "
snowsql -c matttest -f first_run_permissions_test.sql -o friendly=false -o quiet=true
snowsql -c matttest -f json_example.sql -o friendly=false -o quiet=true
snowsql -c matttest -f first_run_drop.sql -o friendly=false -o quiet=true