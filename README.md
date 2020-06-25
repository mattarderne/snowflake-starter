# snowflake-starter
A starter template for [Snowflake Cloud Database](www.snowflake.com)

This temaplate will create the necessary `ROLE`, `USER`, `DATABASE`, `SCHEMA` & `WAREHOUSE`(s) necessary to get up and running with Snowflake:

![snowflake.png](/assets/snowflake.png)

Snowflake offers a 1 month free trial, and with this repo you should be able to get a sense for the basics of Snowflake within an hour.

## Usage

Copy [first_run.sql](/first_run.sql) into a worksheet as in the screenshot below and Run All. This will create the following infrastructure. See [SnowSQL CLI](#SnowSQL-CLI) CLI for the script version.

![snowflake.png](/assets/worksheet.png)

```
├── DATABASES
│   ├── RAW                     # This is the landing pad for everything extracted and loaded
│   └── ANALYTICS               # This database contains tables and views accessible to analysts and reporting
├── WAREHOUSES
│   ├── WAREHOUSE_INGEST        # Tools like Stitch will use this warehouse to perform loads of new data
│   ├── WAREHOUSE_TRANSFORM     # This is the warehouse that dataform/dbt will use to perform all data transformations
│   ├── WAREHOUSE_REPORT        # BI tools will connect to this warehouse to run analytical queries
├── ROLES
│   ├── ROLE_INGEST             # Give this role to your Extract/Load tools/scripts to load data
│   ├── ROLE_TRANSFORM          # Give this role to Dataform/dbt to transform data, and Data Engineers
│   ├── ROLE_REPORT             # Give this role to BI tools / Analysts to query analytics data
├── USERS
│   ├── USER_INGEST             # eg: Stitch User
│   ├── USER_TRANSFORM          # eg: Dataform User
│   ├── USER_REPORT             # eg: Looker user

```

## Test

The [first_run_permissions_test.sql](/first_run_permissions_test.sql) file will:
1. create a base table in the `RAW` database, load a test row using the `ROLE_INGEST` role
1. create a new table and view in `ANALYTICS` using the `ROLE_TRANSFORM` role
1. query that view using the `ROLE_REPORT` role

**NB replace `<USERNAME>` in the file with your login name** 

## JSON

JSON is very well handled in Snowflake, and worth a look. The [json_example.sql](/json_example.sql) file runs through the flattening of raw JSON into a table.

* Key to note is the `RECURSIVE=>TRUE` flag

## Tear Down

The [first_run_drop.sql](/first_run_drop.sql) file will drop all objects created by [first_run.sql](/first_run.sql) 

# SnowSQL-CLI

If you want to do this more than once, the [SnowSQL CLI](https://docs.snowflake.com/en/user-guide/snowsql.html) is worth a look. 

```bash
git clone https://github.com/mattarderne/snowflake-starter.git
cd snowflake-starter
snowsql -c <your_connection_name> -f first_run.sql
```

## End to end CLI
If the following all run without error, then that is an end to end test... it should take about a minute. (change the `<placeholders>`)

```sql
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
```

## Snowflake Inspector

If you'd like to keep track of the evolution of your Snowflake Data Warehouse, [snowflakeinspector](http://snowflakeinspector.hashmapinc.com/) is a great tool to do just that. Query your metadata and paste the results into their tool and you'll get a nice explorable visualisation as below:

![snowflakeinspector.png](/assets/snowflakeinspector.png)

# More

* Thanks for the inspiration [Calogica.com](https://Calogica.com) and [Fishtown Analytics](https://blog.fishtownanalytics.com/how-we-configure-snowflake-fc13f1eb36c4). JSON tutorial [here](https://interworks.com/blog/hcalder/2018/06/19/the-ease-of-working-with-json-in-snowflake/)
* Read my writing on the topic of Data Systems at [groupby1](https://groupby1.substack.com/)


# TODO
* [x] think about adding [Snowsql CLI](https://docs.snowflake.com/en/user-guide/snowsql-install-config.html)
* [ ] think about permissions management with [permifrost](https://gitlab.com/gitlab-data/permifrost)
* [x] think about [snowflake-inspector](http://snowflakeinspector.hashmapinc.com/) inclusion [github](https://github.com/hashmapinc/snowflake-inspector)
* [x] add some JSON to the permissions test
* [ ] add some _more_ automation to the testing
