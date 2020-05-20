#!/usr/bin/env Rscript
library(dplyr)
library(lubridate)

#Read data
tflow <- read.csv("C:/Users/Sotex/Uni/CSC/trabalho/Traffic_Flow_Speed_Prediction/Datasets/Braga_Data/Traffic_Flow_Braga_Until_20191231.csv", encoding = 'utf-8')
incidents <- read.csv("C:/Users/Sotex/Uni/CSC/trabalho/Traffic_Flow_Speed_Prediction/Datasets/Braga_Data/Traffic_Incidents_Braga_Until_20191231.csv", encoding = 'utf-8')
weather <- read.csv("C:/Users/Sotex/Uni/CSC/trabalho/Traffic_Flow_Speed_Prediction/Datasets/Braga_Data/Weather_Braga_Until_20191231.csv", encoding = 'utf-8')
weatherD <- read.csv("C:/Users/Sotex/Uni/CSC/trabalho/Traffic_Flow_Speed_Prediction/Datasets/Braga_Data/Weather_Description.csv", encoding = 'utf-8')

#Remove city_name column
tflow$city_name <- NULL
incidents$city_name <- NULL
weather$city_name <- NULL
weatherD$city_name <- NULL

#Split date time into Year, Month, Day, Hour, Minute
teste <- within(tflow,{
  Year <- as.numeric(substr(tflow$creation_date, 1, 4))
  Month <- as.numeric(substr(tflow$creation_date, 6, 7))
  Day <- as.numeric(substr(tflow$creation_date, 9, 10))
  
  Hour <- as.numeric(substr(tflow$creation_date, 12, 13))
  Minute <- as.numeric(substr(tflow$creation_date, 15, 16))
})

testeIncidents <- within(incidents,{
  Year <- as.numeric(substr(incidents$incident_date, 1, 4))
  Month <- as.numeric(substr(incidents$incident_date, 6, 7))
  Day <- as.numeric(substr(incidents$incident_date, 9, 10))
  
  Hour <- as.numeric(substr(incidents$incident_date, 12, 13))
  Minute <- as.numeric(substr(incidents$incident_date, 15, 16))
})

tempo <- within(weather,{
  Year <- as.numeric(substr(weather$creation_date, 1, 4))
  Month <- as.numeric(substr(weather$creation_date, 6, 7))
  Day <- as.numeric(substr(weather$creation_date, 9, 10))
  
  Hour <- as.numeric(substr(weather$creation_date, 12, 13))
  Minute <- as.numeric(substr(weather$creation_date, 15, 16))
})

tempoD <- within(weatherD,{
  Year <- as.numeric(substr(weatherD$creation_date, 1, 4))
  Month <- as.numeric(substr(weatherD$creation_date, 6, 7))
  Day <- as.numeric(substr(weatherD$creation_date, 9, 10))
  
  Hour <- as.numeric(substr(weatherD$creation_date, 12, 13))
  Minute <- as.numeric(substr(weatherD$creation_date, 15, 16))
})

#Merge weather with weather data
weather_weather <- unique(merge.data.frame(tempo, tempoD, by = c( "Year", "Month", "Day", "Hour", "Minute"), all = TRUE))

#Merge dataframe with weather data
teste_weather <- unique(merge.data.frame(teste, tempo, by = c( "Year", "Month", "Day", "Hour", "Minute"), all = TRUE))


#Merge dataframes and filter by road, if it is equal to to_road or from_road
merged <- unique(merge.data.frame(teste_weather,testeIncidents, by = c("Year", "Month", "Day", "Hour", "Minute"), all = TRUE))

#Retrieving the columns names that are related with the accidents
col <- names(testeIncidents)[1:12]


#Get the row number, that are from rows not related with accidents
no_acc <- which(mapply(function(x, y, z) (!grepl(tolower(x), tolower(y), fixed = TRUE) && !grepl(tolower(x), tolower(z), fixed = TRUE)), merged$road_name, merged$from_road, merged$to_road))


#Get the row number, that are from rows related with accidents
acc <- which(mapply(function(x, y) grepl(tolower(x), tolower(y), fixed = TRUE), merged$road_name, merged$from_road)==TRUE)
acc_2 <- which(mapply(function(x, y) grepl(tolower(x), tolower(y), fixed = TRUE), merged$road_name, merged$to_road)==TRUE)
#Concat vectors
accs <- unique(c(acc, acc_2))

#Build the no accidents dataframe
no_accidents <- merged[no_acc,]
no_accidents[,col] <- NA

#Build the accidents dataframe
accidents <- merged[accs,]


#Merge dataframes and filter by road, if it is equal to to_road or from_road
for(rowNA in 1:nrow(no_accidents)){
  for(rowA in 1:nrow(accidents)){
    #if(identical(accidents$Minute[1], no_accidents$Minute[1], num.eq=TRUE) && (accidents$road_num[rowA] == no_accidents$road_num[rowNA]) &&  (accidents$Day[rowA] == no_accidents$day[rowNA]) && (accidents$Month[rowA] == no_accidents$Month[rowNA])){
    if(accidents$road_num[rowA] == no_accidents$road_num[rowNA]){
      if(accidents$Minute[rowA] == no_accidents$Minute[rowNA]){
        if(accidents$Hour[rowA] == no_accidents$Hour[rowNA]){
          if(accidents$Day[rowA] == no_accidents$Day[rowNA]){
            if(accidents$Month[rowA] == no_accidents$Month[rowNA]){
      no_accidents$magnitude_of_delay_desc[rowNA]<- accidents$magnitude_of_delay_desc[rowA]
            }
          }
        }
      }
    }
  }
}


complete <- unique(no_accidents) 

completed <- unique(rbind.data.frame(no_accidents, accidents))
completed = completed[!duplicated(completed[ , c("Year","Month", "Day", "Minute", "road_num")]),]

#Convert factors to characters
i <- sapply(complete, is.factor)
complete[i] <- lapply(complete[i], as.character)

#Sort by Year, Month, Day, Hour, Minute
sorted <- complete[order(complete$Year, complete$Month, complete$Day, complete$Hour, complete$Minute),]

#Export the generated dataframe
write.csv(x = sorted, file = "C:/Users/Sotex/Uni/CSC/trabalho/Traffic_Flow_Speed_Prediction/Datasets/sorted.csv", row.names=FALSE, fileEncoding = 'utf-8')


#Remove rows from the columns "road_name", "Hour", "Minute", "Day", "Month", that are NA
sorted_clean <- unique(sorted[which(complete.cases(sorted[,c("road_name", "Hour", "Minute", "Day", "Month", "Year")])),])
rownames(sorted_clean) <- NULL #Update index

#percetagem de trafego
sorted_clean$speed_diff = sorted_clean$current_speed / sorted_clean$free_flow_speed



#Merge dataframe with weather data
sorted_clean <- unique(merge.data.frame(sorted_clean, tempoD, by = c( "Year", "Month", "Day", "Hour", "Minute"), all = TRUE))

#Remove extra dates columns
sorted_clean$creation_date.x <- NULL
sorted_clean$creation_date.y <- NULL

#Remove some time travel columns
sorted_clean$time_diff <- NULL
sorted_clean$current_travel_time <- NULL





sunriseData <- within(sorted_clean,{
  YearSunrise <- as.numeric(substr(sorted_clean$sunrise, 1, 4))
  MonthSunrise <- as.numeric(substr(sorted_clean$sunrise, 6, 7))
  DaySunrise <- as.numeric(substr(sorted_clean$sunrise, 9, 10))
  
  HourSunrise <- as.numeric(substr(sorted_clean$sunrise, 12, 13))
})

sunriseD <- unique(sunriseData[,c("YearSunrise", "MonthSunrise", "DaySunrise", "HourSunrise")])

sunriseD = sunriseD[!duplicated(sunriseD[ , c("YearSunrise","MonthSunrise", "DaySunrise")]),]

sunsetData <- within(sorted_clean,{
  YearSunset <- as.numeric(substr(sorted_clean$sunset, 1, 4))
  MonthSunset <- as.numeric(substr(sorted_clean$sunset, 6, 7))
  DaySunset <- as.numeric(substr(sorted_clean$sunset, 9, 10))
  
  HourSunset <- as.numeric(substr(sorted_clean$sunset, 12, 13))
})

sunsetD <- unique(sunsetData[,c("YearSunset", "MonthSunset", "DaySunset", "HourSunset")])

sunsetD = sunsetD[!duplicated(sunsetD[ , c("YearSunset","MonthSunset", "DaySunset")]),]

colnames(sunriseD) <- c("Year", "Month", "Day", "HourSunrise")
colnames(sunsetD) <- c("Year", "Month", "Day", "HourSunset")

#Merge dataframe with weather data
sunR <- unique(merge.data.frame(sorted_clean, sunriseD, by = c( "Year", "Month", "Day"), all = TRUE))
sunRS <- unique(merge.data.frame(sunR, sunsetD, by = c( "Year", "Month", "Day"), all = TRUE))


#Sort by Year, Month, Day, Hour, Minute
sunRS <- sunRS[order(sunRS$Year, sunRS$Month, sunRS$Day, sunRS$Hour, sunRS$Minute, sunRS$road_num),]


#diferença de tempo entre hora atual e sunrise e sunset
sunRS <- within(sunRS,{
  SunriseHourDiff <-  sunRS$Hour - sunRS$HourSunrise
})

sunRS <- within(sunRS,{
  SunsetHourDiff <- sunRS$HourSunset - sunRS$Hour
})

sunRS$current_luminosity[!is.na(sunRS$SunriseHourDiff)]<-"LIGHT"

sunRS$current_luminosity[as.integer(sunRS$SunsetHourDiff) == 0]<- "LOW_LIGHT"
sunRS$current_luminosity[as.integer(sunRS$SunsetHourDiff) == 1]<- "LOW_LIGHT"
sunRS$current_luminosity[as.integer(sunRS$SunriseHourDiff) == 0]<- "LOW_LIGHT"
sunRS$current_luminosity[as.integer(sunRS$SunriseHourDiff) == 1]<- "LOW_LIGHT"

sunRS$current_luminosity[substr(sunRS$SunriseHourDiff, 1, 1) == "-"]<- "DARK"
sunRS$current_luminosity[substr(sunRS$SunsetHourDiff, 1, 1) == "-"]<- "DARK"



sunRS <- sunRS[complete.cases(sunRS[,c("Year", "scity_name")]),]



sunRS <- read.csv("C:/Users/Sotex/Uni/CSC/trabalho/Traffic_Flow_Speed_Prediction/Datasets/sunRS.csv", encoding = 'utf-8')

sunRS$weekday <- wday(as.Date(ISOdatetime(sunRS$Year, sunRS$Month, sunRS$Day, 0,0,0), "%Y-%m-%d"))


#Export the generated dataframe
write.csv(x = sunRS, file = "C:/Users/Sotex/Uni/CSC/trabalho/Traffic_Flow_Speed_Prediction/Datasets/sunRS.csv", row.names=FALSE, fileEncoding = 'utf-8')


#Sort by Year, Month, Day, Hour, Minute
sunRSroad <- sunRS[order(sunRS$road_num, sunRS$Year, sunRS$Month, sunRS$Day, sunRS$Hour, sunRS$Minute),]

#Export the generated dataframe
write.csv(x = sunRSroad, file = "C:/Users/Sotex/Uni/CSC/trabalho/Traffic_Flow_Speed_Prediction/Datasets/sunRSroad.csv", row.names=FALSE, fileEncoding = 'utf-8')


