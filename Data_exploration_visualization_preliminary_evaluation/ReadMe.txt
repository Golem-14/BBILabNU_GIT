Here you can find (write) scripts to explore your data as the preliminary step:

- to check how the whole spectrum looks;

- is there any visible trends;

- is there any visible noise or instability;

- etc.

Listing convention: the listing will be made in temporary progression, just add the next entry when you create a new script. If you modify a script input its title in the list below right under the name of the script you modify (for example if you want to work with  #### 2.1 SomeScript you list you modified script right under it #### 2.1.1 NameOfYourScript)

Be sure to use PROPER COMMENTING - so any changes you make are understandable to everyone. Modified scripts without proper comments will NOT be considered.

Add you name and contact information in the end of the script so people can contact you if they have suggestions and/or feedback, or reference you if you are a developer of the original script.

EXMAPLE: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script modified/developed (choose what applies) by YourName
% Contact info in case of issues and suggestions:
% YourContanctInfo@nu.edu.kz

*** If a script is marked as (UNDER DEVELOPMENT) it might not be fully ready to run and stable, it is better not to use it until the developer releases the final version.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    SCRIPTS - BASIC DESCRIPTION     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


#### 0 rsquare
This is a function needed for calibration scripts. Do not open. It is called by other scripts for proper work. DO NOT DELETE.


#### 1 MicronVisualInspectionOfSpectralFeatures
The script allows to see zoomed in version of spectrum - 4 random points on the spectrum being analyzed. It allows to see if there is a contrast visible between the concentrations. You can work right from this folder - just input the path to your data. It can be both for calibration or detection (see instructions inside the script)



### 2 PlottingWholeSpectrum
The script allows to quickly visually evaluate the stability of the probe. As you know when changing concentrations there can be some time during which the probe presents strong fluctuations. For efficient data analysis you have to identify and remove such data points. This script will allow you to see the major fluctuations.
Filter settings: Default (as in the original calibration script), Butterworth filter



#### 2.1 PlottingWholeSpectrumWithLines
The same as the script #### 2 with single difference: The lines between each 10 data points are added to provide guidance to the eye.
Filter settings: Default (as in the original calibration script), Butterworth filter




#### 2.2 PlottingWholeSpectrumWithLinesFiltfilt   (UNDER DEVELOPMENT)
The same as script #### 3 with DIFFERENCE in filter setting
Filter settings: Butterworth filter BUT "filter" CHANGED to "filtfilt" to compensate for possible spectral shift. filtfilt as opposed to filter performs runs forth and back across data, thus helping to minimize the shift.


#### 2.3 PlottingWholeSpectrumWithLinesSgolayfilt   (UNDER DEVELOPMENT)
The same as script #### 3 with DIFFERENCE in filter setting
Filter settings: Savitzky–Golay filter
Further info: https://en.wikipedia.org/wiki/Savitzky%E2%80%93Golay_filter


#### 2.4 PlottingWholeSpectrumWithLinesWavelet    (UNDER DEVELOPMENT)
The same as script #### 3 with DIFFERENCE in filter setting
Filter settings: Wavelet analysis.
NB: Wavelet toolbox is installed on the MATLAB version on the lab notebook, but you may need it to install it on your local machine as it is not a default package.


#### 3 ScriptMicronOpticsPathFiltfilt       (UNDER DEVELOPMENT)
Default calibration script with a CHANGE in 
- filter settings: filter replaced by filtfilt, Butterworth
- added option to input the path to the folder with data

#### 3.1 ScriptMicronOpticsPathSGolayfilter     (UNDER DEVELOPMENT)
The same as #### 7 but with DIFFERENT filter - Savitzky–Golay filter
(as in #### 5)



