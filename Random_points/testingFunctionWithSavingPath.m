% Define the input parameters
path = "C:\Users\User\Documents\Lyubov\Readings\Calib 28 (2nd RECalib for C21, set 18) LV 190625 Tau"; % input here the address of the folder with your data
N_RI = 6;               % Number of RI values
N_Val = 10;             % Number of times each RI was saved
sensor_trace = 1;       % The channel number for the sensor trace


% Not necessary unless you want to finetune exact parameter
minprom = 0;            % Minimum peak prominence
maxpeakw = inf;         % Maximum peak width
minpeakd = 0;           % Minimum peak distance

% conventions for naming output files, JUST LEAVE as it is UNLESS saving
% then input "1" for "savedata"
savedata = 1;           % Flag to save data (1 for yes, 0 for no)
code_name = "LV3";     % The probe's code name
set = 18;               % The data set number
calibr = 27;            % The calibration number
modif = 0;              % The modification number

% Call the main function with the defined parameters
FunctionCalibWithSavingPath(path, N_RI, N_Val, sensor_trace, minprom, maxpeakw, minpeakd, savedata, code_name, set, calibr, modif);
