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
            