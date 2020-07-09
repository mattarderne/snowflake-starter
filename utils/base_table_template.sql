config { 
    type: "view", 
    schema:"<SCHEMA_NAME>"
        }
with source as (
    
    SELECT * FROM "<DATABASE_NAME>"."<SCHEMA_NAME>"."SNOWFLAKE_TABLE_NAME_VAR"
),
renamed as (
    
    select
ALL_FIELD_NAMES
'' as hack 
        
    from source
    
)
select * from renamed