library(dplyr)
library(tidyr)

################################################ - Import Data - ##################################################################################

train  <- read.csv(file = "C:/Users/Nuno/Desktop/Traffic_Flow_Speed_Prediction/Dataset/training_data.csv")

###################################################################################################################################################

######################################################## - Data Treatment - #######################################################################

#Separete the column "record_date" into 2 columns, each one containing Date and Time, respectively
train <- within(train,{
  Date <- substr(train$record_date,1,10)
  Time <- substr(train$record_date, 11,19)
})
#Remove the column "record_date"
train$record_date <- NULL






###################################################################################################################################################