Here you can find a version of the core scripts which you CAN modify in case you have suggestions on how to improve them.

TO INTRODUCE MAJOR CHANGES in a script - make a COPY of it with corresponding name and work there. DO NOT work in the original file! 

Listing convention: if you modify a script input its title in the list below right under the name of the script you modify (for example if you want to work with  #### 2.1 ScriptMicronOpticsLogHTML you list you modified script right under it #### 2.1.1 NameOfYourScript)

If your contribution is approved the script can be migrated to the folder Core_scripts_unmodifiable.

Be sure to use PROPER COMMENTING - so any changes you make are understandable to everyone. Modified scripts without proper comments will NOT be considered.

Add you name and contact information in the end of the script so people can contact you if they have suggestions and/or feedback, or reference you if you are a developer of the original script.

EXMAPLE: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script modified/developed (choose what applies) by YourName
% Contact info in case of issues and suggestions:
% YourContanctInfor@nu.edu.kz

*** If a script is marked as (UNDER DEVELOPMENT) they might not be fully ready to run and stable, it is better not to use them until the developer releases the final version.


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
The same as #### 1 with CHANGE: Saves log for you calibration run (channel number, probe name, sensitive peaks and valleys (sensitivity and index) as well as r2 value in a .txt file directly in the folder with your data. If your run the script twice for the same channel, data will be added to the file with a corresponding time-stamp, not overwritten.

#### 2.1 ScriptMicronOpticsLogHTML
The same as #### 2 with CHANGE: log is saved in HTML format and contains the last picture (sensitivity) (UNDER DEVELOPMENT)

#### 2.1 ScriptMicronOpticsLogTxtSort
The same as #### 2 with CHANGE: log contains sorted values for sensitivity (UNDER DEVELOPMENT)


#### 3.1 ScriptDataLoading       
Original script needed in combination with ##### 3.2 ScriptDataAnalysis to load the data before processing 

#### 3.2 ScriptDataAnalysis
Ooriginal script for data visualization and primary analysis. CHANGE: added path to your folder. DO NOT copy files here and do NOT move the scripts to you file, just input the address in the corresponding field.

#### 4 ScriptPDMSanalysis
Original script to data analysis for PDMS sensors. CHANGE: added path to your folder. DO NOT copy files here and do NOT move the scripts to you file, just input the address in the corresponding field.

#### 5 ScriptSDIanalysis
Original script to data analysis for SDI sensors. CHANGE: added path to your folder. DO NOT copy files here and do NOT move the scripts to you file, just input the address in the corresponding field.