-- (0) TURN OFF CASE SENSITIVITY
USE ROLE ACCOUNTADMIN;

-- (1) CREATE DATABASES
USE ROLE SYSADMIN;

CREATE DATABASE "RAW";
-- This database contains your raw data. 
-- This is the landing pad for everything extracted and loaded, as well as containing external stages for data living in S3. 
-- Access to this database is strictly permissioned.

CREATE DATABASE "ANALYTICS";
-- This database contains tables and views accessible to analysts and reporting. 
-- Everything in analytics is created and owned by dataform/dbt.


-- (2) CREATE WAREHOUSES
CREATE WAREHOUSE "LOADING"
WITH WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1 MAX_CLUSTER_COUNT = 1
;
-- Tools like Fivetran and Stitch will use this warehouse to perform their regular loads of new data. 
-- We separate this workload from the other workloads because, at scale, loading can put significant strain on your warehouse and we don’t want to cause slowness for your BI users.


CREATE WAREHOUSE "TRANSFORMING"
WITH WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1 MAX_CLUSTER_COUNT = 1
;
-- This is the warehouse that dataform/dbt will use to perform all data transformations. 
-- It will only be in use (and charging you credits) when regular jobs are being run.

CREATE WAREHOUSE "REPORTING"
WITH WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1 MAX_CLUSTER_COUNT = 1
;
-- BI tools will connect to this warehouse to run analytical queries and report the results to end users. 
-- This warehouse will be spun up only when a user is actively running a query against it.

-- (3) CREATE ROLES AND GRANT PRIVILEGES
USE ROLE ACCOUNTADMIN;

CREATE ROLE "LOADER";
-- Owns the tables in your raw database, and connects to the loadingwarehouse.

CREATE ROLE "TRANSFORMER";
-- Has query permissions on tables in raw database and owns tables in the analytics database. 
-- This is for dataform/dbt developers and scheduled jobs.

CREATE ROLE "REPORTER";
-- Has permissions on the analytics database only. This role is for data consumers, such as analysts and BI tools. 
-- These users will not have permissions to read data from the raw database

GRANT ALL PRIVILEGES ON WAREHOUSE "LOADING" TO ROLE "LOADER";
GRANT ALL PRIVILEGES ON WAREHOUSE "TRANSFORMING" TO ROLE "TRANSFORMER";
GRANT ALL PRIVILEGES ON WAREHOUSE "REPORTING" TO ROLE "REPORTER";

GRANT CREATE SCHEMA, MODIFY, MONITOR, USAGE ON DATABASE "RAW" TO ROLE "LOADER";
GRANT USAGE ON DATABASE "RAW" TO ROLE "LOADER";
GRANT USAGE ON ALL SCHEMAS in DATABASE "RAW" to ROLE "LOADER";
GRANT USAGE ON DATABASE "RAW" TO ROLE "TRANSFORMER";
GRANT USAGE ON ALL SCHEMAS in DATABASE "RAW" to ROLE "TRANSFORMER";

GRANT CREATE SCHEMA, MODIFY, MONITOR, USAGE ON DATABASE "ANALYTICS" TO ROLE "TRANSFORMER";
GRANT USAGE ON DATABASE "ANALYTICS" TO ROLE "TRANSFORMER";
GRANT USAGE ON ALL SCHEMAS in DATABASE "ANALYTICS" to ROLE "TRANSFORMER";
GRANT USAGE ON DATABASE "ANALYTICS" TO ROLE "REPORTER";
GRANT USAGE ON ALL SCHEMAS in DATABASE "ANALYTICS" to ROLE "REPORTER";

-- (4) CREATE USERS
CREATE USER "TEST_REPORTER"
  MUST_CHANGE_PASSWORD = TRUE
  DEFAULT_ROLE = "REPORTER"
  DEFAULT_WAREHOUSE = "REPORTING"
  PASSWORD = 'PASSWORD'; -- Single quote!
GRANT ROLE "REPORTER" TO USER "TEST_REPORTER";

CREATE USER "TEST_TRANSFORMER"
  MUST_CHANGE_PASSWORD = TRUE
  DEFAULT_ROLE = "TRANSFORMER"
  DEFAULT_WAREHOUSE = "TRANSFORMING"
  PASSWORD = 'PASSWORD'; -- Single quote!
GRANT ROLE "TRANSFORMER" TO USER "TEST_TRANSFORMER";

CREATE USER "TEST_LOADER"
  MUST_CHANGE_PASSWORD = TRUE
  DEFAULT_ROLE = "LOADER"
  DEFAULT_WAREHOUSE = "LOADING"
  PASSWORD = 'PASSWORD'; -- Single quote!
GRANT ROLE "LOADER" TO USER "TEST_LOADER";



USE ROLE SYSADMIN;
