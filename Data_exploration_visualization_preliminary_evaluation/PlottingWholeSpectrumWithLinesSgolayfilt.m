% Data loading and filtering
clear all;
close all;
clc;
path = "C:\Users\User\Documents\Lyubov\Readings\Calib 47.1 Set 32 SS=1000, ts =1, n=60"; % path to the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Parameters initialization start %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_Conc = 6; % Number of Conc. values
N_Val = 20; % Number of times each Conc. was sampled
chanNumber = 1; % The channel being analysed
calibration = 1; % do you use it for calibration (choose 1) or detection (choose 0)
filterpass = -1; % low pass filter

PVfound = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%
% Indices of peaks and valleys you want to analyze
LeftLocPeak = 2; 
LeftLocValley = 1; 
RightLocPeak = 1; 
RightLocValley = 1; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Parameters initialization stop  %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if filterpass == -2
    [b,a] = butter(5,0.001);
end
if filterpass == -1
    [b,a] = butter(5,0.01);
end
if filterpass == 1
    [b,a] = butter(5,0.1);
end
if filterpass == 2
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
        
        if (kk==1)
            Wavelength = Mat(:,1);
        end
        
        % Channel Loading Logic
        if (D2>=2), CH1(kk,:) = Mat(:,2); else CH1(kk,:) = zeros(D1,1); end
        if (D2>=3), CH2(kk,:) = Mat(:,3); else CH2(kk,:) = zeros(D1,1); end
        if (D2>=4), CH3(kk,:) = Mat(:,4); else CH3(kk,:) = zeros(D1,1); end
        if (D2>=5), CH4(kk,:) = Mat(:,5); else CH4(kk,:) = zeros(D1,1); end
        if (D2>=6), CH5(kk,:) = Mat(:,6); else CH5(kk,:) = zeros(D1,1); end
        if (D2>=7), CH6(kk,:) = Mat(:,7); else CH6(kk,:) = zeros(D1,1); end
        if (D2>=8), CH7(kk,:) = Mat(:,8); else CH7(kk,:) = zeros(D1,1); end
        if (D2>=9), CH8(kk,:) = Mat(:,9); else CH8(kk,:) = zeros(D1,1); end
        kk = kk+1;
    end
end
kk = kk-1;

order = 3; 
framelen = 21; % Must be odd. Larger = smoother.


%%% Filter data
for ii = 1:kk
    CHF1(ii,:) = sgolayfilt(CH1(ii,:), order, framelen);
    CHF2(ii,:) = sgolayfilt(CH2(ii,:), order, framelen);
    CHF3(ii,:) = sgolayfilt(CH3(ii,:), order, framelen);
    CHF4(ii,:) = sgolayfilt(CH4(ii,:), order, framelen);
    CHF5(ii,:) = sgolayfilt(CH5(ii,:), order, framelen);
    CHF6(ii,:) = sgolayfilt(CH6(ii,:), order, framelen);
    CHF7(ii,:) = sgolayfilt(CH7(ii,:), order, framelen);
    CHF8(ii,:) = sgolayfilt(CH8(ii,:), order, framelen);
end

% Data preprocessing channel selection
if chanNumber == 1, ChannelData = CHF1; end
if chanNumber == 2, ChannelData = CHF2; end
if chanNumber == 3, ChannelData = CHF3; end
if chanNumber == 4, ChannelData = CHF4; end
if chanNumber == 5, ChannelData = CHF5; end
if chanNumber == 6, ChannelData = CHF6; end
if chanNumber == 7, ChannelData = CHF7; end
if chanNumber == 8, ChannelData = CHF8; end

% Slicing
TRANSIENT = 1000; 
FBG_LEFT = 11000; 
FBG_RIGHT = 12000; 
SpectrumLeft = ChannelData(:,TRANSIENT:FBG_LEFT);
SpectrumFBG = ChannelData(:,FBG_LEFT:FBG_RIGHT);
SpectrumRight = ChannelData(:,FBG_RIGHT:end);
WavelengthLeft = Wavelength(TRANSIENT:FBG_LEFT);
WavelengthFBG = Wavelength(FBG_LEFT:FBG_RIGHT);
WavelengthRight = Wavelength(FBG_RIGHT:end);

% Combine Regions
SpectrumCombined = [SpectrumLeft, SpectrumRight];
WavelengthCombined = [WavelengthLeft; WavelengthRight];
if size(WavelengthCombined, 1) > 1
     WavelengthCombined = WavelengthCombined';
end

% Peak finding
N_Index = 1; 
MPP = 1.5; 
SpectrumLeft_P = SpectrumLeft(N_Index,:);
SpectrumRight_P = SpectrumRight(N_Index,:);
[P, LocPeakLeft] = findpeaks(SpectrumLeft_P, 'MinPeakProminence',MPP);
[P, LocPeakRight] = findpeaks(SpectrumRight_P, 'MinPeakProminence',MPP);
[P, LocValleyLeft] = findpeaks(-SpectrumLeft_P, 'MinPeakProminence',MPP);
[P, LocValleyRight] = findpeaks(-SpectrumRight_P, 'MinPeakProminence',MPP);

if PVfound == 0
    [~, N_left] = size(SpectrumLeft);
    [~, N_right] = size(SpectrumRight);
    LocPeakLeft = randi([1, N_left], 1, 10);
    LocValleyLeft = randi([1, N_left], 1, 10);
    LocPeakRight = randi([1, N_right], 1, 10);
    LocValleyRight = randi([1, N_right], 1, 10);
end

time = 0 : (kk-1);
if size(time, 1) > 1, time = time'; end

% Virtual Sensor setup
if ~exist('Indices_R98_Left', 'var'), Indices_R98_Left = [5, 20, 35]; end
if ~exist('Indices_R98_Right', 'var'), Indices_R98_Right = [10, 50, 90]; end
[~, N_left_combined] = size(SpectrumLeft);
Indices_R98_Full = [Indices_R98_Left, Indices_R98_Right + N_left_combined];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% VISUALIZATION SECTION %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
hold on;
title('Combined Spectral Surface with 10-Point Intervals');
xlabel('Wavelength (nm)');
ylabel('Time (Measurement Index)');
zlabel('Spectral Intensity (dBm)');
grid on;

% 1. Calculate Z-limits first to avoid errors
all_data_combined = SpectrumCombined(:);
z_min = min(all_data_combined);
z_max = max(all_data_combined);

% 2. Plot Combined Spectrum Surface
if ~isempty(WavelengthCombined)
    [X_matrix, Y_matrix] = meshgrid(WavelengthCombined, time);
    h_surf = surf(X_matrix, Y_matrix, SpectrumCombined, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
end

% 3. ADD HORIZONTAL LINES EVERY 10 DATA POINTS
x_line_range = [min(WavelengthCombined), max(WavelengthCombined)];
for y_val = 0:10:max(time)
    % Draw lines slightly above the surface (z_max + 0.5) to ensure visibility
    line(x_line_range, [y_val, y_val], [z_max + 0.5, z_max + 0.5], ...
        'Color', 'w', 'LineWidth', 0.6, 'LineStyle', '--', 'HandleVisibility', 'off');
end

% 4. Highlight the Virtual Sensor Array
sensor_plotted = false;
for idx_combined = Indices_R98_Full
    if idx_combined >= 1 && idx_combined <= length(WavelengthCombined)
        W_val = WavelengthCombined(idx_combined);
        for i = 1:length(time)
            t = time(i);
            Z_val = SpectrumCombined(i, idx_combined);
            h_scat = scatter3(W_val, t, Z_val, 150, 'k', 'filled', 'MarkerEdgeColor', 'k', 'DisplayName', 'Virtual Sensor');
            sensor_plotted = true;
        end
    end
end

% 5. Final Styling
shading flat; 
view(2); 
colorbar;
colormap("jet"); 
rotate3d on;
xlim([min(WavelengthCombined), max(WavelengthCombined)]);
ylim([min(time), max(time)]);
zlim([z_min - 1, z_max + 2]); 

if sensor_plotted
    legend(h_scat(1), 'Location', 'NorthEast');
end
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by Lyubov Vassilets (2025, BBILab NU)
% based on original scripts for calibration and data analysis
% in the case of issues or suggestions - 
% contact info: lyubov.vassilets@alumni.nu.edu.kz