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
