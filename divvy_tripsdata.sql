--Combining in a single table
SELECT *
INTO divvy_tripdata
FROM (
    SELECT *
    FROM [master].[dbo].[202004-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202005-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202006-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202007-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202008-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202009-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202010-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202011-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202012-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202101-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202102-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202103-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202104-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202105-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202106-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202107-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202108-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202109-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202110-divvy-tripdata]
    UNION
    SELECT *
    FROM [master].[dbo].[202111-divvy-tripdata]
    
) AS trips_data

--casual riders prefers which bike the most
SELECT 
    COUNT(rideable_type) AS num_of_bikes,
    rideable_type
FROM divvy_tripdata 
WHERE member_casual = 'casual'
GROUP BY
    rideable_type

-- Annual members use which bike the most
SELECT 
    rideable_type,
    COUNT(rideable_type) AS num_of_bikes
FROM divvy_tripdata 
WHERE member_casual = 'member'
GROUP BY
    rideable_type


--CLEANING (ride_id)

SELECT LEN(ride_id)
FROM divvy_tripdata

SELECT ride_id
FROM divvy_tripdata
WHERE LEN(ride_id) != 16


-- CLEANING (rideable_type)

SELECT rideable_type
FROM divvy_tripdata
WHERE 
    rideable_type IS NULL

-- Checking  bikes types
SELECT DISTINCT rideable_type
FROM dbo.divvy_tripdata


-- CLEANING (started_at, ended_at)

SELECT started_at
FROM divvy_tripdata
WHERE
    started_at IS NULL

-- separating date and checking removing started_date > ended_date
SELECT 
    CAST(started_at AS date) AS started_date,
    CAST(ended_at AS date) AS ended_date,
    IIF(CAST(started_at AS date) > CAST(ended_at AS date), 'Y', '.') AS checking,
    start_station_id,
    end_station_id,
    member_casual
FROM divvy_tripdata
WHERE 
    CAST(started_at AS date) > CAST(ended_at AS date)


-- delete rows started_at
SELECT 
    started_at,
    ended_at,
    CAST(ended_at AS datetime) - CAST(started_at AS datetime)
FROM divvy_tripdata
WHERE 
    start_station_id = '638' AND end_station_id = '41.93-87.7'


-- Checking length of started at
SELECT LEN(started_at)
FROM divvy_tripdata

SELECT started_at
FROM divvy_tripdata
WHERE LEN(started_at) != 27

-- Checking length of ended_at
SELECT LEN(ended_at)
FROM divvy_tripdata

SELECT ended_at
FROM divvy_tripdata
WHERE LEN(ended_at) != 27


-- CLEANING (start_station_name)
-- removing nulls (start_station_name)
SELECT 
    start_station_id,
    start_station_name,
    start_lat,
    start_lng
FROM divvy_tripdata
WHERE 
    start_station_name IS NULL AND start_station_id IS NOT NULL


-- getting station names
SELECT 
    start_station_id,
    start_station_name,
    start_lat
FROM divvy_tripdata
WHERE
    start_station_id = 'WL-008' 

--Filling the NULL with values
UPDATE divvy_tripdata
SET start_station_name = 'Wood St & Milwaukee Ave'
WHERE start_station_id = '13221' AND start_station_name IS NULL
 
UPDATE divvy_tripdata
SET start_station_name = 'Hegewisch Metra Station'
WHERE start_station_id = '20215' AND start_station_name IS NULL

UPDATE divvy_tripdata
SET start_station_name = 'Clinton St & Roosevelt Rd'
WHERE start_station_id = 'WL-008' AND start_station_name IS NULL

-- removing remaining NULL




--CLEANING (start_lat, start_lng)
SELECT start_lat, start_station_name, start_station_name
FROM divvy_tripdata
WHERE start_lat IS NULL

SELECT start_lng, start_station_name, start_station_name
FROM divvy_tripdata
WHERE start_lng IS NULL




-- CLEANING (end_lat)
SELECT end_lat, end_station_name, end_station_id, end_lng
FROM divvy_tripdata
WHERE 
    end_lat IS NULL 

-- there is no end address
SELECT end_lat, end_station_name, end_station_id, end_lng
FROM divvy_tripdata
WHERE 
    end_lat IS NULL AND end_station_name IS NOT NULL AND end_station_id is NOT NULL AND end_lng IS NOT NULL

--delete rows
DELETE divvy_tripdata
WHERE 
    end_lat IS NULL AND
    end_station_name IS NULL AND
    end_station_id IS NULL AND
    end_lng IS NULL

-- remaning NULL (end_stn_name, end_stn_id)
SELECT end_station_name, end_lat, end_lng
FROM divvy_tripdata
WHERE end_lat = 41.91 AND end_lng = -87.7 AND end_station_name IS NOT NULL

UPDATE divvy_tripdata
SET end_station_name = 'Francisco Ave & Bloomingdale Ave'
WHERE end_lat = 41.91 AND end_lng = -87.7 AND end_station_name IS NULL

-- Updated (end_station_name) with lat, lng
UPDATE divvy_tripdata
SET end_station_name = CONCAT(end_lat, end_lng)
WHERE
    end_station_name IS NULL


--Updated (start_stn_name) with lat, lon
UPDATE divvy_tripdata
SET start_station_name = CONCAT(start_lat, start_lng)
WHERE
    start_station_name IS NULL


-- Updated (start_stn_id) with lat, lon
UPDATE divvy_tripdata
SET start_station_id = CONCAT(start_lat, start_lng)
WHERE
    start_station_id IS NULL

--Updating (end_stn_id) with lat, lon
UPDATE divvy_tripdata 
SET end_station_id = CONCAT(end_lat, end_lng)
WHERE
    end_station_id IS NULL

--Calculating (ride_length)

SELECT 
    DATEDIFF(MINUTE, CAST(started_at AS time), CAST(ended_at AS time)) ride_length,
    started_at,
    ended_at
FROM divvy_tripdata

--adding column (ride_length)
ALTER TABLE divvy_tripdata
ADD ride_length bigint

-- Updating values (ride_length)
UPDATE divvy_tripdata
SET ride_length = DATEDIFF(MINUTE, started_at, ended_at)

--Checking (ride_length <= 0 )
SELECT 
    ride_length,
    started_at,
    ended_at
FROM 
    divvy_tripdata
WHERE
    ride_length <= 0

--Delete (ride_length <= 0)
DELETE divvy_tripdata
WHERE
    ride_length <= 0


--Adding new column
ALTER TABLE divvy_tripdata
ADD day_of_week VARCHAR (50)

--Adding values 
UPDATE divvy_tripdata
SET day_of_week = DATENAME(WEEKDAY, started_at)


--Average ride_length
SELECT 
    AVG(ride_length) AS avg_ride_length
FROM divvy_tripdata
WHERE
    member_casual = 'member'

SELECT 
    AVG(ride_length) AS avg_ride_length
FROM divvy_tripdata
WHERE
    member_casual = 'casual'

--Max ride_length
SELECT MAX(ride_length) AS Max_ride_length
FROM divvy_tripdata

--Checking top 10 values
SELECT TOP 10 *
FROM divvy_tripdata




