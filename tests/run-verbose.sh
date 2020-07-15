snowsql -c matttest -f first_run_drop.sql -o friendly=false -o quiet=true
echo 'first_run_drop'
snowsql -c matttest -f first_run.sql -o friendly=false -o quiet=true
echo 'first_run'
snowsql -c matttest -o friendly=false -o quiet=true -q "                                    
    USE ROLE ACCOUNTADMIN;
    GRANT ROLE ROLE_INGEST TO USER mattarderne;
    GRANT ROLE ROLE_TRANSFORM TO USER mattarderne;
    GRANT ROLE ROLE_REPORT TO USER mattarderne;
    "
echo 'grant'
snowsql -c matttest -f test_permissions.sql -o friendly=false -o quiet=true
echo 'first_run_permissions_test'
snowsql -c matttest -f test_json.sql -o friendly=false -o quiet=true
echo 'json_example'
# snowsql -c matttest -f first_run_drop.sql -o friendly=false -o quiet=true
# echo 'first_run_drop'