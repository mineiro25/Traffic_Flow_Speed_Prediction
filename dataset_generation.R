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
teste[which(teste[,"Minute"] < 10), "Minute"] <- 0
teste[which(10<=teste$Minute & teste$Minute<20),"Minute"] <- 10
teste[which(20<=teste$Minute & teste$Minute<30),"Minute"] <- 20
teste[which(30<=teste$Minute & teste$Minute<40),"Minute"] <- 30
teste[which(40<=teste$Minute & teste$Minute<50),"Minute"] <- 40
teste[which(50<=teste$Minute & teste$Minute<60),"Minute"] <- 50

testeIncidents[which(testeIncidents[,"Minute"] < 10), "Minute"] <- 0
testeIncidents[which(10<=testeIncidents$Minute & testeIncidents$Minute<20),"Minute"] <- 10
testeIncidents[which(20<=testeIncidents$Minute & testeIncidents$Minute<30),"Minute"] <- 20
testeIncidents[which(30<=testeIncidents$Minute & testeIncidents$Minute<40),"Minute"] <- 30
testeIncidents[which(40<=testeIncidents$Minute & testeIncidents$Minute<50),"Minute"] <- 40
testeIncidents[which(50<=testeIncidents$Minute & testeIncidents$Minute<60),"Minute"] <- 50

tempo[which(tempo[,"Minute"] < 10), "Minute"] <- 0
tempo[which(10<=tempo$Minute & tempo$Minute<20),"Minute"] <- 10
tempo[which(20<=tempo$Minute & tempo$Minute<30),"Minute"] <- 20
tempo[which(30<=tempo$Minute & tempo$Minute<40),"Minute"] <- 30
tempo[which(40<=tempo$Minute & tempo$Minute<50),"Minute"] <- 40
tempo[which(50<=tempo$Minute & tempo$Minute<60),"Minute"] <- 50


#Merge dataframe with weather data
teste_weather <- unique(merge.data.frame(teste, tempo, by = c("Hour", "Year", "Month", "Day", "Minute"), all = TRUE))


#Merge dataframes and filter by road, if it is equal to to_road or from_road
merged <- unique(merge.data.frame(teste_weather,testeIncidents, by = c("Hour", "Year", "Month", "Day", "Minute"), all = TRUE))

#Retrieving the columns names that are related with the accidents
col <- names(testeIncidents)[1:12]

#Get the row number, that are from rows not related with accidents
lin <- which(mapply(function(x, y) !grepl(tolower(x), tolower(y), fixed = TRUE), merged$road_name, merged$from_road)==TRUE)
lin_2 <- which(mapply(function(x, y) !grepl(tolower(x), tolower(y), fixed = TRUE), merged$road_name, merged$to_road)==TRUE)
#Concat vectors
no_acc <- unique(c(lin, lin_2))

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

#Concat the two dataframes
complete <- unique(rbind.data.frame(no_accidents, accidents))

#Convert factors to characters
i <- sapply(complete, is.factor)
complete[i] <- lapply(complete[i], as.character)

#Sort by Year, Month, Day, Hour, Minute
sorted <- complete[order(complete$Year, complete$Month, complete$Day, complete$Hour, complete$Minute),]

#Remove rows from the columns "road_name", "Hour", "Minute", "Day", "Month", that are NA
sorted_clean <- unique(sorted[which(complete.cases(sorted[,c("road_name", "Hour", "Minute", "Day", "Month", "Year")])),])
rownames(sorted_clean) <- NULL #Update index


#Export the generated dataframe
write.csv(x = sorted_clean, file = "C:/Users/Nuno/Desktop/Traffic_Flow_Speed_Prediction/Datasets/Braga_generated_data.csv", row.names=FALSE, fileEncoding = 'utf-8')

