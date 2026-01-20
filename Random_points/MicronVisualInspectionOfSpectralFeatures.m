% Data loading and filtering

clear all;
close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Parameters initialization START %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MAIN DATA<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


% input here the path to you data:
% open the needed folder and copy its address 
pathToData = "C:\Users\User\Documents\Lyubov\Readings\Scan 16 SCANSPEED 100 Hz Set 18"; 

N_Conc = 1; % Number of Conc. values
N_Val = 360; % Number of times each Conc. was sampled

chanNumber = 1; % The channel being analysed

calibration = 0; % calibration (put 1) or detection files (put 0)

presentation = 2; % for 2D choose 2, for 3D input 3

PVfound = 0; % sensor is good and there are peaks - choose 1; 
% if NO PEAKS found - choose 0, random points will be displayed


%Indices of peaks and vallyes you want to analyze if you chose 1 above
LeftLocPeak = 2; %input here a peak you want to examine (index from LocPeakLeft)
LeftLocValley = 1; %input here a valley you want to examine (index from LocValleyLeft)
RightLocPeak = 1; %input here a peak you want to examine (index from LocPeakRight)
RightLocValley = 1; %input here a valley you want to examine (index from LocValleyRight)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Parameters initialization stop  %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% You do not need to input anything below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% OPTIONAL - choose your filter (OR LEAVE THE DEFAULT)


% Low-pass filter

[b,a] = butter(5,0.01);


%Vary cutoff
%[b,a] = butter(5,0.001); % BY DEFAULT AS GIVING THE BEST CONTRAST
%[b,a] = butter(5,0.05);
%[b,a] = butter(5,0.10);
%[b,a] = butter(5,0.15);
%[b,a] = butter(5,0.20);

%[b,a] = butter(5,0.5);
%[b,a] = butter(1,0.001);

%Vary order
%[b,a] = butter(1,0.01);
%[b,a] = butter(2,0.01);
%[b,a] = butter(3,0.01); %Not tried since here
%[b,a] = butter(4,0.01);
%[b,a] = butter(6,0.01);

% Other variants
% [b,a] = butter(6,0.02);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Load data from files %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

kk = 1;
for ii = 1:N_Conc
    for jj = 1:N_Val
        

        if calibration == 1
            Fname = strcat(pathToData, '\', 'RI', num2str(ii), '_', num2str(jj), '.txt');
        else
            Fname = strcat(pathToData, '\', 'concentration', num2str(ii), '_measurement', num2str(jj), '.txt');
        end


        Data = importdata(Fname);
        Mat = Data.data;
        
        [D1,D2] = size(Mat);
        
        % Load data on each channel
        if (kk==1)
            Wavelength = Mat(:,1);
        end
        
        if (D2>=2)
            CH1(kk,:) = Mat(:,2);
        else
            CH1(kk,:) = zeros(D1,1);
        end
        
        if (D2>=3)
            CH2(kk,:) = Mat(:,3);
        else
            CH2(kk,:) = zeros(D1,1);
        end
        
        if (D2>=4)
            CH3(kk,:) = Mat(:,4);
        else
            CH3(kk,:) = zeros(D1,1);
        end
        
        if (D2>=5)
            CH4(kk,:) = Mat(:,5);
        else
            CH4(kk,:) = zeros(D1,1);
        end
        
        if (D2>=6)
            CH5(kk,:) = Mat(:,6);
        else
            CH5(kk,:) = zeros(D1,1);
        end
        
        if (D2>=7)
            CH6(kk,:) = Mat(:,7);
        else
            CH6(kk,:) = zeros(D1,1);
        end
        
        if (D2>=8)
            CH7(kk,:) = Mat(:,8);
        else
            CH7(kk,:) = zeros(D1,1);
        end
        
        if (D2>=9)
            CH8(kk,:) = Mat(:,9);
        else
            CH8(kk,:) = zeros(D1,1);
        end

  
        kk = kk+1;
        
    end
end

kk = kk-1;

%%% Filter data

for ii = 1:kk
    CHF1(ii,:) = filter(b,a,CH1(ii,:));
    CHF2(ii,:) = filter(b,a,CH2(ii,:));
    CHF3(ii,:) = filter(b,a,CH3(ii,:));
    CHF4(ii,:) = filter(b,a,CH4(ii,:));
    CHF5(ii,:) = filter(b,a,CH5(ii,:));
    CHF6(ii,:) = filter(b,a,CH6(ii,:));
    CHF7(ii,:) = filter(b,a,CH7(ii,:));
    CHF8(ii,:) = filter(b,a,CH8(ii,:));
end
%%
% Data preprocessing

if chanNumber == 1
    ChannelData = CHF1;
end
if chanNumber == 2
    ChannelData = CHF2;
end
if chanNumber == 3
    ChannelData = CHF3;
end
if chanNumber == 4
    ChannelData = CHF4;
end
if chanNumber == 5
    ChannelData = CHF5;
end
if chanNumber == 6
    ChannelData = CHF6;
end
if chanNumber == 7
    ChannelData = CHF7;
end
if chanNumber == 8
    ChannelData = CHF8;
end

%ChannelData = CHF1; %%% Replace here the channel you want to analyze

% Select spectral portions

TRANSIENT = 1000; % Length of filter transient
FBG_LEFT = 11000; % Leftmost part of the FBG spectrum
FBG_RIGHT = 12000; % Rightmost part of the FBG spectrum
SpectrumLeft = ChannelData(:,TRANSIENT:FBG_LEFT); % Left spectrum: cut out the transient, for SDI analysis
SpectrumFBG = ChannelData(:,FBG_LEFT:FBG_RIGHT); % Spectral portion containing the FBG
SpectrumRight = ChannelData(:,FBG_RIGHT:end); % Right part of the spectrum for SDI analysis
WavelengthLeft = Wavelength(TRANSIENT:FBG_LEFT);
WavelengthFBG = Wavelength(FBG_LEFT:FBG_RIGHT);
WavelengthRight = Wavelength(FBG_RIGHT:end);


% Identify peaks and valleys

N_Index = 1; % Index of the spectral measurement for peak search
MPP = 1.5; % Min. peak prominence

SpectrumLeft_P = SpectrumLeft(N_Index,:);
SpectrumFBG_P = SpectrumFBG(N_Index,:);
SpectrumRight_P = SpectrumRight(N_Index,:);

% Peaks
[P, LocPeakLeft] = findpeaks(SpectrumLeft_P, 'MinPeakProminence',MPP);
[P, LocPeakRight] = findpeaks(SpectrumRight_P, 'MinPeakProminence',MPP);

% Valleys
[P, LocValleyLeft] = findpeaks(-SpectrumLeft_P, 'MinPeakProminence',MPP);
[P, LocValleyRight] = findpeaks(-SpectrumRight_P, 'MinPeakProminence',MPP);


% In case no peaks and valleys found we need the randomization loop below
if PVfound == 1
    LocPeakLeft = LocPeakLeft;
    LocValleyLeft = LocValleyLeft;
    LocPeakRight = LocPeakRight;
    LocValleyRight = LocValleyRight;
end
if PVfound == 0
    % Initialize arrays for storing peak and valley locations
    LocPeakLeft = randi([1000, 9500], 1, 10);
    LocValleyLeft = randi([1000, 9500], 1, 10);
    LocPeakRight = randi([100, 7900], 1, 10);
    LocValleyRight = randi([100, 7900], 1, 10);

    
end



% Extract timeline

time = 0 : (kk-1);



% Extract levels for each concentration

ConcentrationIndex = 1:N_Conc;

%%
% VISUAL ANALYSIS

% --- Script to Create a 3D Surface Plot Over Time ---
% This script ensures that the Left and Right spectra are processed and plotted
% completely independently. Only the spectral channel covering the requested
% range will appear on the plot.
% --------------------------------------------------------------------------

% --- ASSUMED WORKSPACE VARIABLES ---
% WavelengthLeft, WavelengthRight: Wavelength arrays (1xN)
% time: Time vector (1xM or Mx1) - should be in minutes
% SpectrumLeft, SpectrumRight: Intensity matrices (M rows (time) x N columns (Wavelength))
%
% --- NEW Required Variables for Virtual Sensor Highlight ---
% Indices_R98_Left: A list of INDICES in WavelengthLeft that passed R^2 > 0.98.
% Indices_R98_Right: A list of INDICES in WavelengthRight that passed R^2 > 0.98.
% ---------------------------------------------------------




% --- SETUP: Ensure data consistency and define R98 indices ---
if size(time, 1) > 1
    time = time'; % Ensure time is a row vector
end

% >>> IMPORTANT: DEFINE YOUR R^2 > 0.98 INDICES HERE <<<
% Placeholder indices for demonstration. REPLACE THESE LINES with your actual data.
if ~exist('Indices_R98_Left', 'var')
    % Example: Indices 5, 20, 35 in the Left Wavelength array
    Indices_R98_Left = [5, 20, 35]; 
end
if ~exist('Indices_R98_Right', 'var')
    % Example: Indices 10, 50, 90 in the Right Wavelength array
    Indices_R98_Right = []; % Set to empty array if this spectrum has no high-quality points
end

% Visual inspection of peaks - LEFT

% --- 1. Define Wavelength Range for Plotting (Zoom Control) ---
% **NOTE: Using the user-requested range of 1470 nm to 1500 nm**
Wavelength_Min = WavelengthLeft(LocPeakLeft(LeftLocPeak))-0.1; 
Wavelength_Max = WavelengthLeft(LocPeakLeft(LeftLocPeak))+0.1; 

% --- 2. Calculate Index Range for Cropping (INDEPENDENT) ---

% For the Left Spectrum
idx_left = WavelengthLeft >= Wavelength_Min & WavelengthLeft <= Wavelength_Max;
WavelengthLeft_cropped = WavelengthLeft(idx_left);
SpectrumLeft_cropped = SpectrumLeft(:, idx_left);

% For the Right Spectrum
idx_right = WavelengthRight >= Wavelength_Min & WavelengthRight <= Wavelength_Max;
WavelengthRight_cropped = WavelengthRight(idx_right);
SpectrumRight_cropped = SpectrumRight(:, idx_right);

% --- FIGURE: FULL SURFACE PLOT SETUP ---
figure;
hold on;
title(sprintf('Spectral Surface of a Left Peak: %g nm to %g nm', Wavelength_Min, Wavelength_Max));
xlabel('Wavelength (nm)');
ylabel('Time (min)');
zlabel('Spectral Intensity (dBm)');
grid on;

% --- 3. Plot Left Spectrum Surface (CROPPED) ---
if ~isempty(WavelengthLeft_cropped)
    [X_left_matrix, Y_left_matrix] = meshgrid(WavelengthLeft_cropped, time);
    h_left = surf(X_left_matrix, Y_left_matrix, SpectrumLeft_cropped, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
end

% --- 4. Plot Right Spectrum Surface (CROPPED) ---
if ~isempty(WavelengthRight_cropped)
    [X_right_matrix, Y_right_matrix] = meshgrid(WavelengthRight_cropped, time);
    h_right = surf(X_right_matrix, Y_right_matrix, SpectrumRight_cropped, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
end

% --- 5. Highlight the Virtual Sensor Array (R^2 > 0.98 Points) ---
% A. Left Channel Highlights
for idx_full = Indices_R98_Left
    W_val = WavelengthLeft(idx_full);
    % Check if this high-quality point is within the current plot range
    if W_val >= Wavelength_Min && W_val <= Wavelength_Max
        % Loop through every time point (i.e., every row of data)
        for i = 1:length(time)
            t = time(i);
            Z_val = SpectrumLeft(i, idx_full);
            
            % Scatter plot: Wavelength (X), Time (Y), Intensity (Z). 
            % CHANGED: Swapped 'r' (red) to 'k' (black) for a consistent grayscale/monochrome look.
            scatter3(W_val, t, Z_val, 150, 'k', 'filled', 'MarkerEdgeColor', 'k', 'Marker', 'o', 'DisplayName', 'Virtual Sensor (R^2 > 0.98)');
        end
    end
end
% B. Right Channel Highlights
for idx_full = Indices_R98_Right
    W_val = WavelengthRight(idx_full);
    % Check if this high-quality point is within the current plot range
    if W_val >= Wavelength_Min && W_val <= Wavelength_Max
        % Loop through every time point (i.e., every row of data)
        for i = 1:length(time)
            t = time(i);
            Z_val = SpectrumRight(i, idx_full);
            
            % Scatter plot: Wavelength (X), Time (Y), Intensity (Z). 
            % CHANGED: Swapped 'r' (red) to 'k' (black) for a consistent grayscale/monochrome look.
            scatter3(W_val, t, Z_val, 150, 'k', 'filled', 'MarkerEdgeColor', 'k', 'Marker', 'o');
        end
    end
end

% --- 6. Customize Visualization ---
shading flat; 

if presentation == 2
    view(2); 
else
    view(3)
end

%camlight infinite;
%lighting phong;
colorbar;
% ---------------------------------------------------------------------------------
colormap(gray); 
% ---------------------------------------------------------------------------------
rotate3d on;
% Set dynamic axis limits based on the user's requested range
xlim([Wavelength_Min, Wavelength_Max]);
ylim([min(time), max(time)]);
% Set Z-limits for better perspective (consider both spectra's full data for Z-range)
all_data = [SpectrumLeft(:); SpectrumRight(:)];
z_min = min(all_data);
z_max = max(all_data);
zlim([z_min - 1, z_max + 1]); 
% Add a clean legend only for the sensor markers
h = findobj(gcf,'DisplayName','Virtual Sensor (R^2 > 0.98)');
if ~isempty(h)
    % Only keep one legend entry for the virtual sensor
    legend(h(1), 'Location', 'NorthEast'); 
end
hold on;

%%
% Visual inspection of peaks - RIGHT

% --- 1. Define Wavelength Range for Plotting (Zoom Control) ---
% **NOTE: Using the user-requested range of 1470 nm to 1500 nm**
Wavelength_Min = WavelengthRight(LocPeakRight(RightLocPeak))-0.1; 
Wavelength_Max = WavelengthRight(LocPeakRight(RightLocPeak))+0.1; 

% --- 2. Calculate Index Range for Cropping (INDEPENDENT) ---

% For the Left Spectrum
idx_left = WavelengthLeft >= Wavelength_Min & WavelengthLeft <= Wavelength_Max;
WavelengthLeft_cropped = WavelengthLeft(idx_left);
SpectrumLeft_cropped = SpectrumLeft(:, idx_left);

% For the Right Spectrum
idx_right = WavelengthRight >= Wavelength_Min & WavelengthRight <= Wavelength_Max;
WavelengthRight_cropped = WavelengthRight(idx_right);
SpectrumRight_cropped = SpectrumRight(:, idx_right);

% --- FIGURE: FULL SURFACE PLOT SETUP ---
figure;
hold on;
title(sprintf('Spectral Surface a Right Peak: %g nm to %g nm', Wavelength_Min, Wavelength_Max));
xlabel('Wavelength (nm)');
ylabel('Time (min)');
zlabel('Spectral Intensity (dBm)');
grid on;

% --- 3. Plot Left Spectrum Surface (CROPPED) ---
if ~isempty(WavelengthLeft_cropped)
    [X_left_matrix, Y_left_matrix] = meshgrid(WavelengthLeft_cropped, time);
    h_left = surf(X_left_matrix, Y_left_matrix, SpectrumLeft_cropped, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
end

% --- 4. Plot Right Spectrum Surface (CROPPED) ---
if ~isempty(WavelengthRight_cropped)
    [X_right_matrix, Y_right_matrix] = meshgrid(WavelengthRight_cropped, time);
    h_right = surf(X_right_matrix, Y_right_matrix, SpectrumRight_cropped, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
end

% --- 5. Highlight the Virtual Sensor Array (R^2 > 0.98 Points) ---
% A. Left Channel Highlights
for idx_full = Indices_R98_Left
    W_val = WavelengthLeft(idx_full);
    % Check if this high-quality point is within the current plot range
    if W_val >= Wavelength_Min && W_val <= Wavelength_Max
        % Loop through every time point (i.e., every row of data)
        for i = 1:length(time)
            t = time(i);
            Z_val = SpectrumLeft(i, idx_full);
            
            % Scatter plot: Wavelength (X), Time (Y), Intensity (Z). 
            % CHANGED: Swapped 'r' (red) to 'k' (black) for a consistent grayscale/monochrome look.
            scatter3(W_val, t, Z_val, 150, 'k', 'filled', 'MarkerEdgeColor', 'k', 'Marker', 'o', 'DisplayName', 'Virtual Sensor (R^2 > 0.98)');
        end
    end
end
% B. Right Channel Highlights
for idx_full = Indices_R98_Right
    W_val = WavelengthRight(idx_full);
    % Check if this high-quality point is within the current plot range
    if W_val >= Wavelength_Min && W_val <= Wavelength_Max
        % Loop through every time point (i.e., every row of data)
        for i = 1:length(time)
            t = time(i);
            Z_val = SpectrumRight(i, idx_full);
            
            % Scatter plot: Wavelength (X), Time (Y), Intensity (Z). 
            % CHANGED: Swapped 'r' (red) to 'k' (black) for a consistent grayscale/monochrome look.
            scatter3(W_val, t, Z_val, 150, 'k', 'filled', 'MarkerEdgeColor', 'k', 'Marker', 'o');
        end
    end
end

% --- 6. Customize Visualization ---
shading flat; 

if presentation == 2
    view(2); 
else
    view(3)
end

%camlight infinite;
%lighting phong;
colorbar;
% ---------------------------------------------------------------------------------
colormap(gray); 
% ---------------------------------------------------------------------------------
rotate3d on;
% Set dynamic axis limits based on the user's requested range
xlim([Wavelength_Min, Wavelength_Max]);
ylim([min(time), max(time)]);
% Set Z-limits for better perspective (consider both spectra's full data for Z-range)
all_data = [SpectrumLeft(:); SpectrumRight(:)];
z_min = min(all_data);
z_max = max(all_data);
zlim([z_min - 1, z_max + 1]); 
% Add a clean legend only for the sensor markers
h = findobj(gcf,'DisplayName','Virtual Sensor (R^2 > 0.98)');
if ~isempty(h)
    % Only keep one legend entry for the virtual sensor
    legend(h(1), 'Location', 'NorthEast'); 
end
hold on;


%%
% Visual inspection of valleys - LEFT

% --- 1. Define Wavelength Range for Plotting (Zoom Control) ---
% **NOTE: Using the user-requested range of 1470 nm to 1500 nm**
Wavelength_Min = WavelengthLeft(LocValleyLeft(LeftLocValley))-0.1; 
Wavelength_Max = WavelengthLeft(LocValleyLeft(LeftLocValley))+0.1; 

% --- 2. Calculate Index Range for Cropping (INDEPENDENT) ---

% For the Left Spectrum
idx_left = WavelengthLeft >= Wavelength_Min & WavelengthLeft <= Wavelength_Max;
WavelengthLeft_cropped = WavelengthLeft(idx_left);
SpectrumLeft_cropped = SpectrumLeft(:, idx_left);

% For the Right Spectrum
idx_right = WavelengthRight >= Wavelength_Min & WavelengthRight <= Wavelength_Max;
WavelengthRight_cropped = WavelengthRight(idx_right);
SpectrumRight_cropped = SpectrumRight(:, idx_right);

% --- FIGURE: FULL SURFACE PLOT SETUP ---
figure;
hold on;
title(sprintf('Spectral Surface of a Left Valley: %g nm to %g nm', Wavelength_Min, Wavelength_Max));
xlabel('Wavelength (nm)');
ylabel('Time (min)');
zlabel('Spectral Intensity (dBm)');
grid on;

% --- 3. Plot Left Spectrum Surface (CROPPED) ---
if ~isempty(WavelengthLeft_cropped)
    [X_left_matrix, Y_left_matrix] = meshgrid(WavelengthLeft_cropped, time);
    h_left = surf(X_left_matrix, Y_left_matrix, SpectrumLeft_cropped, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
end

% --- 4. Plot Right Spectrum Surface (CROPPED) ---
if ~isempty(WavelengthRight_cropped)
    [X_right_matrix, Y_right_matrix] = meshgrid(WavelengthRight_cropped, time);
    h_right = surf(X_right_matrix, Y_right_matrix, SpectrumRight_cropped, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
end

% --- 5. Highlight the Virtual Sensor Array (R^2 > 0.98 Points) ---
% A. Left Channel Highlights
for idx_full = Indices_R98_Left
    W_val = WavelengthLeft(idx_full);
    % Check if this high-quality point is within the current plot range
    if W_val >= Wavelength_Min && W_val <= Wavelength_Max
        % Loop through every time point (i.e., every row of data)
        for i = 1:length(time)
            t = time(i);
            Z_val = SpectrumLeft(i, idx_full);
            
            % Scatter plot: Wavelength (X), Time (Y), Intensity (Z). 
            % CHANGED: Swapped 'r' (red) to 'k' (black) for a consistent grayscale/monochrome look.
            scatter3(W_val, t, Z_val, 150, 'k', 'filled', 'MarkerEdgeColor', 'k', 'Marker', 'o', 'DisplayName', 'Virtual Sensor (R^2 > 0.98)');
        end
    end
end
% B. Right Channel Highlights
for idx_full = Indices_R98_Right
    W_val = WavelengthRight(idx_full);
    % Check if this high-quality point is within the current plot range
    if W_val >= Wavelength_Min && W_val <= Wavelength_Max
        % Loop through every time point (i.e., every row of data)
        for i = 1:length(time)
            t = time(i);
            Z_val = SpectrumRight(i, idx_full);
            
            % Scatter plot: Wavelength (X), Time (Y), Intensity (Z). 
            % CHANGED: Swapped 'r' (red) to 'k' (black) for a consistent grayscale/monochrome look.
            scatter3(W_val, t, Z_val, 150, 'k', 'filled', 'MarkerEdgeColor', 'k', 'Marker', 'o');
        end
    end
end

% --- 6. Customize Visualization ---
shading flat; 

if presentation == 2
    view(2); 
else
    view(3)
end

%camlight infinite;
%lighting phong;
colorbar;
% ---------------------------------------------------------------------------------
colormap(gray); 
% ---------------------------------------------------------------------------------
rotate3d on;
% Set dynamic axis limits based on the user's requested range
xlim([Wavelength_Min, Wavelength_Max]);
ylim([min(time), max(time)]);
% Set Z-limits for better perspective (consider both spectra's full data for Z-range)
all_data = [SpectrumLeft(:); SpectrumRight(:)];
z_min = min(all_data);
z_max = max(all_data);
zlim([z_min - 1, z_max + 1]); 
% Add a clean legend only for the sensor markers
h = findobj(gcf,'DisplayName','Virtual Sensor (R^2 > 0.98)');
if ~isempty(h)
    % Only keep one legend entry for the virtual sensor
    legend(h(1), 'Location', 'NorthEast'); 
end
hold on;

%%
% Visual inspection of valleys - RIGHT

% --- 1. Define Wavelength Range for Plotting (Zoom Control) ---
% **NOTE: Using the user-requested range of 1470 nm to 1500 nm**
Wavelength_Min = WavelengthRight(LocValleyRight(RightLocValley))-0.1; 
Wavelength_Max = WavelengthRight(LocValleyRight(RightLocValley))+0.1; 

% --- 2. Calculate Index Range for Cropping (INDEPENDENT) ---

% For the Left Spectrum
idx_left = WavelengthLeft >= Wavelength_Min & WavelengthLeft <= Wavelength_Max;
WavelengthLeft_cropped = WavelengthLeft(idx_left);
SpectrumLeft_cropped = SpectrumLeft(:, idx_left);

% For the Right Spectrum
idx_right = WavelengthRight >= Wavelength_Min & WavelengthRight <= Wavelength_Max;
WavelengthRight_cropped = WavelengthRight(idx_right);
SpectrumRight_cropped = SpectrumRight(:, idx_right);

% --- FIGURE: FULL SURFACE PLOT SETUP ---
figure;
hold on;
title(sprintf('Spectral Surface of a Right Valley: %g nm to %g nm', Wavelength_Min, Wavelength_Max));
xlabel('Wavelength (nm)');
ylabel('Time (min)');
zlabel('Spectral Intensity (dBm)');
grid on;

% --- 3. Plot Left Spectrum Surface (CROPPED) ---
if ~isempty(WavelengthLeft_cropped)
    [X_left_matrix, Y_left_matrix] = meshgrid(WavelengthLeft_cropped, time);
    h_left = surf(X_left_matrix, Y_left_matrix, SpectrumLeft_cropped, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
end

% --- 4. Plot Right Spectrum Surface (CROPPED) ---
if ~isempty(WavelengthRight_cropped)
    [X_right_matrix, Y_right_matrix] = meshgrid(WavelengthRight_cropped, time);
    h_right = surf(X_right_matrix, Y_right_matrix, SpectrumRight_cropped, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
end

% --- 5. Highlight the Virtual Sensor Array (R^2 > 0.98 Points) ---
% A. Left Channel Highlights
for idx_full = Indices_R98_Left
    W_val = WavelengthLeft(idx_full);
    % Check if this high-quality point is within the current plot range
    if W_val >= Wavelength_Min && W_val <= Wavelength_Max
        % Loop through every time point (i.e., every row of data)
        for i = 1:length(time)
            t = time(i);
            Z_val = SpectrumLeft(i, idx_full);
            
            % Scatter plot: Wavelength (X), Time (Y), Intensity (Z). 
            % CHANGED: Swapped 'r' (red) to 'k' (black) for a consistent grayscale/monochrome look.
            scatter3(W_val, t, Z_val, 150, 'k', 'filled', 'MarkerEdgeColor', 'k', 'Marker', 'o', 'DisplayName', 'Virtual Sensor (R^2 > 0.98)');
        end
    end
end
% B. Right Channel Highlights
for idx_full = Indices_R98_Right
    W_val = WavelengthRight(idx_full);
    % Check if this high-quality point is within the current plot range
    if W_val >= Wavelength_Min && W_val <= Wavelength_Max
        % Loop through every time point (i.e., every row of data)
        for i = 1:length(time)
            t = time(i);
            Z_val = SpectrumRight(i, idx_full);
            
            % Scatter plot: Wavelength (X), Time (Y), Intensity (Z). 
            % CHANGED: Swapped 'r' (red) to 'k' (black) for a consistent grayscale/monochrome look.
            scatter3(W_val, t, Z_val, 150, 'k', 'filled', 'MarkerEdgeColor', 'k', 'Marker', 'o');
        end
    end
end

% --- 6. Customize Visualization ---
shading flat; 

if presentation == 2
    view(2); 
else
    view(3)
end

%camlight infinite;
%lighting phong;
colorbar;
% ---------------------------------------------------------------------------------
colormap(gray); 
% ---------------------------------------------------------------------------------
rotate3d on;
% Set dynamic axis limits based on the user's requested range
xlim([Wavelength_Min, Wavelength_Max]);
ylim([min(time), max(time)]);
% Set Z-limits for better perspective (consider both spectra's full data for Z-range)
all_data = [SpectrumLeft(:); SpectrumRight(:)];
z_min = min(all_data);
z_max = max(all_data);
zlim([z_min - 1, z_max + 1]); 
% Add a clean legend only for the sensor markers
h = findobj(gcf,'DisplayName','Virtual Sensor (R^2 > 0.98)');
if ~isempty(h)
    % Only keep one legend entry for the virtual sensor
    legend(h(1), 'Location', 'NorthEast'); 
end
hold off;