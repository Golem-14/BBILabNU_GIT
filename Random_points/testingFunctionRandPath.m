% Define the input parameters. General
path = "C:\Users\User\Documents\Lyubov\Readings\Calib 46.1 SCANSPEED 100 Hz (ts = 1, n = 60) Set 18";      % input path to your data
N_RI = 6;               % Number of RI values
N_Val = 10;             % Number of times each RI was saved
sensor_trace = 2;       % The channel number for the sensor trace
savedata = 0;           % Flag to save data (1 for yes, 0 for no)
number_of_points = 100;  %Number of random points to generate.


% IF YOU DO NOT SAVE DATA ignore parameters below BUT DO NOT DELETE THEM!
code_name = "LV30";     % The probe's code name
set = 18;               % The data set number
calibr = 27;            % The calibration number
modif = 3;              % The modification number

%Technical detail FOR ADVANCED settting! Do not modify UNLESS SURE
exclude_min = 11001;    %Minimum index to exclude from random selection.
exclude_max = 11499;    %Maximum index to exclude from random selection.
range_start = 510;      %Start index for random wavelength selection.
range_end = 18500;      %End index for random wavelength selection.


% Call the main function with the defined parameters
FunctionCalibRandPath(path, N_RI, N_Val, sensor_trace, savedata, code_name, set, calibr, modif, range_start, range_end, number_of_points, exclude_min, exclude_max);
