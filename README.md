This repository documents my data analysis project on Cyclistic’s 2024 bike-share data. The objective was to explore usage patterns among different rider types, clean and transform the data, and finally perform structural and exploratory analysis leading to meaningful visual insights.

My broader motivation was to understand how casual riders and annual members differ in behavior across temporal and spatial variables, ultimately offering data-driven recommendations for improving service design and marketing strategy.

---

1. Setting Up the Working Environment**

I began by setting the working directory and loading the required libraries:

```r
setwd("~/Desktop/Data Analysis/2024_bike_data")
library(tidyverse)
```

I used `tidyverse` due to its modular capabilities in data wrangling, visualization, and functional programming.

---

2. Importing and Combining Multiple CSV Files

Because the dataset consisted of twelve separate monthly CSV files, I used `list.files()` to dynamically locate all files and `map_dfr()` to merge them into one unified data frame.

```r
files <- list.files(pattern = "*.csv", full.names = TRUE)

combined_data <- files %>%
    map_dfr(read_csv)
```

This produced 5,860,568 observations**, confirming successful aggregation.

---

3. Challenges Encountered in Data Cleaning

Initially, I attempted to replace empty strings and drop NA values globally, but encountered errors caused by mismatched column types (especially date-time columns).

Example failed approach:

```r
bike_ride <- combined_data %>%
    mutate(across(everything(), ~na_if(., ""))) %>%
    drop_na()
```

Cause of Error:** `na_if()` attempted to coerce datetime fields into character strings.

**Solution Implemented:

I restricted replacement to only character columns:

```r
bike_ride <- combined_data %>%
    mutate(across(where(is.factor), as.character)) %>%
    mutate(across(where(is.character), ~ na_if(., ""))) %>%
    drop_na()
```

After cleaning, the dataset reduced from **5.86M rows to 4.2M rows**, ensuring only valid ride entries remained.

---

4. Feature Engineering

To enable temporal analysis, I created new columns:

```r
bike_ride <- bike_ride %>%
    mutate(
        start_day = wday(started_at, label = TRUE, abbr = FALSE),
        start_time = format(started_at, "%H:%M:%S"),
        start_hour = hour(started_at),
        end_time = format(ended_at, "%H:%M:%S")
    )
```

I also computed ride duration:

```r
bike_ride <- bike_ride %>%
    mutate(
        ride_duration = as.numeric(difftime(ended_at, started_at, units = "mins")),
        ride_duration = if_else(ride_duration < 0, ride_duration + 24 * 60, ride_duration),
        ride_duration = ceiling(ride_duration)
    )
```

Finally, I saved the cleaned dataset:

```r
write_csv(bike_ride, "~/Desktop/Data Analysis/2024_bike_data/bike_ride_final_table.csv")
```

---

5. Structural Analysis

I performed eight analytic summaries focused on user type, time patterns, and ride characteristics.

#### **a. Total rides by user type

```r
total_rides <- bike_ride %>%
    group_by(member_casual) %>%
    summarise(total_rides = n())
```
b. Average ride duration

```r
avg_ride_length <- bike_ride %>%
    group_by(member_casual) %>%
    summarise(avg_ride_length = mean(ride_duration, na.rm = TRUE))
```

c. Ride demand by hour

```r
bike_demand_hour <- bike_ride %>%
    group_by(start_hour) %>%
    summarise(total_rides = n()) %>%
    arrange(start_hour)
```

d. Ride demand by day

```r
bike_demand_day <- bike_ride %>%
    group_by(start_day) %>%
    summarise(total_rides = n())
```

e. Ride demand by day & user type

```r
bike_demand_day_usertype <- bike_ride %>%
    group_by(start_day, member_casual) %>%
    summarise(total_rides = n(), .groups = "drop")
```

f. Ride demand by month

```r
bike_demand_month <- bike_ride %>%
    mutate(month = month(started_at, label = TRUE, abbr = FALSE)) %>%
    group_by(month) %>%
    summarise(total_rides = n())
```

g. Ride demand by month & user type

```r
bike_demand_month_usertype <- bike_ride %>%
    mutate(month = month(started_at, label = TRUE, abbr = FALSE)) %>%
    group_by(month, member_casual) %>%
    summarise(total_rides = n(), .groups = "drop")
```

h. Ride usage by bike type

```r
total_ride_type <- bike_ride %>%
    group_by(rideable_type) %>%
    summarise(total_rides = n())
```

---

6. Key Analytical Insights

| Metric             | Casual Riders | Members          | Interpretation                      |
| ------------------ | ------------- | ---------------- | ----------------------------------- |
| Ride frequency | Lower         | Higher           | Members ride more consistently      |
| Ride duration  | Longer        | Shorter          | Casual riders use bikes for leisure |
| Peak activity  | Weekends      | Weekdays         | Members are commute-driven          |
| Peak hours     | 10am–6pm      | 7am–9am, 4pm–6pm | Members match work hours            |

These findings support a marketing strategy aimed at converting casual riders into subscribers through targeted incentives on weekends and leisure routes.

---

7. Next Steps
Dashboard deployment using Excell

---

Conclusion

This project strengthened my proficiency in large-scale data wrangling, temporal feature engineering, and applied analytics. The workflow evolved iteratively, requiring several debugging steps before achieving final insights, reflecting a realistic data-science process rather than a linear pipeline.
