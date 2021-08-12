-- https://medium.com/hashmapinc/how-to-improve-cloud-cost-monitoring-snowflake-tableau-2aaf6fe2bf2a

-- //==========================================================
-- // create objects
-- //==========================================================

USE ROLE ROLE_ADMIN;

-- db
  CREATE DATABASE IF NOT EXISTS COSTS;

-- schema 
CREATE OR REPLACE SCHEMA COSTS.SNOWFLAKE_MONITORING;

USE ROLE ROLE_DATA_ENGINEERING;

-- // warehouse
CREATE WAREHOUSE IF NOT EXISTS
  COSTS_WAREHOUSE
  COMMENT='Warehouse for Costs dashboard development'
  WAREHOUSE_SIZE=XSMALL
  AUTO_SUSPEND=60 
  INITIALLY_SUSPENDED=TRUE;
-- //==========================================================


-- //==========================================================
-- // create user and role
-- //==========================================================
USE ROLE SECURITYADMIN;

-- // user
CREATE USER IF NOT EXISTS 
  COSTS_DEV_SERVICE_ACCOUNT 
  COMMENT='Account for Costs dashboard development'
  PASSWORD="change password here" 
  MUST_CHANGE_PASSWORD=false; 

-- // role
CREATE ROLE IF NOT EXISTS
    COSTS_ROLE
    COMMENT='Role for Costs dashboard development';
-- //==========================================================


-- //==========================================================
-- // Assign permissions to new tableau objects
-- //==========================================================
USE ROLE SECURITYADMIN;

-- // grant db and warehouse access to role
GRANT USAGE ON DATABASE COSTS TO ROLE COSTS_ROLE;
GRANT USAGE ON SCHEMA COSTS.SNOWFLAKE_MONITORING TO ROLE COSTS_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA COSTS.SNOWFLAKE_MONITORING TO ROLE COSTS_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA COSTS.SNOWFLAKE_MONITORING TO ROLE COSTS_ROLE;
GRANT USAGE ON WAREHOUSE COSTS_WAREHOUSE TO ROLE COSTS_ROLE;

-- // grant role to user and sysadmin
GRANT ROLE COSTS_ROLE TO USER COSTS_DEV_SERVICE_ACCOUNT;
GRANT ROLE COSTS_ROLE TO ROLE SYSADMIN;

-- // Set the default role and warehouse for the user account
ALTER USER 
  COSTS_DEV_SERVICE_ACCOUNT 
SET 
  DEFAULT_ROLE=COSTS_ROLE
  DEFAULT_WAREHOUSE=COSTS_WAREHOUSE;
-- //==========================================================