import os
import pandas as pd 
import subprocess
import platform

################################################################ File Upload ############################################################################

#Upload the file depending on the operating system
if platform.system() == 'Windows':
    #Check if file exists
    if os.path.exists("Datasets/Braga_generated_data.csv"):
        dataset = pd.read_csv("Datasets/Braga_generated_data.csv")
    else:
        subprocess.call([r'run_R.bat'])
        dataset = pd.read_csv("Datasets/Braga_generated_data.csv")
else:
    #Check if file exists
    if os.path.exists("Datasets/Braga_generated_data.csv"):
        dataset = pd.read_csv("Datasets/Braga_generated_data.csv")
    else:
        subprocess.call([r'run_R.sh'])
        dataset = pd.read_csv("Datasets/Braga_generated_data.csv")    

#########################################################################################################################################################
############################################################### Dataset Infos ###########################################################################

#dataset info
print("Dataset Information")
print(dataset.info())
print('--------\n')

"""
 #   Column                      Non-Null Count  Dtype  
---  ------                      --------------  -----  
 0   Hour                        6706 non-null   int64  
 1   Year                        6706 non-null   int64  
 2   Month                       6706 non-null   int64  
 3   Day                         6706 non-null   int64  
 4   Minute                      6706 non-null   int64  
 5   road_num                    6706 non-null   int64  
 6   road_name                   6706 non-null   object 
 7   functional_road_class_desc  6706 non-null   object 
 8   current_speed               6706 non-null   int64  
 9   free_flow_speed             6706 non-null   int64  
 10  speed_diff                  6706 non-null   int64  
 11  current_travel_time         6706 non-null   int64  
 12  free_flow_travel_time       6706 non-null   int64  
 13  time_diff                   6706 non-null   int64  
 14  creation_date.x             6706 non-null   object 
 15  description                 6706 non-null   object 
 16  cause_of_incident           0 non-null      float64
 17  from_road                   6706 non-null   object 
 18  to_road                     6706 non-null   object 
 19  affected_roads              2320 non-null   object 
 20  incident_category_desc      6706 non-null   object 
 21  magnitude_of_delay_desc     6706 non-null   object 
 22  length_in_meters            6706 non-null   int64  
 23  delay_in_seconds            6706 non-null   int64  
 24  incident_date               6706 non-null   object 
 25  latitude                    6706 non-null   float64
 26  longitude                   6706 non-null   float64
 27  temperature                 2218 non-null   float64
 28  atmospheric_pressure        2218 non-null   float64
 29  humidity                    2218 non-null   float64
 30  wind_speed                  2218 non-null   float64
 31  clouds                      2218 non-null   float64
 32  precipitation               2218 non-null   float64
 33  current_luminosity          2218 non-null   object 
 34  sunrise                     2218 non-null   object 
 35  sunset                      2218 non-null   object 
 36  creation_date.y             2218 non-null   object 
"""

#check and replace missing with -99 (masking)
print("Count number of NA")
print(dataset.isnull().sum())
print('--------\n')
dataset.fillna(-99, inplace=True)
"""
Count number of NA
Hour                             0
Year                             0
Month                            0
Day                              0
Minute                           0
road_num                         0
road_name                        0
functional_road_class_desc       0
current_speed                    0
free_flow_speed                  0
speed_diff                       0
current_travel_time              0
free_flow_travel_time            0
time_diff                        0
creation_date.x                  0
description                      0
cause_of_incident             6706
from_road                        0
to_road                          0
affected_roads                4386
incident_category_desc           0
magnitude_of_delay_desc          0
length_in_meters                 0
delay_in_seconds                 0
incident_date                    0
latitude                         0
longitude                        0
temperature                   4488
atmospheric_pressure          4488
humidity                      4488
wind_speed                    4488
clouds                        4488
precipitation                 4488
current_luminosity            4488
sunrise                       4488
sunset                        4488
creation_date.y               4488
"""
#########################################################################################################################################################
