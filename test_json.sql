
------------------
-- Replace <USERNAME> with your current user
------------------

-- USE ROLE ACCOUNTADMIN;

-- GRANT ROLE ROLE_INGEST TO USER <USERNAME>;
-- GRANT ROLE ROLE_TRANSFORM TO USER <USERNAME>;
-- GRANT ROLE ROLE_REPORT TO USER <USERNAME>;


------------------
-- TEST JSON LOAD
------------------
USE ROLE ROLE_INGEST; 
USE WAREHOUSE WAREHOUSE_INGEST;
CREATE OR REPLACE SCHEMA RAW.SOURCE_NAME;

CREATE TABLE RAW.SOURCE_NAME.WEATHER (jsondata VARIANT);

INSERT INTO WEATHER
  SELECT PARSE_JSON(column1)
  FROM VALUES
  ('{       
  "currently": {
        "apparentTemperature": 70.97,
        "cloudCover": 0.39,
        "dewPoint": 45.56,
        "humidity": 0.4,
        "icon": "partly-cloudy-night",
        "ozone": 310.66,
        "precipIntensity": 0,
        "precipProbability": 0,
        "pressure": 1005.44,
        "summary": "Partly Cloudy",
        "temperature": 70.97,
        "time": 1528919028,
        "uvIndex": 0,
        "visibility": 10,
        "windBearing": 141,
        "windGust": 6.28,
        "windSpeed": 1.82
  },
  "latitude": 43.6532,
  "longitude": 79.3832
}');

SELECT * FROM WEATHER;


-- ------------------
-- -- TEST JSON TRANSFORM
-- ------------------
USE ROLE ROLE_TRANSFORM; 
USE WAREHOUSE WAREHOUSE_TRANSFORM;
CREATE OR REPLACE SCHEMA ANALYTICS.BUSINESS;

-- This query will provide you with the path to extract every key’s value. 
-- This can be extremely important because due to JSON’s structure, if you call the path incorrectly when trying to build your view, you will receive NULL values.
-- We don't use this query, but we do have a look to make sure we find all the fields we want to extract. 
-- Key is the RECURSIVE=>TRUE flag
CREATE OR REPLACE TABLE ANALYTICS.BUSINESS.WEATHER_FLATTEN_ALL AS (
    SELECT * FROM
        (SELECT 
        jsondata AS JSON_FIELD 
        FROM RAW.SOURCE_NAME.WEATHER) V,
        TABLE(FLATTEN(INPUT=>V.JSON_FIELD, RECURSIVE=>TRUE)) F
    WHERE F.KEY IS NOT NULL);

SELECT * FROM WEATHER_FLATTEN_ALL;

CREATE OR REPLACE VIEW VW_WEATHER AS(
    SELECT
    jsondata:latitude::float Latitude,
    jsondata:longitude::float Longitude,
    Jsondata:currently.summary::string DailySummary,
    jsondata:currently.temperature::float Temperature,
    jsondata:currently.dewPoint::float DewPoint,
    jsondata:currently.humidity::float Humidity
    FROM RAW.SOURCE_NAME.WEATHER);

SELECT * FROM VW_WEATHER;

