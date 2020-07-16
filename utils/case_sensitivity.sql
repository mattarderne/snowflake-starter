---------------------------------------------------------------------
-------Comparison between Snowflake and PostgreSQL-------------------
--------------------Case Sensitivity --------------------------------
---------------------------------------------------------------------
-- See Snowflake docs for more
-- https://docs.snowflake.com/en/sql-reference/identifiers-syntax.html

DROP TABLE IF EXISTS "UPPER_CASE";
CREATE TABLE IF NOT EXISTS "UPPER_CASE"(
   column1 varchar);

DROP TABLE IF EXISTS  "lower_case";
CREATE TABLE IF NOT EXISTS "lower_case"(
   column1 varchar);
   

--  Upper case table
select * from upper_case; -- works in Snowflake, not Postgres 
select * from UPPER_CASE; -- works in Snowflake, not Postgres
select * from "UPPER_CASE"; -- both work

-- Lower Case table
select * from lower_case;   -- works in Posgres, not Snowflake
select * from LOWER_CASE;   -- works in Posgres, not Snowflake 
select * from "lower_case"; -- both work
