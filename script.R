library(dplyr)
library(tidyr)
library(mlbench)
library(lubridate)
library(corrr)
library(h2o)
library(moments)

################################################ - Import Data - ##################################################################################

train  <- read.csv(file = "C:/Users/Nuno/Desktop/Traffic_Flow_Speed_Prediction/Dataset/training_data.csv")

###################################################################################################################################################

######################################################## - Data Treatment - #######################################################################

#Remove city_name column because its all in the same city
train$city_name <- NULL

#Remove Average_precipitation column because its all the same value
train$AVERAGE_PRECIPITATION <- NULL

#Separete the column "record_date" into 2 columns, each one containing Date and Time, respectively
train <- within(train,{
  Date <- substr(train$record_date,1,10)
  Time <- substr(train$record_date, 11,13)
})

#Convert column to numeric
train$Time <- as.numeric(train$Time)

#Convert column "Date" to numeric(day of week)
train$Date <- wday(as.Date(train$Date, "%Y-%m-%d"))

#Remove the column "record_date"
train$record_date <- NULL

#Merge the columns "Cloudiness" with "Rain", using | as separator
train$AVERAGE_RAIN <- paste(train$AVERAGE_CLOUDINESS,"|",train$AVERAGE_RAIN)

#Labeling column "AVERAGE_RAIN"
train$AVERAGE_RAIN <- ifelse(train$AVERAGE_RAIN == " | ", 0, 
                      ifelse(train$AVERAGE_RAIN == "céu claro | NULL", 0, 
                      ifelse(train$AVERAGE_RAIN == "nuvens dispersas | NULL", 0, 
                      ifelse(train$AVERAGE_RAIN == "céu limpo | NULL", 0, 
                      ifelse(train$AVERAGE_RAIN == "algumas nuvens | NULL", 0, 
                      ifelse(train$AVERAGE_RAIN == "nuvens quebrados | NULL", 0, 
                      ifelse(train$AVERAGE_RAIN == "NULL | NULL", 0,
                      ifelse(train$AVERAGE_RAIN == "tempo nublado | NULL", 0,
                      ifelse(train$AVERAGE_RAIN == "nuvens quebradas | ", 0,
                      ifelse(train$AVERAGE_RAIN == "céu pouco nublado | NULL", 0, 
                      ifelse(train$AVERAGE_RAIN == "nuvens dispersas | ", 0, 
                      ifelse(train$AVERAGE_RAIN == "nuvens quebradas | NULL", 0,
                      ifelse(train$AVERAGE_RAIN == "nublado | ", 0,
                      ifelse(train$AVERAGE_RAIN == "céu pouco nublado | NULL", 0, 1))))))))))))))

#Remove the column "AVERAGE_CLOUDINESS"
train$AVERAGE_CLOUDINESS <- NULL

#Labeling column "Luminosity"
train$LUMINOSITY <- ifelse(train$LUMINOSITY == "LIGHT", 0,
                    ifelse(train$LUMINOSITY == "LOW_LIGHT", 1, 2))

#Add column weekend, where values can be 0 or 1
train$Weekend <- ifelse(train$Date == 6, 1, 
                  ifelse(train$Date == 7, 1, 0))

#Creation of column PartsOfDay
#Morning - 5 to 12 - 0
#Afternoon - 13 to 17 - 1
#Evening - 18 to 21 - 2
#Night - 22 to 23 and 0 to 4 - 3
train$PartsOfDay <- ifelse(between(train$Time, 5, 12), 0, 
                    ifelse(between(train$Time, 13, 17), 1,
                    ifelse(between(train$Time, 18, 21), 2,
                    ifelse(between(train$Time, 22, 23), 3, 3))))

####################################################### - Correlatio Filtering - ################################################################

#Calculate correlation between features
correlation <- as.data.frame(correlate(train[,2:ncol(train)], quiet = TRUE))
#Removing the features Humidity and Luminosity, because they show the most correlation with other features
train$LUMINOSITY <- NULL
train$AVERAGE_HUMIDITY <- NULL

#################################################################################################################################################
########################################################### - Skewness Filtering - ##############################################################

#Store the indexes to be removed
toRemove <- c()
j <- 1
for(i in 2:ncol(train)){
  varSkew <- skewness(train[,i])
  if(abs(varSkew) > 0.5){
    toRemove[j] <- i
    j <- j+1
  }
}
#Removed the indexes
train[,toRemove] <- NULL

#################################################################################################################################################
############################################################ - Outlier Filtering - ##############################################################

#Replace outliers with the median of each feature
for(i in 2:ncol(train)){
  outlier <- boxplot(train[,i], plot = FALSE)$out
  train[which(train[,i] %in% outlier),i] <- median(train[,i])
}

#################################################################################################################################################

##################################################################################################################################################

############################################################### - Gradient Boosting Machine - #####################################################

#Begin H20
h2o.init(port = 54321, nthreads = -1, max_mem_size ="5G", ip = "localhost")

#Define the factor
train$AVERAGE_SPEED_DIFF <- as.factor(train$AVERAGE_SPEED_DIFF)

#Begin H20 frame
train <- as.h2o(train)

#Set frames for predictions
splited_data <- h2o.splitFrame(data = train, 
                               ratios = c(0.7,0.15),
                               destination_frames = c("TRAIN","VALID","TEST"),
                               seed = 1234)

#Set Predictors and Response
PREDICTORS <- c("AVERAGE_SPEED_DIFF","AVERAGE_FREE_FLOW_SPEED","AVERAGE_TIME_DIFF","AVERAGE_FREE_FLOW_TIME",
                "AVERAGE_TEMPERATURE","AVERAGE_ATMOSP_PRESSURE","AVERAGE_WIND_SPEED","AVERAGE_RAIN","Time","Date","PartsOfDay")

RESPONSE <- c("AVERAGE_SPEED_DIFF")


# Grid (Hyperparameter) Search
gbm_params <- list(
  ntrees = seq(300,800,25),
  max_depth = seq(5,15,1),
  learn_rate = c(0.01,0.02),
  min_rows = c(1,2,5,10),
  sample_rate = seq(0.9,0.99,0.01),
  nbins = c(16,20,24,75),
  col_sample_rate_per_tree = c(0.7,0.8),
  col_sample_rate = c(0.6,0.7,0.8),
  distribution = "multinomial",
  fold_assignment = "AUTO"
)

# Early Stopping
search_criteria <- list(
  strategy = "RandomDiscrete",
  stopping_metric = "AUC",
  stopping_tolerance = 0.000001,
  stopping_rounds = 10,
  max_models = 50
)

# Gradient Boosting Machine algorithm with grid search
traffic_gbm_grid <- h2o.grid(
  algorithm = "gbm",
  grid_id = "traffic_gbm_grid",
  x = PREDICTORS,
  y = RESPONSE,
  training_frame = h2o.getFrame("TRAIN"),
  validation_frame= h2o.getFrame("VALID"),
  nfolds = 0,
  seed = 99,
  hyper_params = gbm_params,
  search_criteria = search_criteria,
  stopping_metric = "AUTO",
  stopping_tolerance = 0,
  stopping_rounds = 4,
  score_tree_interval = 10
)


# Get the grid results, sorted by validation AUC
gbm_grid_performance <- h2o.getGrid(grid_id = "traffic_gbm_grid",
                             sort_by = "accuracy",
                             decreasing = TRUE)
print(gbm_grid_performance)




