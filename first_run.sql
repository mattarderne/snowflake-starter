----------------------------------------
-- (1) CREATE DATABASES
----------------------------------------

USE ROLE SYSADMIN;

CREATE DATABASE RAW COMMENT = "This database contains your raw data,";
-- This database contains your raw data. 
-- This is the landing pad for everything extracted and loaded, as well as containing external stages for data living in S3. 
-- Access to this database is strictly permissioned.

CREATE DATABASE ANALYTICS COMMENT = "This database contains tables and views accessible to analysts and reporting";
-- This database contains tables and views accessible to analysts and reporting. 
-- Everything in analytics is created and owned by dataform/dbt.

----------------------------------------
-- (2) CREATE WAREHOUSES
----------------------------------------
CREATE WAREHOUSE WAREHOUSE_INGEST
WITH WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
COMMENT = "Tools like Fivetran and Stitch will use this warehouse to perform their regular loads of new data"
;
-- Tools like Fivetran and Stitch will use this warehouse to perform their regular loads of new data. 
-- We separate this workload from the other workloads because, at scale, loading can put significant strain on your warehouse and we don’t want to cause slowness for your BI users.


CREATE WAREHOUSE WAREHOUSE_TRANSFORM
WITH WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
COMMENT = "This is the warehouse that dataform/dbt will use to perform all data transformations"
;
-- This is the warehouse that dataform/dbt will use to perform all data transformations. 
-- It will only be in use (and charging you credits) when regular jobs are being run.

CREATE WAREHOUSE WAREHOUSE_REPORT
WITH WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
COMMENT = "BI tools will connect to this warehouse to run analytical queries and report the results to end users"
;
-- BI tools will connect to this warehouse to run analytical queries and report the results to end users. 
-- This warehouse will be spun up only when a user is actively running a query against it.

----------------------------------------
-- (3) CREATE ROLES AND GRANT PRIVILEGES
----------------------------------------
USE ROLE SECURITYADMIN;
-- From the docs: We recommend using a role other than ACCOUNTADMIN for automated scripts
-- https://docs.snowflake.com/en/user-guide/security-access-control-considerations.html

CREATE ROLE ROLE_INGEST
COMMENT = "Owns the tables in your raw database, and connects to the loading warehouse";
-- Owns the tables in your raw database, and connects to the loading warehouse.

CREATE ROLE ROLE_TRANSFORM
COMMENT = "Has query permissions on tables in raw database and owns tables in the analytics database";
-- Has query permissions on tables in raw database and owns tables in the analytics database. 
-- This is for dataform/dbt developers and scheduled jobs.

CREATE ROLE ROLE_REPORT
COMMENT = "Has permissions on the analytics database only. This role is for data consumers, such as analysts and BI tools";
-- Has permissions on the analytics database only. This role is for data consumers, such as analysts and BI tools. 
-- These users will not have permissions to read data from the raw database

GRANT ALL PRIVILEGES ON WAREHOUSE WAREHOUSE_INGEST TO ROLE_INGEST;
GRANT ALL PRIVILEGES ON WAREHOUSE WAREHOUSE_TRANSFORM TO ROLE_TRANSFORM;
GRANT ALL PRIVILEGES ON WAREHOUSE WAREHOUSE_REPORT TO ROLE_REPORT;
-- assign warehouse privileges

GRANT CREATE SCHEMA, MODIFY, MONITOR, USAGE ON DATABASE RAW TO ROLE_INGEST;
GRANT USAGE ON DATABASE RAW TO ROLE_TRANSFORM;
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE RAW TO ROLE_TRANSFORM;
GRANT SELECT ON FUTURE TABLES IN DATABASE RAW TO ROLE_TRANSFORM;
GRANT SELECT ON FUTURE VIEWS IN DATABASE RAW TO ROLE_TRANSFORM;
GRANT USAGE ON FUTURE FUNCTIONS IN DATABASE RAW TO ROLE_TRANSFORM;
-- assign RAW database privileges to ROLE_INGEST and ROLE_TRANSFORM

GRANT CREATE SCHEMA, MODIFY, MONITOR, USAGE ON DATABASE ANALYTICS TO ROLE_TRANSFORM;
GRANT USAGE ON DATABASE ANALYTICS TO ROLE_REPORT;
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE ANALYTICS TO ROLE_REPORT;
GRANT SELECT ON FUTURE TABLES IN DATABASE ANALYTICS TO ROLE_REPORT;
GRANT SELECT ON FUTURE VIEWS IN DATABASE ANALYTICS TO ROLE_REPORT;
GRANT USAGE ON FUTURE FUNCTIONS IN DATABASE ANALYTICS TO ROLE_REPORT;
-- assign ANALYTICS database privileges to ROLE_REPORT and ROLE_TRANSFORM

----------------------------------------
-- (4) CREATE USERS
----------------------------------------
CREATE USER USER_INGEST
  MUST_CHANGE_PASSWORD = TRUE
  DEFAULT_ROLE = ROLE_REPORT
  DEFAULT_WAREHOUSE = WAREHOUSE_REPORT
  PASSWORD = 'PASSWORD'; -- Single quote!
GRANT ROLE ROLE_INGEST TO USER USER_INGEST;

CREATE USER USER_TRANSFORM
  MUST_CHANGE_PASSWORD = TRUE
  DEFAULT_ROLE = ROLE_TRANSFORM
  DEFAULT_WAREHOUSE = WAREHOUSE_TRANSFORM
  PASSWORD = 'PASSWORD'; -- Single quote!
GRANT ROLE ROLE_TRANSFORM TO USER USER_TRANSFORM;

CREATE USER USER_REPORT
  MUST_CHANGE_PASSWORD = TRUE
  DEFAULT_ROLE = ROLE_INGEST
  DEFAULT_WAREHOUSE = WAREHOUSE_INGEST
  PASSWORD = 'PASSWORD'; -- Single quote!
GRANT ROLE ROLE_REPORT TO USER USER_REPORT;
