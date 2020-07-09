import sqlalchemy as db
import pandas as pd
import snowflake.connector                        
import os
from snowflake.sqlalchemy import URL
from datetime import datetime
import argparse
# import records

def connect(database, role = 'TRANSFORMER', warehouse = 'TRANSFORMING'):
    '''
    Connect to Snowflake, returns the cursor to be reused
    '''  
    # Get passwords etc from the .env file
    try:
        engine = db.create_engine(
                URL(user=os.getenv("user"),
                    password=os.getenv("pdw"),
                    account='<account>',
                    role=role,
                    warehouse=warehouse))

        con = engine.connect()
        con.execute(f'USE WAREHOUSE {warehouse}')
        con.execute(f'USE DATABASE {database}')
    except Exception as e:
        raise
        traceback.format_exception(*sys.exc_info())
        raise # reraises the exception

    return con;

def query_table(connection, database=None,schema=None,table=None, sql=None):
    '''
    Connect to snowflake and return a dataframe from the SQL query
    '''
    if sql:
        sql = sql
    else:
        sql = f'''SELECT 
                    *
                    FROM "{database}"."{schema}"."{table}"
                '''

    df = pd.read_sql(sql, connection)
    con.close()
    return df;



### template for the views






if __name__ == "__main__":
    # Construct the argument parser
    ap = argparse.ArgumentParser()

    # Add the arguments to the parser
    ap.add_argument("-db", "--source_database", required=True, help="Snowflake database")
    ap.add_argument("-s", "--source_schema", required=True, help="Snowflake schema")    
    ap.add_argument("-r", "--role", required=True, help="Snowflake role")
    ap.add_argument("-w", "--warehouse", required=True, help="Snowflake warehouse")
    args = vars(ap.parse_args())

    source_database = args['source_database']
    source_schema = args['source_schema']
    role = args['role']
    warehouse = args['warehouse']

    template = 'base_table_template.sql' # change this to a file input

    con = connect(source_database], role], warehouse])
    tables_sql = f"""show tables like '%%' in {source_database}.{source_schema}"""
    columns_sql = f"""desc table {source_database}.{source_schema]}.SNOWFLAKE_TABLE_NAME_VAR;"""
    # con = connect('RAW_DEV', 'ROLE_DATA_ENGINEERING', 'WAREHOUSE_TRANSFORM_DEV')
    # tables_sql = """show tables like '%%' in RAW_DEV.CANVAS_INSHOSTEDDATA"""
    # columns_sql = f"""desc table RAW_DEV.CANVAS_INSHOSTEDDATA.SNOWFLAKE_TABLE_NAME_VAR;"""

    results = query_table(con, source_database, source_schema],'',tables_sql)

    for name in results.name:
        all_columns = ''
        columns_query = ''
        columns = ''
        sql_result = ''
        
        print(name)
        
        ## get columns
        columns_query = columns_sql.replace('SNOWFLAKE_TABLE_NAME_VAR',name)
        con = connect('RAW_DEV', 'ROLE_DATA_ENGINEERING', 'WAREHOUSE_TRANSFORM_DEV')
        columns = query_table(con, 'RAW_DEV', 'CANVAS_INSHOSTEDDATA','',columns_query)

        ## create columns list
        for column in columns.name:
    #         column =  '   ' + column + ' as ' + name + '_' + column + ',' + '\n'
            column =  '   ' + column + ',' + '\n'
            all_columns+=column
            
        ## create SQL by replacing placeholders with variables
        sql_result = template.replace('SNOWFLAKE_TABLE_NAME_VAR',name).replace('ALL_FIELD_NAMES',all_columns)   
        
        ## write to a file
        name = name.lower()
        file_name = f'canvas/base/canvas_base_{name}.sqlx'
        with open(file_name, 'w') as f:
            f.write("%s" % sql_result)

    print('done')