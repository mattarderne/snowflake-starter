# Costs

## Costs
Think about snowalert and how it can help
https://medium.com/hashmapinc/snowalert-data-driven-security-analytics-using-snowflake-data-warehouse-3f046b779d54

## Utility
Find a way to map costs to utilisation of tables and views
https://medium.com/hashmapinc/housekeeping-in-snowflake-with-sql-and-dbt-a50d7448d4b1
https://medium.com/hashmapinc/3-steps-to-find-access-patterns-in-snowflake-using-hierarchical-queries-dde30849bb28




## Create
Need to be using account admin or sysadmin role

Test working:
```
snowsql -c vi_matt -o friendly=true -o quiet=false -q "                                    
    USE ROLE SYSADMIN;
    CREATE DATABASE IF NOT EXISTS COSTS;
    CREATE SCHEMA COSTS.SNOWFLAKE_MONITORING;
    "
```
Create all objects"
```
snowsql -c <admin_role> -f costs/costs_create.sql
```

## Use

Test working: 
```sql
snowsql -c COSTS_DEV_SERVICE_ACCOUNT -o friendly=false -o quiet=false -q "                                    
    USE ROLE COSTS_ROLE;
    USE DATABASE COSTS;
    USE SCHEMA SNOWFLAKE_MONITORING;

    select * from COSTS.SNOWFLAKE_MONITORING.SNOWFLAKE_USAGE limit 10;
    "
```

```
snowsql -c COSTS_DEV_SERVICE_ACCOUNT -f costs/costs_use.sql
```

