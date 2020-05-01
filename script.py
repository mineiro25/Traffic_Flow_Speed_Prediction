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
 0   Hour                        81881 non-null  int64  
 1   Year                        81881 non-null  int64  
 2   Month                       81881 non-null  int64  
 3   Day                         81881 non-null  int64  
 4   Minute                      81881 non-null  int64  
 5   road_num                    81881 non-null  int64  
 6   road_name                   81881 non-null  object 
 7   functional_road_class_desc  81881 non-null  object 
 8   current_speed               81881 non-null  int64  
 9   free_flow_speed             81881 non-null  int64  
 10  speed_diff                  81881 non-null  int64  
 11  current_travel_time         81881 non-null  int64  
 12  free_flow_travel_time       81881 non-null  int64  
 13  time_diff                   81881 non-null  int64  
 14  creation_date.x             81881 non-null  object 
 15  temperature                 27190 non-null  float64
 16  atmospheric_pressure        27190 non-null  float64
 17  humidity                    27190 non-null  float64
 18  wind_speed                  27190 non-null  float64
 19  clouds                      27190 non-null  float64
 20  precipitation               27190 non-null  float64
 21  current_luminosity          27190 non-null  object 
 22  sunrise                     27190 non-null  object 
 23  sunset                      27190 non-null  object 
 24  creation_date.y             27190 non-null  object 
 25  description                 283 non-null    object 
 26  cause_of_incident           0 non-null      float64
 27  from_road                   283 non-null    object 
 28  to_road                     283 non-null    object 
 29  affected_roads              0 non-null      float64
 30  incident_category_desc      283 non-null    object 
 31  magnitude_of_delay_desc     283 non-null    object 
 32  length_in_meters            283 non-null    float64
 33  delay_in_seconds            283 non-null    float64
 34  incident_date               283 non-null    object 
 35  latitude                    283 non-null    float64
 36  longitude                   283 non-null    float64
"""

#check and replace missing with -99 (masking)
print("Count number of NA")
print(dataset.isnull().sum())
print('--------\n')
dataset.fillna(-99, inplace=True)
"""
Count number of NA
Hour                              0
Year                              0
Month                             0
Day                               0
Minute                            0
road_num                          0
road_name                         0
functional_road_class_desc        0
current_speed                     0
free_flow_speed                   0
speed_diff                        0
current_travel_time               0
free_flow_travel_time             0
time_diff                         0
creation_date.x                   0
temperature                   54691
atmospheric_pressure          54691
humidity                      54691
wind_speed                    54691
clouds                        54691
precipitation                 54691
current_luminosity            54691
sunrise                       54691
sunset                        54691
creation_date.y               54691
description                   81598
cause_of_incident             81881
from_road                     81598
to_road                       81598
affected_roads                81881
incident_category_desc        81598
magnitude_of_delay_desc       81598
length_in_meters              81598
delay_in_seconds              81598
incident_date                 81598
latitude                      81598
longitude                     81598
"""
#########################################################################################################################################################
