# snowflake-starter
A starter template for [Snowflake Cloud Database](www.snowflake.com)

* Snowflake offers a 1 month free trial, and with this repo you should be able to get a sense for the basics of Snowflake within an hour.
* This temaplate will create the necessary `ROLE`, `USER`, `DATABASE`, `SCHEMA` & `WAREHOUSE`(s) necessary to get up and running with Snowflake:

![snowflake.png](/assets/snowflake_rn.png)


# Usage

## Requirements

* [Snowflake instance](https://trial.snowflake.com/) (takes 5min to setup, no credit card for 1 month)
* [SnowSQL CLI](https://docs.snowflake.com/en/user-guide/snowsql.html) (optional)

## 1. Deploy

Copy [first_run.sql](/first_run.sql) into a worksheet as in the screenshot below and Run All. 

Or use the CLI
```bash
snowsql -c <your_connection_name> -f first_run.sql
```

![snowflake.png](/assets/worksheet.png)

### Infrastructure Details
The following is created, as described in [first_run.sql](/first_run.sql)
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

## 2. Test

Use the [test_permissions.sql](/test_permissions.sql) SQL to:
1. create a base table in the `RAW` database, load a test row using the `ROLE_INGEST` role
1. create a new table and view in `ANALYTICS` using the `ROLE_TRANSFORM` role
1. query that view using the `ROLE_REPORT` role

**NB replace `<USERNAME>` in the file with your login name** 

Or use the CLI:
```bash
snowsql -c <your_connection_name> -f test_permissions.sql
```

## 3. JSON

JSON is very well handled in Snowflake, and worth a look. The [test_json.sql](/test_json.sql) file runs through the flattening of raw JSON into a table.

Or use the CLI:
```bash
snowsql -c <your_connection_name> -f test_json.sql
```

* Key to note is the `RECURSIVE=>TRUE` flag

## 4. User-Defined Functions

UDF allow you to create functions in SQL or JavaScript. The [test_udf.sql](/test_udf.sql) file runs through the creation and testing of a SQL and JavaScript UDF. See the [docs](https://docs.snowflake.com/en/sql-reference/udf-overview.html) for more

Or use the CLI:
```bash
snowsql -c <your_connection_name> -f test_udf.sql
```


## 5. Tear Down

The [first_run_drop.sql](/first_run_drop.sql) file will drop all objects created by [first_run.sql](/first_run.sql) 

Or use the CLI:
```bash
snowsql -c <your_connection_name> -f first_run_drop.sql
```

## 6. SnowSQL-CLI

If you want to do this more than once, the [SnowSQL CLI](https://docs.snowflake.com/en/user-guide/snowsql.html) is great. 

```bash
git clone https://github.com/mattarderne/snowflake-starter.git
cd snowflake-starter
snowsql -c <your_connection_name> -f first_run.sql
```

## 7. End to End Test
If the following script runs without error, then that is an end to end test... it should take about a minute. (change the `<placeholders>` in the [file](tests/run.sh))

```bash
sh tests/run.sh
```

# Other things

## SnowAlert

[SnowAlert](https://github.com/snowflakedb/SnowAlert) is a project maintained by Snowflake that provides some useful system monitoring features. I like to use some of the queries they have created to monitor cost spikes.

The [snowAlert.sql](/utils/snowAlert.sql) creates the views and runs the queries necessary to get alerts. Running it daily in Dataform/dbt is a nice way to get custom alerts to unusual spikes 

```bash
snowsql -c <your_connection_name> -f utils/snowAlert.sql -o friendly=false -o quiet=true
```

## Snowflake Inspector

If you'd like to keep track of the evolution of your Snowflake Data Warehouse, [snowflakeinspector](http://snowflakeinspector.hashmapinc.com/) is a great tool to do just that. Query your metadata and paste the results into their tool and you'll get a nice explorable visualisation as below:

![snowflakeinspector.png](/assets/snowflakeinspector.png)

## Thanks

* Thanks to [Trevor](https://trevorscode.com/comprehensive-tutorial-of-snowflake-privileges-and-access-control/) for reviews, thoughts and guidance, checkout his code [here](https://github.com/trevor-higbee/snowflake-tools)
* Thanks for the inspiration [Calogica.com](https://Calogica.com) and [Fishtown Analytics](https://blog.fishtownanalytics.com/how-we-configure-snowflake-fc13f1eb36c4). JSON tutorial [here](https://interworks.com/blog/hcalder/2018/06/19/the-ease-of-working-with-json-in-snowflake/)
* Read my writing on the topic of Data Systems at [groupby1](https://groupby1.substack.com/)


## TODO
* [x] think about adding [Snowsql CLI](https://docs.snowflake.com/en/user-guide/snowsql-install-config.html)
* [x] add some JSON to the permissions test
* [x] add the Snowflake credits query pack [1](https://github.com/snowflakedb/SnowAlert/blob/master/packs/snowflake_query_pack.sql)[2](https://github.com/snowflakedb/SnowAlert/blob/master/packs/snowflake_cost_management.sql)
* [x] think about [snowflake-inspector](http://snowflakeinspector.hashmapinc.com/) inclusion [github](https://github.com/hashmapinc/snowflake-inspector)
* [x] add a UDF
* [x] compare `TO ROLE role` and `TO role`
* [ ] Add something about [masking semi-structured data with snowflake](https://www.snowflake.com/blog/masking-semi-structured-data-with-snowflake/)
* [ ] think about permissions management with [permifrost](https://gitlab.com/gitlab-data/permifrost)
* [ ] add some _more_ automation to the testing
* [ ] think about adding some kind of Query credit [usage analysis](https://www.snowflake.com/blog/understanding-snowflake-utilization-warehouse-profiling/) and [troubleshooting](https://community.snowflake.com/s/article/Cloud-Services-Billing-Update-Understanding-and-Adjusting-Usage)
* [ ] think about adding some over-permission analysis
* [ ] add [IP whitelisting](https://docs.snowflake.com/en/sql-reference/sql/alter-network-policy.html) to script
* [ ] create a script to run and specify account name etc 
* [ ] fine tune the warehouse specifications appropriately 
* [ ] add some features to make sure this is compatible with [RA_datawarehouse](https://github.com/rittmananalytics/ra_data_warehouse)
* [ ] update the sql to match the [mm style guide](https://github.com/mattm/sql-style-guide)
* [ ] Add some data with the [docker dataset](https://github.com/aa8y/docker-dataset)

## TODO: Snowflake Inspector
* Schema:
    * explore "analytics" database for primary keys, analyse for similarity, unnamed primary keys, variables etc
    * make suggestions
* Costs
    * Explore query history and build a recommendation for query optimisation 
    * Visualise 
