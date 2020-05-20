library(ggplot2)
library(plyr)
library(dplyr)

dataset <- read.csv("C:/Users/Nuno/Desktop/Traffic_Flow_Speed_Prediction/Datasets/Braga_generated_data.csv", encoding = 'utf-8')

###################################### Generate Boxplots ######################################################

#Get the names of the numeric columns
nums <- unlist(lapply(dataset, is.numeric))
col <- names(dataset)[nums]

for(j in  col){
  #Build path for each column
  pathWithName <- paste("C:/Users/Nuno/Desktop/Traffic_Flow_Speed_Prediction/Graphs/Boxplots/",j, sep="")
  finalPath <- paste(pathWithName, ".png", sep = "")
  
  #Indicates which type of file is being stored
  png(filename = finalPath, width = 1000, height = 800)
  
  #Boxplot build
  boxplot(dataset[,j],
          main=j,
          data = dataset,
          border = "black")
  
  #End the building
  dev.off()
}
#################################################################################################################