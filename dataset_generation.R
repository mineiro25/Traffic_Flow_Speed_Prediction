#!/usr/bin/env Rscript
library(dplyr)

#Read data
tflow <- read.csv("C:/Users/Nuno/Desktop/Traffic_Flow_Speed_Prediction/Datasets/Braga_Data/Traffic_Flow_Braga_Until_20191231.csv", encoding = 'utf-8')
incidents <- read.csv("C:/Users/Nuno/Desktop/Traffic_Flow_Speed_Prediction/Datasets/Braga_Data/Traffic_Incidents_Braga_Until_20191231.csv", encoding = 'utf-8')
weather <- read.csv("C:/Users/Nuno/Desktop/Traffic_Flow_Speed_Prediction/Datasets/Braga_Data/Weather_Braga_Until_20191231.csv", encoding = 'utf-8')

#Remove city_name column
tflow$city_name <- NULL
incidents$city_name <- NULL
weather$city_name <- NULL

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

#Truncate Minute values
teste[which(teste[,"Minute"] < 20), "Minute"] <- 0
teste[which(20<=teste$Minute & teste$Minute<40),"Minute"] <- 20
teste[which(40<=teste$Minute & teste$Minute<60),"Minute"] <- 40

testeIncidents[which(testeIncidents[,"Minute"] < 20), "Minute"] <- 0
testeIncidents[which(20<=testeIncidents$Minute & testeIncidents$Minute<40),"Minute"] <- 20
testeIncidents[which(40<=testeIncidents$Minute & testeIncidents$Minute<60),"Minute"] <- 40

tempo[which(tempo[,"Minute"] < 20), "Minute"] <- 0
tempo[which(20<=tempo$Minute & tempo$Minute<40),"Minute"] <- 20
tempo[which(40<=tempo$Minute & tempo$Minute<60),"Minute"] <- 40


#Merge dataframes and filter by road, if it is equal to to_road or from_road
joined_A <- merge.data.frame(teste,testeIncidents, by = c("Hour", "Year", "Month", "Day", "Minute"), all = TRUE) %>%
  filter( mapply(function(x, y) grepl(tolower(x), tolower(y), fixed = TRUE), road_name, to_road) )

joined_B <- merge.data.frame(teste,testeIncidents, by = c("Hour", "Year", "Month", "Day", "Minute"), all = TRUE) %>%
  filter( mapply(function(x, y) grepl(tolower(x), tolower(y), fixed = TRUE), road_name, from_road) )


#Merge dataframe with weather data
complete_A <- unique(joined_A %>%
  full_join(tempo, by = c("Hour" = "Hour", "Year"="Year", "Month"="Month", "Day"="Day", "Minute"="Minute")))

complete_B <- unique(joined_B %>%
  full_join(tempo, by = c("Hour" = "Hour", "Year"="Year", "Month"="Month", "Day"="Day", "Minute"="Minute")))

#Merge the two complete dataframes
complete <- unique(rbind(complete_A, complete_B))

#Sort by Year, Month, Day, Hour, Minute
sorted <- complete[order(complete$Year, complete$Month, complete$Day, complete$Hour, complete$Minute),]

#Remove rows from the columns "road_name", "from_road", "to_road", that are NA
sorted_clean <- sorted[which(!is.na(sorted[,c("road_name", "from_road", "to_road")])),]
rownames(sorted_clean) <- NULL #Update index

#Export the generated dataframe
write.csv(x = sorted_clean, file = "C:/Users/Nuno/Desktop/Traffic_Flow_Speed_Prediction/Datasets/Braga_generated_data.csv", row.names=FALSE, fileEncoding = 'utf-8')

