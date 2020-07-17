--------------------------------------------------------
-- Source: https://github.com/snowflakedb/SnowAlert
--------------------------------------------------------

----------------------------------------
-- (1) CREATE VIEWS
----------------------------------------

USE ROLE SYSADMIN;

CREATE OR REPLACE VIEW rules.snowflake_admin_role_grant_monitor_alert_query COPY GRANTS AS
SELECT
      OBJECT_CONSTRUCT('cloud', 'Snowflake', 'account', current_account()) AS environment
    , ARRAY_CONSTRUCT('snowflake') AS sources
    , REGEXP_SUBSTR(query_text, '\\s([^\\s]+)\\sto\\s',1,1,'ie') AS object
    , 'Snowflake ADMIN Role Granted' AS title
    , 'Snowflake - Admin role granted' AS alerttype
    , start_time AS event_time
    , CURRENT_TIMESTAMP() AS alert_time
    , 'A new grant was added ' || LOWER(REGEXP_SUBSTR(query_text, '\\s(to\\s[^\\s]+\\s[^\\s]+);?',1,1,'ie')) || ' by user ' || user_name || ' using role ' || role_name AS description
    , 'SnowAlert' AS detector
    , query_text AS event_data
    , 'Medium' AS severity
    , user_name AS actor
    , 'Granted Admin role' AS action
    , 'c77cf311de094a0ab9599917d6d0c644' AS query_id
    , 'snowflake_admin_role_grant_monitor_alert_query' AS query_name
FROM snowflake.account_usage.query_history
WHERE 1=1
  AND query_type='GRANT'
  AND execution_status='SUCCESS'
  AND (object ILIKE '%securityadmin%' OR object ILIKE '%accountadmin%')
;


CREATE OR REPLACE VIEW rules.snowflake_authorization_error_alert_query COPY GRANTS AS
SELECT
      OBJECT_CONSTRUCT('cloud', 'Snowflake', 'account', current_account()) AS environment
    , ARRAY_CONSTRUCT('snowflake') AS sources
    , 'Snowflake Query' AS object
    , 'Snowflake Access Control Error' AS title
    , START_TIME AS event_time
    , current_timestamp() AS alert_time
    , 'User ' || USER_NAME || ' received ' || ERROR_MESSAGE AS description
    , 'SnowAlert' AS detector
    , ERROR_MESSAGE AS event_data
    , USER_NAME AS actor
    , 'Received an authorization error' AS action
    , 'Low' AS severity
    , 'b0724d64b40d4506b7bc4e0caedd1442' AS query_id
    , 'snowflake_authorization_error_alert_query' AS query_name
from snowflake.account_usage.query_history
WHERE 1=1
  AND error_code in (1063, 3001, 3003, 3005, 3007, 3011, 3041)
;


CREATE OR REPLACE VIEW rules.snowflake_authentication_failure_alert_query COPY GRANTS AS
SELECT
      OBJECT_CONSTRUCT('cloud', 'Snowflake', 'account', current_account()) AS environment
    , ARRAY_CONSTRUCT('snowflake') AS sources
    , 'Snowflake' AS object
    , 'Snowflake Authentication Failure' AS title
    , event_timestamp AS event_time
    , CURRENT_TIMESTAMP() AS alert_time
    , 'User ' || USER_NAME || ' failed to authentication to Snowflake, from IP: ' || CLIENT_IP AS description
    , 'SnowAlert' AS detector
    , error_message AS event_data
    , user_name AS actor
    , 'failed to authenticate to Snowflake' AS action
    , 'Low' AS severity
    , 'c24675c89deb4e5ba6ecc57104447f90' AS query_id
    , 'snowflake_authentication_failure_alert_query' AS query_name
FROM snowflake.account_usage.login_history
WHERE 1=1
  AND IS_SUCCESS='NO'
;

-- GRANT SELECT ON VIEW rules.snowflake_authentication_failure_alert_query TO ROLE snowalert;
-- GRANT SELECT ON VIEW rules.snowflake_authorization_error_alert_query TO ROLE snowalert;
-- GRANT SELECT ON VIEW rules.snowflake_admin_role_grant_monitor_alert_query TO ROLE snowalert;


----------------------------------------
-- (2) RUN ALERT QUERIES
----------------------------------------

-- Automatic Clustering Spend
-- this query finds tables where the automatic clustering spend has gone over 10 credits in the past 5 hours
WITH table_spend AS (
  SELECT
    table_id,
    table_name,
    SUM(credits_used) AS credits
  FROM snowflake.account_usage.automatic_clustering_history
  WHERE DATEDIFF(HOUR, end_time, CURRENT_TIMESTAMP) < 5
  GROUP BY 1, 2
  ORDER BY 3 DESC
)
SELECT *
FROM table_spend
WHERE credits > 10
; 

-- Materialized View Spend
-- this query finds tables where the materialized view spend has gone over 10 credits in the past 5 hours
WITH table_spend AS (
  SELECT
    table_id,
    table_name,
    SUM(credits_used) AS credits
  FROM snowflake.account_usage.materialized_view_refresh_history
  WHERE DATEDIFF(HOUR, end_time, CURRENT_TIMESTAMP) < 5
  GROUP BY 1, 2
  ORDER BY 3 DESC)
SELECT * FROM table_spend
WHERE credits > 10
;

-- Snowpipe spend
-- this query finds tables where the snowpipe spend has gone over 10 credits in the past 12 hours
WITH pipe_spend AS (
  SELECT
    pipe_id,
    pipe_name,
    SUM(credits_used) AS credits_used
  FROM snowflake.account_usage.pipe_usage_history
  WHERE DATEDIFF(HOUR, end_time, CURRENT_TIMESTAMP) < 12
  GROUP BY 1, 2
  ORDER BY 3 DESC
)
SELECT *
FROM pipe_spend
WHERE credits_used > 10
;

-- Warehouse Spending Spike
-- this query compares the last day credit spend vs. the last 28 day average for the account
WITH average_use AS (
  SELECT
    warehouse_id,
    warehouse_name,
    SUM(credits_used) AS total_credits_used,
    SUM(credits_used) / 28 AS avg_credits_used
  FROM snowflake.account_usage.warehouse_metering_history
  WHERE DATEDIFF(DAY, start_time, CURRENT_TIMESTAMP) < 28
  GROUP BY 1, 2
)
SELECT
  w.warehouse_id,
  w.warehouse_name,
  SUM(w.credits_used) AS ld_credits_used,
  a.avg_credits_used
FROM snowflake.account_usage.warehouse_metering_history w
JOIN average_use a
ON w.warehouse_id = a.warehouse_id
WHERE DATEDIFF(DAY, start_time, CURRENT_TIMESTAMP) < 2
GROUP BY 1, 2, 4
HAVING ld_credits_used > (a.avg_credits_used * 2)
;