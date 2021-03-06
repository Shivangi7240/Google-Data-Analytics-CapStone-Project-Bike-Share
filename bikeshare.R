---
  title: "Data Analyst Capstone"
author: "Atakan K�REZ"
date: "05 11 2021"
output:
  pdf_document: default
html_document: default
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Case Study: How Does a Bike-Share Navigate Speedy Success?

The purpose of this document is to consolidate downloaded Divvy data into a single dataframe and then conduct simple analysis to help answer the key question: "In what ways do members and casual riders use Divvy bikes differently?"

### Introduction
This exploratory analysis case study is towards Capstome project requirement for [Google Data Analytics Professional Certificate](https://www.coursera.org/professional-certificates/google-data-analytics). The case study involves a bikeshare company's data of its customer's trip details over a 12 month period (November 2020 - October 2021). The data has been made available by Motivate International Inc. under this [license](https://www.divvybikes.com/data-license-agreement).

The analysis will follow the 6 phases of the Data Analysis process: Ask, Prepare, Process, Analyze, and Act. A brief explanation of these processes:
  
  #### Ask
  
  - Ask effective questions
- Define the scope of the analysis
- Define what success looks like

#### Prepare

- Verify data's integrity
- Check data credibility and reliability
- Check data types
- Merge datasets

#### Process

- Clean, Remove and Transform data
- Document cleaning processes and results

#### Analyze

- Identify patterns
- Draw conclusions
- Make predictions

#### Share

- Create effective visuals
- Create a story for data
- Share insights to stakeholders

#### Act

- Give recommendations based on insights
- Solve problems
- Create something new

<br/>
  
  ### 1. Ask
  
  
  #### Scenario
  
  Marketing team needs to design marketing strategies aimed at converting casual riders into annual members. In order to do that, however, the marketing analyst team needs to better understand how annual members and casual riders differ.

#### Stakeholders:

- Director of marketing
- Cyclistic executive team

##### Objective

Hence, the objective for this analysis is to throw some light on how the two types of customers: annual members and casual riders, use Cyclistic bikeshare differently, based on few parameters that can be calculated/ obtained from existing data.

#### Deliverables:

- Insights on how annual members and casual riders use Cyclistic bikes differently
- Provide effective visuals and relevant data to support insights
- Use insights to give three recommendations to convert casual riders to member riders

<br/>
  
  ### 2. Prepare
  
  #### Data Source
  
  A total of **12 CSV files** have been made available for each month starting from **November 2020 to October 2021**. Each file captures the details of every ride logged by the customers of Cyclistic. This data that has been made publicly available has been scrubbed to omit rider's personal information.

The combined size of all the 12 CSV files is close to 950 MB. Data cleaning in spreadsheets will be time-consuming and slow compared to R. I am choosing R simply because I could do both data wrangling and analysis/ visualizations in the same platform. 

<br/>

#### Load Libraries

```{r}
library(tidyverse)
library(ggplot2)
library(lubridate)
library(dplyr)
library(readr)
library(janitor)
library(data.table)
library(tidyr)
```

<br/>

#### Load dataset CSV files (Previous 12 months of Cyclistic trip data)
```{r}
tripdata_202011 <- read.csv("~/Data_Analytics_Capstone/202011-divvy-tripdata.csv")
tripdata_202012 <- read.csv("~/Data_Analytics_Capstone/202012-divvy-tripdata.csv")
tripdata_202101 <- read.csv("~/Data_Analytics_Capstone/202101-divvy-tripdata.csv")
tripdata_202102 <- read.csv("~/Data_Analytics_Capstone/202102-divvy-tripdata.csv")
tripdata_202103 <- read.csv("~/Data_Analytics_Capstone/202103-divvy-tripdata.csv")
tripdata_202104 <- read.csv("~/Data_Analytics_Capstone/202104-divvy-tripdata.csv")
tripdata_202105 <- read.csv("~/Data_Analytics_Capstone/202105-divvy-tripdata.csv")
tripdata_202106 <- read.csv("~/Data_Analytics_Capstone/202106-divvy-tripdata.csv")
tripdata_202107 <- read.csv("~/Data_Analytics_Capstone/202107-divvy-tripdata.csv")
tripdata_202108 <- read.csv("~/Data_Analytics_Capstone/202108-divvy-tripdata.csv")
tripdata_202109 <- read.csv("~/Data_Analytics_Capstone/202109-divvy-tripdata.csv")
tripdata_202110 <- read.csv("~/Data_Analytics_Capstone/202110-divvy-tripdata.csv")
```

<br/>

#### Data transformation and cleaning

start_station_id & end_station_id are not consistent in one CSV file. The ones in tripdata_202011 is int vs. the others are char. Convert the inconsistent ones from int to char datatype.


```{r}
tripdata_202011 <- tripdata_202011 %>% mutate(start_station_id = as.character(start_station_id), end_station_id = as.character(end_station_id))
```

<br />

### 3. Process

Combine all the datasets into one single dataframe

```{r}
all_trips <- bind_rows(tripdata_202011,tripdata_202012,tripdata_202101,tripdata_202102,tripdata_202103,tripdata_202104,tripdata_202105,tripdata_202106,tripdata_202107,tripdata_202108,tripdata_202109,  tripdata_202110)

str(all_trips)
```

#### Clean-up further!
Hold on! started_at & ended_at should be in datetime datatype instead of char. Convert all from char to datetime.

```{r}
all_trips[['started_at']] <- ymd_hms(all_trips[['started_at']])
all_trips[['ended_at']] <- ymd_hms(all_trips[['ended_at']])
```

<br/>

#### Remove columns not required or beyond the scope of project

```{r}
all_trips <- all_trips %>%
  select(-c(start_lat:end_lng))

glimpse(all_trips)
```

<br/>

#### Rename columns for better readability
```{r}
all_trips <- all_trips %>%
  rename(ride_type = rideable_type, 
         start_time = started_at,
         end_time = ended_at,
         customer_type = member_casual)

glimpse(all_trips)
```


<br/>

```{r}
# column for day of the week the trip started
all_trips$day_of_the_week <- format(as.Date(all_trips$start_time),'%a')
```


```{r}
# column for month when the trip started
all_trips$month <- format(as.Date(all_trips$start_time),'%b_%y')
```


```{r}
# The time is then converted back to POSIXct with today's date - the date is of no interest to us,only the hours-minutes-seconds are.
all_trips$time <- format(all_trips$start_time, format = "%H:%M")
all_trips$time <- as.POSIXct(all_trips$time, format = "%H:%M")
```


```{r}
# column for trip duration in min
all_trips$trip_duration <- (as.double(difftime(all_trips$end_time, all_trips$start_time)))/60
```


```{r}
# check the dataframe
glimpse(all_trips)
```

<br/>

Let's check to see if the trip_duration column has any negative values, as this may cause problem while creating visualizations. Also, we do not want to include the trips that were part of quality tests by the company. These trips are usually identified by string 'test' in the start_station_name column.


```{r}
# checking for trip lengths less than 0
nrow(subset(all_trips,trip_duration < 0))
```

```{r}
#checking for testrides that were made by company for quality checks
nrow(subset(all_trips, start_station_name %like% "TEST"))
nrow(subset(all_trips, start_station_name %like% "test"))
nrow(subset(all_trips, start_station_name %like% "Test"))
```

As there are 1393 rows with trip_dration less than 0 mins and 105 trips that were test rides, we will remove these observations from our dataframe as they contribute to only about 0.3% of the total rows. We will create a new dataframe deviod of these obseravtions without making any changes to the existing dataframe.  

```{r}
# remove negative trip durations 
all_trips_v2 <- all_trips[!(all_trips$trip_duration < 0),]

#remove test rides
all_trips_v2<- all_trips_v2[!((all_trips_v2$start_station_name %like% "TEST" | all_trips_v2$start_station_name %like% "test")),]

#check dataframe
glimpse(all_trips_v2)
```

It is important to make sure that customer_type column has only two distinct values. Let's confirm the same.

```{r}
# checking count of distinct values
table(all_trips_v2$customer_type)

#aggregating total trip duration by customer type
setNames(aggregate(trip_duration ~ customer_type, all_trips_v2, sum), c("customer_type", "total_trip_duration(mins)"))

```

<br/>

### 4&5. Analyze and Share Data

The dataframe is now ready for descriptive analysis that will help us uncover some insights on how the casual riders and members use Cyclistic rideshare differently.

First, let's try to get some simple statistics on trip_duration for all customers, and do the same by customer_type.

```{r}
# statictical summary of trip_duration for all trips
summary(all_trips_v2$trip_duration)
```

```{r}
#statistical summary of trip_duration by customer_type
all_trips_v2 %>%
  group_by(customer_type) %>%
  summarise(min_trip_duration = min(trip_duration),max_trip_duration = max(trip_duration),
            median_trip_duration = median(trip_duration), mean_trip_duration = mean(trip_duration))
```

The mean trip duration of member riders is lower than the mean trip duration of all trips, while it is exactly the opposite for casual riders, whose mean trip duration is higher than the the mean trip duration of all trips. This tells us that casual riders usually take the bikes out for a longer duration compared to members.

<br/>
  
  #### Total number of trips by customer type and day of the week
  ```{r}
# fix the order for the day_of_the_week and month variable so that they show up in the same sequence in output tables and visualizations
all_trips_v2$day_of_the_week <- ordered(all_trips_v2$day_of_the_week, levels=c("Pzt", "Sal", "�ar", "Per", "Cum", "Cmt", "Paz"))

all_trips_v2$month <- ordered(all_trips_v2$month, levels=c("Kas_20","Ara_20","Oca_21","Sub_21","Mar_21",                      "Nis_21", "May_21","Haz_21","Tem_21", "Agu_21",                    "Eyl_21","Eki_21"))

#Total number of trips by customer type and day of the week

all_trips_v2 %>% 
  group_by(customer_type, day_of_the_week) %>%  
  summarise(number_of_rides = n(),average_duration_mins = mean(trip_duration)) %>% 
  arrange(customer_type, desc(number_of_rides))
```


#### Visualization
```{r}
#Total trips by customer type Vs. Day_of_Week
all_trips_v2 %>%  
  group_by(customer_type, day_of_the_week) %>% 
  summarise(number_of_rides = n()) %>% 
  arrange(customer_type, day_of_the_week)  %>% 
  ggplot(aes(x = day_of_the_week, y = number_of_rides, fill = customer_type)) +
  labs(title ="Total trips by customer type Vs. Day of the week") +
  geom_col(width=0.5, position = position_dodge(width=0.5)) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE))
```

From the table and graph above, casual customers are most busy on Sundays followed by Saturdays, while members are most busy on later half of the week extending into the weekend. Interesting pattern to note though is the consistent trip numbers among members with less spread over entire week as compared to casual riders who don't seem to use the bikeshare services much during weekdays.

<br/>

#### Average number of trips by customer type and month
```{r}
all_trips_v2 %>% 
  group_by(customer_type, month) %>%  
  summarise(number_of_rides = n(),`average_duration_(mins)` = mean(trip_duration)) %>% 
  arrange(customer_type,desc(number_of_rides))
```


#### Visualization
```{r}
#Total trips by customer type Vs. Month
all_trips_v2 %>%  
  group_by(customer_type, month) %>% 
  summarise(number_of_rides = n()) %>% 
  arrange(customer_type, month)  %>% 
  ggplot(aes(x = month, y = number_of_rides, fill = customer_type)) +
  labs(title ="Total trips by customer type Vs. Month") +
  theme(axis.text.x = element_text(angle = 30)) +
  geom_col(width=0.5, position = position_dodge(width=0.5)) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE))
```

The data shows that the months of July, August, September and October are the most busy time of the year among both members and casual riders. This could be attributed to an external factor (eg. cold weather, major quality issue) that might have hindered with customer needs. 2021 is a tough year when Covid comes. People care more about their health. The charts shows that the no.of rides in 2021 is higher than 2020 in general. However, the number of trips made by members is always higher than the casual riders across all months of the year.

<br/>

#### Visualizaton of average trip duration by customer type on each day of the week

```{r}
all_trips_v2 %>%  
  group_by(customer_type, day_of_the_week) %>% 
  summarise(average_trip_duration = mean(trip_duration)) %>%
  ggplot(aes(x = day_of_the_week, y = average_trip_duration, fill = customer_type)) +
  geom_col(width=0.5, position = position_dodge(width=0.5)) + 
  labs(title ="Average trip duration by customer type Vs. Day of the week")

```

The average trip duration of a casual rider is more than twice that of a member. Note that this necessarily does not mean that casual riders travel farther distance. It is also interesting to note that weekends not only contribute to more number of trips but also longer trips on average when compared to weekdays.


<br/>

#### Visualizaton of average trip duration by customer type Vs. month
```{r}
all_trips_v2 %>%  
  group_by(customer_type, month) %>% 
  summarise(average_trip_duration = mean(trip_duration)) %>%
  ggplot(aes(x = month, y = average_trip_duration, fill = customer_type)) +
  geom_col(width=0.5, position = position_dodge(width=0.5)) + 
  labs(title ="Average trip duration by customer type Vs. Month") +
  theme(axis.text.x = element_text(angle = 30))
```

Average trip duration of member riders is anywhere between 10-30 minutes throughout the year, exception being February when it goes slightly over 20 minutes. However, there seems to be a distinct pattern when it comes to casual riders, whose average trip duration swings wildly from as low as ~25 minutes to more than an hour depending on time of the year. It is worth noting unusually long trip durations by casual riders in the month of February.

<br/>

#### Visualizaton of bike demand over 24 hr period (a day)
```{r}
all_trips_v2 %>%  
  group_by(customer_type, time) %>% 
  summarise(number_of_trips = n()) %>%
  ggplot(aes(x = time, y = number_of_trips, color = customer_type, group = customer_type)) +
  geom_line() +
  scale_x_datetime(date_breaks = "1 hour", minor_breaks = NULL,
                   date_labels = "%H:%M", expand = c(0,0)) +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title ="Demand over 24 hours of a day", x = "Time of the day")
```

For the members, there seems to be two distict peak demand hours: 7-9 AM and 5-7 PM, the latter one coinciding with the peak demand hours of casual riders as well. One could probably hypothesize that office-goers make up majority of the members profile due to demand in both morning and evening hours, but we need more data to substabtiate this assumption.

<br/>

#### Visualizaton of ride type Vs. number of trips by customer type
```{r}
all_trips_v2 %>%
  group_by(ride_type, customer_type) %>%
  summarise(number_of_trips = n()) %>%  
  ggplot(aes(x= ride_type, y=number_of_trips, fill= customer_type))+
  geom_bar(stat='identity') +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  labs(title ="Ride type Vs. Number of trips")
```

Classic bikes are predominantly used by members. Docked bikes are almost never used compared to others. Electric bikes are equally used by both members as well as casual riders. If docked bikes cost the highest among all 3 types, it would be a financially sound move to increase their fleet while reducing docked bikes, as they are already preferred by members who make up for the majority of the trips.

<br/>

### 6. Act

#### Important Findings
- Casual riders made 41% of total trips contributing to 66% of total trip duration between Nov'20 - Oct'21. Member riders make up 59% of total trips contributing to 34% of total trip duration between Nov'20 - Oct'21

- Usage (based on trip duration) of bikes by casual riders is almost twice that of member riders.

- Casual customers use bikeshare services more during weekends, while members use them consistently over the entire week.

- Average trip duration of casual riders is more than twice that of member rider over any given day of the week cumulatively.

- Casual riders ride longer during first half of the year compared to the second half, while members clock relatively similar average trip duration month over month.

- Casual riders prefer electric bikes the most while classic bikes are popular among members.

<br/>

### Recommendations

- Provide attractive promotions for casual riders on weekdays so that casual members use the bikeshare services ore uniformly across the entire week.

- Offer discounted membership fee for renewals after the first year. It might nudge casual riders to take up membership.

- Offer discounted pricing during non-busy hours so that casual riders might choose to use bikes more often and level out demand over the day.

### Additonal data that could expand scope of analysis

- Age and gender profile - Again, this data could be used to study the category of riders who can be targeted for attracting new members.

- Address/ neighborhood details of members to investigate if there are any location specific parameters that encourage membership.

- Pricing details for members and casual riders - Based on this data, we might be to optimize cost structure for casual riders or provide discounts without affecting the profit margin.



