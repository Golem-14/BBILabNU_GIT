In this folder you find scripts used for the routine work in the lab:

- for calibration; and

- data analysis

These scripts shall stay as they are, NO modifications other than inputting information for a particular run (channel number, probe name, path etc.) are allowed to ensure stability.

In case you have an idea on how to improve core scripts and want to modify them - go to the folder Core_scripts_modifiable. If you suggestion is approved your version can be later migrated in the Core_scripts_unmodifiable by Admins. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    SCRIPTS - BASIC DESCRIPTION     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


#### 0 rsquare
It is a function needed for other scripts to run, you do not need to open it. Do NOT DELETE, do NOT MODIFY.

#### 1 ScriptMicronOptics
Original calibration script. CHANGE: added path to your folder. DO NOT copy files here and do NOT move the scripts to you file, just input the address in the corresponding field.

#### 2 ScriptMicronOpticsLog
The same as #### 1 CHANGE: Saves log for you calibration run (channel number, probe name, sensitive peaks and valleys (sensitivity and index) as well as r2 value in a .txt file directly in the folder with your data. If your run the script twice for the same channel, data will be added to the file with a corresponding time-stamp, not overwritten.


#### 3.1 ScriptDataLoading       
Original script needed in combination with ##### 3.2 ScriptDataAnalysis to load the data before processing 

#### 3.2 ScriptDataAnalysis
Ooriginal script for data visualization and primary analysis. CHANGE: added path to your folder. DO NOT copy files here and do NOT move the scripts to you file, just input the address in the corresponding field.

#### 3.2.1 ScriptDataAnalysisLog
The same as #### 3.2 ScriptDataAnalysis CHANGE - is saves a log in the folder with your files listing time-stamp, path to data, left/right peaks/valleys and the response for each concentration.

#### 4 ScriptPDMSanalysis
Original script to data analysis for PDMS sensors. CHANGE: added path to your folder. DO NOT copy files here and do NOT move the scripts to you file, just input the address in the corresponding field.

#### 5 ScriptSDIanalysis
Original script to data analysis for SDI sensors. CHANGE: added path to your folder. DO NOT copy files here and do NOT move the scripts to you file, just input the address in the corresponding field.
