% Data loading and filtering
clear all;
close all;
clc;
path = "C:\Users\User\Documents\Lyubov\Readings\Calib 47.1 Set 32 SS=1000, ts =1, n=60"; % path to the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Parameters initialization start %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input your data in this section
% For visual inspection it is crucial to provide good zoom-in because 
% relative intensity changes are small and
% not visible on the plot of the whole spectrum

N_Conc = 6; % Number of Conc. values
N_Val = 60; % Number of times each Conc. was sampled
chanNumber = 3; % The channel being analysed
calibration = 1; % do you use it for calibration (choose 1) or detection (choose 0)
filterpass = -1; %what type of filter you want to use:
% if choosing 2 - extremely high pass
% if choosing 1 - high pass
% if choosing -1 - low pass
% if choosing -2 - extremely low pass


%Suppose you want to examine a channel, then there are two options:
% - channel HAS PEAKS AND VALLEYS detected but sensitivity is bad/absent:
%       input PVfound = 1; the program will take actual peaks
% - channel has NO (OR TOO LITTLE) peaks and valleys detected:
%       input PVfound = 0; the program will take random values
PVfound = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%
%Indices of peaks and vallyes you want to analyze
LeftLocPeak = 2; %input here a peak you want to examine (index from LocPeakLeft)
LeftLocValley = 1; %input here a valley you want to examine (index from LocValleyLeft)
RightLocPeak = 1; %input here a peak you want to examine (index from LocPeakRight)
RightLocValley = 1; %input here a valley you want to examine (index from LocValleyRight)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Parameters initialization stop  %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% You do not need to input anything below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if filterpass == -2
    % Extremely low-pass filter
    [b,a] = butter(5,0.001);
end
if filterpass == -1
    % Low-pass filter
    [b,a] = butter(5,0.01);
end
if filterpass == 1
    % High-pass filter
    [b,a] = butter(5,0.1);
end
if filterpass == 2
    % Extremely high-pass filter
    [b,a] = butter(5,0.5);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Load data from files %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
kk = 1;
for ii = 1:N_Conc
    for jj = 1:N_Val
        
        if calibration == 1
            Fname = strcat(path, '\', 'RI', num2str(ii), '_', num2str(jj), '.txt');
        else
            Fname = strcat(path, '\', 'concentration', num2str(ii), '_measurement', num2str(jj), '.txt');
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
% Select spectral portions (SLICING RESTORED)
TRANSIENT = 1000; % Length of filter transient
FBG_LEFT = 11000; % Leftmost part of the FBG spectrum
FBG_RIGHT = 12000; % Rightmost part of the FBG spectrum
SpectrumLeft = ChannelData(:,TRANSIENT:FBG_LEFT); % Left spectrum: cut out the transient, for SDI analysis
SpectrumFBG = ChannelData(:,FBG_LEFT:FBG_RIGHT); % Spectral portion containing the FBG (EXCLUDED FROM PLOT)
SpectrumRight = ChannelData(:,FBG_RIGHT:end); % Right part of the spectrum for SDI analysis
WavelengthLeft = Wavelength(TRANSIENT:FBG_LEFT);
WavelengthFBG = Wavelength(FBG_LEFT:FBG_RIGHT);
WavelengthRight = Wavelength(FBG_RIGHT:end);

% --- NEW: Combine Left and Right Regions for Full Plotting ---
SpectrumCombined = [SpectrumLeft, SpectrumRight];
WavelengthCombined = [WavelengthLeft; WavelengthRight];
if size(WavelengthCombined, 1) > 1
     WavelengthCombined = WavelengthCombined'; % Ensure row vector for meshgrid
end


% Identify peaks and valleys
N_Index = 1; % Index of the spectral measurement for peak search
MPP = 1.5; % Min. peak prominence
% Peak finding runs on the SLICED data, consistent with original script
SpectrumLeft_P = SpectrumLeft(N_Index,:);
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
    % These indices are relative to the SLICED regions
    [~, N_left] = size(SpectrumLeft);
    [~, N_right] = size(SpectrumRight);
    LocPeakLeft = randi([1, N_left], 1, 10);
    LocValleyLeft = randi([1, N_left], 1, 10);
    LocPeakRight = randi([1, N_right], 1, 10);
    LocValleyRight = randi([1, N_right], 1, 10);
    
end
% Extract timeline
time = 0 : (kk-1);
% Extract levels for each concentration
ConcentrationIndex = 1:N_Conc;
%%
% VISUAL ANALYSIS: COMBINED FULL LEFT AND RIGHT SPECTRAL REGIONS
% --- Script to Create a Single 3D Surface Plot of the Left and Right Spectrum (EXCLUDING FBG) ---
% -------------------------------------------------------------------------------------------------
% --- ASSUMED WORKSPACE VARIABLES ---
% WavelengthCombined: Combined Wavelength arrays (1xN_combined)
% time: Time vector (1xM or Mx1)
% SpectrumCombined: Combined Intensity matrix (M rows (time) x N_combined columns (Wavelength))
%
% --- NEW Required Variables for Virtual Sensor Highlight ---
% NOTE: The indices for R98 must now refer to the COMBINED WavelengthCombined array.
% The original Left/Right indices are kept but must be mapped to the combined array.
% ---------------------------------------------------------
% --- SETUP: Ensure data consistency and define R98 indices ---
if size(time, 1) > 1
    time = time'; % Ensure time is a row vector
end

% >>> IMPORTANT: DEFINE YOUR R^2 > 0.98 INDICES HERE <<<
% Placeholder indices for demonstration. REPLACE THESE LINES with your actual data.
% NOTE: These indices must now map to the COMBINED WavelengthCombined array.
if ~exist('Indices_R98_Left', 'var')
    % Example: Indices 5, 20, 35 in the LEFT portion of the COMBINED array
    Indices_R98_Left = [5, 20, 35]; 
end
if ~exist('Indices_R98_Right', 'var')
    % Example: Indices 10, 50, 90 in the RIGHT portion of the COMBINED array
    Indices_R98_Right = [10, 50, 90]; 
end

% Calculate offset for Right indices in the Combined Array
[~, N_left_combined] = size(SpectrumLeft);
Indices_R98_Full = [Indices_R98_Left, Indices_R98_Right + N_left_combined];


% --- FIGURE: FULL SURFACE PLOT SETUP ---
figure;
hold on;
title('Combined Left and Right Spectral Surface (FBG and Transient Excluded)');
xlabel('Wavelength (nm)');
ylabel('Time (min)');
zlabel('Spectral Intensity (dBm)');
grid on;

% --- 3. Plot Combined Spectrum Surface ---
if ~isempty(WavelengthCombined)
    [X_matrix, Y_matrix] = meshgrid(WavelengthCombined, time);
    h_surf = surf(X_matrix, Y_matrix, SpectrumCombined, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
end



% --- 4. Highlight the Virtual Sensor Array (R^2 > 0.98 Points) ---
for idx_combined = Indices_R98_Full
    % Ensure index is within bounds
    if idx_combined >= 1 && idx_combined <= length(WavelengthCombined)
        W_val = WavelengthCombined(idx_combined);
        % Loop through every time point
        for i = 1:length(time)
            t = time(i);
            Z_val = SpectrumCombined(i, idx_combined);
            
            % Scatter plot: Wavelength (X), Time (Y), Intensity (Z). 
            scatter3(W_val, t, Z_val, 150, 'k', 'filled', 'MarkerEdgeColor', 'k', 'Marker', 'o', 'DisplayName', 'Virtual Sensor (R^2 > 0.98)');
        end
    end
end

% --- 5. Customize Visualization ---
shading flat; 
view(2); 
colorbar;
% ⚠️ Use 'gray' colormap instead of 'parula' for grayscale shading.
colormap("jet"); 
rotate3d on;

% Set dynamic axis limits based on the combined range
xlim([min(WavelengthCombined), max(WavelengthCombined)]);
ylim([min(time), max(time)]);

% Set Z-limits for better perspective (consider the combined data for Z-range)
all_data_combined = SpectrumCombined(:);
z_min = min(all_data_combined);
z_max = max(all_data_combined);
zlim([z_min - 1, z_max + 1]); 

% Add a clean legend only for the sensor markers
h = findobj(gcf,'DisplayName','Virtual Sensor (R^2 > 0.90)');
if ~isempty(h)
    % Only keep one legend entry for the virtual sensor
    legend(h(1), 'Location', 'NorthEast'); 
end
hold off;

% The original four zoomed-in visual analysis sections (%% Visual inspection of peaks - LEFT, etc.) are now DELETED.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Created by Lyubov Vassilets (2025, BBILab NU)
% based on original scripts for calibration and data analysis
% in the case of issues or suggestions - 
% contact info: lyubov.vassilets@alumni.nu.edu.kz