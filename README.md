# snowflake_init
A starter template for [Snowflake Cloud Database](www.snowflake.com)

This temaplate will create the necessary `ROLE`, `USER`, `DATABASE`, `SCHEMA` & `WAREHOUSE`(s) necessary to get up and running with Snowflake.

Snowflake offers a 1 month free trial, and with this repo you should be able to get a sense for the basics within an hour.

## Usage

[first_run.sql](/first_run.sql) will create the following infrastructure. Copy the code into the Snowflake Worksheet window 

```
├── DATABASES
│   ├── RAW            # This is the landing pad for everything extracted and loaded
│   └── ANALYTICS      # This database contains tables and views accessible to analysts and reporting
├── WAREHOUSES
│   ├── LOADING        # Tools like Stitch will use this warehouse to perform loads of new data
│   ├── TRANSFORMING   # This is the warehouse that dataform/dbt will use to perform all data transformations
│   ├── REPORTING      # BI tools will connect to this warehouse to run analytical queries
├── ROLES
│   ├── LOADER        # Give this role to your Extract/Load tools/scripts to load data
│   ├── TRANSFORMER   # Give this role to Dataform/dbt to transform data, and Data Engineers
│   ├── REPORTER      # Give this role to BI tools / Analysts to query analytics data
├── USERS
│   ├── TEST_LOADER        
│   ├── TEST_TRANSFORMER   
│   ├── TEST_REPORTER      

```

Permissions are structured as follows

![snowflake.png](/snowflake.png)

## Test

The [first_run_permissions_test.sql.sql](/first_run_permissions_test.sql.sql) file will:
1. create a base table in the `RAW` database, load a test row using the `LOADER` role
1. create a new table and view in `ANALYTICS` using the `TRANSFORMER` role
1. query that view using the `REPORTER` role



# Sources
Taking inspiration from [Calogica.com](https://Calogica.com) and following the advice of [Fishtown Analytics](https://blog.fishtownanalytics.com/how-we-configure-snowflake-fc13f1eb36c4), this SQL statement will configure your Snowflake instance with a nicely configured and scalable platform for further development.


