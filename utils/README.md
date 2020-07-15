

## case_sensitivity.sql

Snowflake has some differences to PostgreSQL, demonstrated below. The case_sensitivity.sql file runs in both Snowflake and PostgreSQL, but the behavior is different as below:

```
--  Upper case table
select * from upper_case; -- works in Snowflake, not Postgres 
select * from UPPER_CASE; -- works in Snowflake, not Postgres
select * from "UPPER_CASE"; -- both work

-- Lower Case table
select * from lower_case;   -- works in Posgres, not Snowflake
select * from LOWER_CASE;   -- works in Posgres, not Snowflake 
select * from "lower_case"; -- both work
```

## snowflake_bulk_create.py

Work in progress 


TODO:
* [ ] add installation instructions
* [ ] remove the CANVAS_INSHOSTEDDATA from the script and replace with a variable
* [ ] remove Pandas
* [ ] Add option for choosing preferred naming convention (col as col_name or col)
* [ ] fix the '' as hack hack
* [ ] clean up the ${getRawDatabase()}.${canvas.CANVAS_INSHOSTEDDATA_SCHEMA}. javascript or remove
