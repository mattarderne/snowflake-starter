-- for each schema in database RAW,
-- give the transformer select access to all tables, e.g.:
GRANT SELECT ON ALL TABLES IN SCHEMA "RAW"."<SCHEMA_NAME>" TO DBT_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA "RAW"."<SCHEMA_NAME>" TO ROLE transformer;
-- this may have to be repeated periodically



-- NB use Post Hooks in your dbt_project.yml file to grant usage on dbt runs, eg add something like the below:
/*
on-run-end:                     # grants permissions on all newly created tables
     - 'grant usage on schema {{ target.schema }} to reporting'
     - 'grant select on all tables in schema {{ target.schema }} to reporting'
*/
