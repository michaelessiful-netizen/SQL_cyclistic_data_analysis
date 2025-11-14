Select
	count(*)
from
		bike_share_analysis.bike_share_data
where
			ride_id is NULL OR
            started_at is NULL OR
            ended_at is NULL OR
            member_casual is NULL OR
            rideable_type is NULL OR
            start_station_id is NULL OR
            end_station_id is NULL OR
            end_station_name is NULL OR
            start_station_id is NULL OR
            start_station_name is NULL OR
            start_lat is NULL OR
            start_lng is NULL OR
            end_lat is NULL OR
            end_lng is NULL;
            
## Adding the column for just the time (HH:MM:SS)
ALTER TABLE bike_share_analysis.bike_share_data
ADD COLUMN start_time VARCHAR(8); 

## Adding the column for the hour (0-23)
ALTER TABLE bike_share_analysis.bike_share_data
ADD COLUMN start_hour INT;

## Adding the column for the day of the week name (SUN-SAT)
ALTER TABLE bike_share_analysis.bike_share_data
ADD COLUMN start_day VARCHAR(10);

## Updating the new columns created with data from the start_at column
UPDATE bike_share_analysis.bike_share_data
SET start_hour = HOUR(started_at);

UPDATE bike_share_analysis.bike_share_data
SET start_time = TIME(started_at);
## run into error code 1175 so I searched on google and that I have to disable safe mode
SET SQL_SAFE_UPDATES = 0;

## running the querries again after turning off the safe mode
UPDATE bike_share_analysis.bike_share_data
SET start_time = TIME(started_at);

UPDATE bike_share_analysis.bike_share_data
SET start_hour = HOUR(started_at);

UPDATE bike_share_analysis.bike_share_data
SET start_day = DAYNAME(started_at);
UPDATE bike_share_analysis.bike_share_data
SET start_time = TIME(started_at);

UPDATE bike_share_analysis.bike_share_data
SET start_hour = HOUR(started_at);

## adding. start_month column and populating it with data from started_at column
ALTER TABLE bike_share_analysis.bike_share_data
ADD COLUMN start_month VARCHAR(10);
UPDATE bike_share_analysis.bike_share_data
SET start_month = MONTHNAME(started_at);

## creating a new column end_time to help calculate ride duration
ALTER TABLE bike_share_analysis.bike_share_data
ADD COLUMN end_time varchar(8);

UPDATE bike_share_analysis.bike_share_data
SET end_time = TIME(ended_at);

## creating a new column ride_duration 
ALTER TABLE bike_share_analysis.bike_share_data
ADD COLUMN ride_duration INT;

UPDATE bike_share_analysis.bike_share_data
SET ride_duration = 
	CASE 
		WHEN timestampdiff(minute, started_at, ended_at) <0
        THEN timestampdiff(minute, started_at, ended_at) + 1440
        ELSE timestampdiff(minute, started_at, ended_at)
    END;    
    
## Data Aggregation
## Average ride length (casual/ members), Bike demand by hour, day, and month, total ride demand (memebrs/casual)    
# Average ride duration
SELECT
    member_casual,
    AVG(ride_duration) AS avg_ride_length_minutes
FROM
    bike_share_analysis.bike_share_data
GROUP BY
    member_casual;

## Bike demand per hour    
SELECT
    start_hour,
    COUNT(ride_id) AS total_rides
FROM
    bike_share_analysis.bike_share_data
GROUP BY
    start_hour
ORDER BY
    start_hour;

## Bike demand by day
SELECT
    start_day,
    COUNT(ride_id) AS total_rides
FROM
    bike_share_analysis.bike_share_data
GROUP BY
    start_day
ORDER BY
    FIELD(start_day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

## Bike demand by Month
SELECT
    start_month,
    COUNT(ride_id) AS total_rides
FROM
    bike_share_analysis.bike_share_data
GROUP BY
    start_month
ORDER BY
    FIELD(start_month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
    
## total ride demand (member/casual)
SELECT
    member_casual,
    COUNT(ride_id) AS total_rides_by_type
FROM
    bike_share_analysis.bike_share_data
GROUP BY
    member_casual;
    
## Aggregation by user types
## by hour
SELECT
    start_hour,
    member_casual,
    COUNT(ride_id) AS total_rides
FROM
    bike_share_analysis.bike_share_data
GROUP BY
    start_hour, member_casual
ORDER BY
    start_hour, member_casual;

## by day 
SELECT
    start_day,
    member_casual,
    COUNT(ride_id) AS total_rides
FROM
    bike_share_analysis.bike_share_data
GROUP BY
    start_day, member_casual
ORDER BY
    FIELD(start_day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'), member_casual;

## By Month
SELECT
    start_month,
    member_casual,
    COUNT(ride_id) AS total_rides
FROM
    bike_share_analysis.bike_share_data
GROUP BY
    start_month, member_casual
ORDER BY
    FIELD(start_month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'), member_casual;
    
## Average ride_duration by day    
SELECT
    start_day,
    member_casual,
    AVG(ride_duration) AS avg_ride_length_minutes
FROM
    bike_share_analysis.bike_share_data
GROUP BY
    start_day, member_casual
ORDER BY
    FIELD(start_day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'), member_casual;
    
## data aggregation by ride trpe    
SELECT
    rideable_type,
    COUNT(ride_id) AS total_rides
FROM
    bike_share_analysis.bike_share_data
GROUP BY
    rideable_type
ORDER BY
    total_rides DESC;

SELECT
    start_month,
    rideable_type,
    COUNT(ride_id) AS total_rides
FROM
    bike_share_analysis.bike_share_data
GROUP BY
    start_month, rideable_type
ORDER BY
    FIELD(start_month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'),
    total_rides DESC;
            
