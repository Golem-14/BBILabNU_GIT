function FunctionCalibWithSavingPath(path, N_RI, N_Val, sensor_trace, minprom, maxpeakw, minpeakd, savedata, code_name, set, calibr, modif)
% This function analyzes sensor data, finds peaks and valleys, and
% calculates sensitivities based on a series of input parameters.
%
% Inputs:
%   N_RI          - Number of different RI values.
%   N_Val         - Number of times each RI value was measured.
%   sensor_trace  - The channel number corresponding to the sensor trace.
%   minprom       - Minimum peak prominence for findpeaks. Set to 0 to ignore.
%   maxpeakw      - Maximum peak width for findpeaks. Set to Inf to ignore.
%   minpeakd      - Minimum peak distance for findpeaks.
%   savedata      - Flag to save data (1 to save, 0 to not save).
%   code_name     - String for the probe's code name (e.g., "LV30").
%   set           - Numerical value for the data set.
%   calibr        - Numerical value for the calibration.
%   modif         - Numerical value for the modification.
%
% Example call:
%   analyze_sensor_data(6, 20, 6, 0, inf, 0, 0, "LV30", 18, 27, 0)
%
% Note: This function assumes the data files are named RI1_1.txt, RI1_2.txt, etc.,
% and that the RI values are hardcoded within the function. If you need
% to change the RI values, modify the 'RI' array below.
close all;

% Hardcoded RI values - modify as needed
RI = [1.34761 1.34974 1.35216 1.35457 1.35696 1.35845];

% Hardcoded parameters for probe signature creation
% These are now function inputs, but the string formatting remains.
probe_name = strcat(code_name, '_Set', num2str(set), '_Calib', num2str(calibr), '_MOD', num2str(modif), '_Chan', num2str(sensor_trace));

% --- Load Data ---
kk = 1;
for ii = 1:N_RI
    for jj = 1:N_Val
        Fname = strcat(path, '\', 'RI', num2str(ii), '_', num2str(jj), '.txt');
        Data = readmatrix(Fname);
        
        if (kk==1)
            Wavelength = Data(:,1);
        end
        
        % The following try/catch blocks are robust for channels that may not exist
        try
            CH1(kk,:) = Data(:,2);
        catch
        end
        try
            CH2(kk,:) = Data(:,3);
        catch
        end
        try
            CH3(kk,:) = Data(:,4);
        catch
        end
        try
            CH4(kk,:) = Data(:,5);
        catch
        end
        try
            CH5(kk,:) = Data(:,6);
        catch
        end
        try
            CH6(kk,:) = Data(:,7);
        catch
        end
        try
            CH7(kk,:) = Data(:,8);
        catch
        end
        try
            CH8(kk,:) = Data(:,9);
        catch
        end
        
        kk = kk+1;
    end
end
kk = kk-1;

% --- Processing ---
% Filtering
[b,a] = butter(5,0.01);
for ii = 1:kk
    CHF1(ii,:) = filter(b,a,CH1(ii,:));
    if exist('CH2', 'var')
        CHF2(ii,:) = filter(b,a,CH2(ii,:));
    end
    if exist('CH3', 'var')
        CHF3(ii,:) = filter(b,a,CH3(ii,:));
    end
    if exist('CH4', 'var')
        CHF4(ii,:) = filter(b,a,CH4(ii,:));
    end
    if exist('CH5', 'var')
        CHF5(ii,:) = filter(b,a,CH5(ii,:));
    end
    if exist('CH6', 'var')
        CHF6(ii,:) = filter(b,a,CH6(ii,:));
    end
    if exist('CH7', 'var')
        CHF7(ii,:) = filter(b,a,CH7(ii,:));
    end
    if exist('CH8', 'var')
        CHF8(ii,:) = filter(b,a,CH8(ii,:));
    end
end

% Remove left strange peak
Wavelength = Wavelength(1001:end);
CHF1 = CHF1(:,1001:end);
if exist('CHF2', 'var')
    CHF2 = CHF2(:,1001:end);
end
if exist('CHF3', 'var')
    CHF3 = CHF3(:,1001:end);
end
if exist('CHF4', 'var')
    CHF4 = CHF4(:,1001:end);
end
if exist('CHF5', 'var')
    CHF5 = CHF5(:,1001:end);
end
if exist('CHF6', 'var')
    CHF6 = CHF6(:,1001:end);
end
if exist('CHF7', 'var')
    CHF7 = CHF7(:,1001:end);
end
if exist('CHF8', 'var')
    CHF8 = CHF8(:,1001:end);
end

% Get reference from FBG
% NOTE: The FBG_trace is currently tied to the sensor_trace.
% You might consider making FBG_trace a separate input if it can vary.
FBG_trace = sensor_trace;
if FBG_trace == 1
    CHF_ref = CHF1;
elseif FBG_trace == 2
    CHF_ref = CHF2;
elseif FBG_trace == 3
    CHF_ref = CHF3;
elseif FBG_trace == 4
    CHF_ref = CHF4;
elseif FBG_trace == 5
    CHF_ref = CHF5;
elseif FBG_trace == 6
    CHF_ref = CHF6;
elseif FBG_trace == 7
    CHF_ref = CHF7;
elseif FBG_trace == 8
    CHF_ref = CHF8;
end

IND_FBG = 5000:19000;
for ii = 1:kk
    RefVal(ii) = max(CHF_ref(ii,IND_FBG));
end

% Remove reference (set the peak of FBG to be zero)
for ii = 1:kk
    CHF1(ii,:) = CHF1(ii,:) - RefVal(ii);
    if exist('CHF2', 'var')
        CHF2(ii,:) = CHF2(ii,:) - RefVal(ii);
    end
    if exist('CHF3', 'var')
        CHF3(ii,:) = CHF3(ii,:) - RefVal(ii);
    end
    if exist('CHF4', 'var')
        CHF4(ii,:) = CHF4(ii,:) - RefVal(ii);
    end
    if exist('CHF5', 'var')
        CHF5(ii,:) = CHF5(ii,:) - RefVal(ii);
    end
    if exist('CHF6', 'var')
        CHF6(ii,:) = CHF6(ii,:) - RefVal(ii);
    end
    if exist('CHF7', 'var')
        CHF7(ii,:) = CHF7(ii,:) - RefVal(ii);
    end
    if exist('CHF8', 'var')
        CHF8(ii,:) = CHF8(ii,:) - RefVal(ii);
    end
end

% Averages of all traces
for jj = 1:N_RI
    dd = N_Val*(jj-1)+1;
    CHF1_temp(jj,:) = mean(CHF1(dd:dd+(N_Val-1), :));
    if exist('CH2', 'var')
        CHF2_temp(jj,:) = mean(CHF2(dd:dd+(N_Val-1), :));
    end
    if exist('CH3', 'var')
        CHF3_temp(jj,:) = mean(CHF3(dd:dd+(N_Val-1), :));
    end
    if exist('CH4', 'var')
        CHF4_temp(jj,:) = mean(CHF4(dd:dd+(N_Val-1), :));
    end
    if exist('CH5', 'var')
        CHF5_temp(jj,:) = mean(CHF5(dd:dd+(N_Val-1), :));
    end
    if exist('CH6', 'var')
        CHF6_temp(jj,:) = mean(CHF6(dd:dd+(N_Val-1), :));
    end
    if exist('CH7', 'var')
        CHF7_temp(jj,:) = mean(CHF7(dd:dd+(N_Val-1), :));
    end
    if exist('CH8', 'var')
        CHF8_temp(jj,:) = mean(CHF8(dd:dd+(N_Val-1), :));
    end
end

CHF1 = CHF1_temp;
if exist('CH2', 'var')
    CHF2 = CHF2_temp;
end
if exist('CH3', 'var')
    CHF3 = CHF3_temp;
end
if exist('CH4', 'var')
    CHF4 = CHF4_temp;
end
if exist('CH5', 'var')
    CHF5 = CHF5_temp;
end
if exist('CH6', 'var')
    CHF6 = CHF6_temp;
end
if exist('CH7', 'var')
    CHF7 = CHF7_temp;
end
if exist('CH8', 'var')
    CHF8 = CHF8_temp;
end

% --- Plotting All Traces ---
figure
plot(Wavelength(1:end), CHF1(1,:), 'LineWidth',2);
hold on
if exist('CHF2', 'var')
    plot(Wavelength(1:end), CHF2(1,:), 'LineWidth',2);
end
if exist('CHF3', 'var')
    plot(Wavelength(1:end), CHF3(1,:), 'LineWidth',2);
end
if exist('CHF4', 'var')
    plot(Wavelength(1:end), CHF4(1,:), 'LineWidth',2);
end
if exist('CHF5', 'var')
    plot(Wavelength(1:end), CHF5(1,:), 'LineWidth',2);
end
if exist('CHF6', 'var')
    plot(Wavelength(1:end), CHF6(1,:), 'LineWidth',2);
end
if exist('CHF7', 'var')
    plot(Wavelength(1:end), CHF7(1,:), 'LineWidth',2);
end
if exist('CH8', 'var')
    plot(Wavelength(1:end), CHF8(1,:), 'LineWidth',2);
end
title('all traces')
legend('Trace 1','Trace 2','Trace 3','Trace 4','Trace 5','Trace 6','Trace 7','Trace 8')
xlabel('Wavelength (nm)');
ylabel('Return loss (dB)');

% --- Analysis ---
% Get the sensor trace
if sensor_trace == 1
    CHF_sens = CHF1;
elseif sensor_trace == 2
    CHF_sens = CHF2;
elseif sensor_trace == 3
    CHF_sens = CHF3;
elseif sensor_trace == 4
    CHF_sens = CHF4;
elseif sensor_trace == 5
    CHF_sens = CHF5;
elseif sensor_trace == 6
    CHF_sens = CHF6;
elseif sensor_trace == 7
    CHF_sens = CHF7;
elseif sensor_trace == 8
    CHF_sens = CHF8;
end

% Finding peaks
% Find peaks with a clean filter for accuracy
[b,a] = butter(5,0.1);
for ii = 1:N_RI
    CHF_sens_clean(ii,:) = filter(b,a,CHF_sens(ii,:));
end

% Getting preliminary peak and valley values and positions
[~, pre_peak_locs, ~, ~] = findpeaks(CHF_sens_clean(1,:),'MinPeakProminence', minprom, 'MaxPeakWidth', maxpeakw, 'MinPeakDistance', minpeakd);
[~, pre_valley_locs, ~, ~] = findpeaks(-CHF_sens_clean(1,:),'MinPeakProminence', minprom, 'MaxPeakWidth', maxpeakw, 'MinPeakDistance', minpeakd);

% Plotting peaks
figure
plot(Wavelength(1:end), CHF_sens(:,:), 'LineWidth',2);
hold on
% Check if pre_peak_locs is not empty before plotting
if ~isempty(pre_peak_locs)
    [pre_peaks, ~] = findpeaks(CHF_sens_clean(1,:),'MinPeakProminence', minprom, 'MaxPeakWidth', maxpeakw, 'MinPeakDistance', minpeakd);
    plot(Wavelength(pre_peak_locs), pre_peaks, '*', 'MarkerSize', 7)
end
% Check if pre_valley_locs is not empty before plotting
if ~isempty(pre_valley_locs)
    [pre_valleys, ~] = findpeaks(-CHF_sens_clean(1,:),'MinPeakProminence', minprom, 'MaxPeakWidth', maxpeakw, 'MinPeakDistance', minpeakd);
    plot(Wavelength(pre_valley_locs), -pre_valleys, '*', 'MarkerSize', 7)
end
title('Sensor trace')
xlabel('Wavelength (nm)');
ylabel('Return loss (dB)');

% Finding peaks and valleys of all measurements via 2nd order fitting of each pre-peak
if ~isempty(pre_peak_locs) && ~isempty(pre_valley_locs)
    interval = length(Wavelength)/(length(pre_peak_locs)+200);
else
    interval = 100; % Default interval if no peaks are found
end

n_peaks = length(pre_peak_locs);
n_valleys = length(pre_valley_locs);

% Initializing peak and valley arrays
peaks = zeros(N_RI, n_peaks);
peak_locs = zeros(N_RI, n_peaks);
valleys = zeros(N_RI, n_valleys);
valley_locs = zeros(N_RI, n_valleys);

% Peaks
for ii=1:n_peaks
    peak_i = pre_peak_locs(1,ii);
    
    if peak_i > interval  && peak_i+interval < length(Wavelength)
        for jj = 1:N_RI
            x = Wavelength(peak_i-interval:peak_i+interval);
            y = CHF_sens(jj,peak_i-interval:peak_i+interval);
            
            p = polyfit(x,y,2);
            peaks(jj,ii) = -p(2)^2/(4*p(1))+p(3);
            peak_locs(jj,ii) = -p(2)/(2*p(1));
            peak_polyvals(jj,ii,:) = polyval(p,x);
        end
        peak_intervals(ii,:) = x;
    end
end

% Plotting peaks
if ~isempty(peak_locs)
    figure
    for ii = 1:n_peaks
        peak_i = pre_peak_locs(1,ii);
        if peak_i > interval && peak_i+interval < length(Wavelength)
            subplot(5,ceil(n_peaks/5), ii)
            x = peak_intervals(ii,:);
            y = CHF_sens(:,peak_i-interval:peak_i+interval);
            plot(x, y, 'LineWidth',2)
            hold on
            plot(x,squeeze(peak_polyvals(:,ii,:)),'--','LineWidth',2)
            plot(peak_locs(:,ii), peaks(:,ii), '*', 'MarkerSize', 7)
            title(sprintf('Peak %i', ii))
        end
    end
end

% Valleys
for ii=1:n_valleys
    valley_i = pre_valley_locs(1,ii);
    
    if valley_i > interval && valley_i+interval < length(Wavelength)
        for jj = 1:N_RI
            x = Wavelength(valley_i-interval:valley_i+interval);
            y = CHF_sens(jj,valley_i-interval:valley_i+interval);
            
            p = polyfit(x,y,2);
            valleys(jj,ii) = -p(2)^2/(4*p(1))+p(3);
            valley_locs(jj,ii) = -p(2)/(2*p(1));
            valley_polyvals(jj,ii,:) = polyval(p,x);
        end
        valley_intervals(ii,:) = x;
    end
end

% Plotting valleys
if ~isempty(valley_locs)
    figure
    for ii = 1:n_valleys
        valley_i = pre_valley_locs(1,ii);
        if valley_i > interval && valley_i+interval < length(Wavelength)
            subplot(5,ceil(n_valleys/5), ii)
            x = valley_intervals(ii,:);
            y = CHF_sens(:,valley_i-interval:valley_i+interval);
            plot(x, y, 'LineWidth',2)
            hold on
            plot(x,squeeze(valley_polyvals(:,ii,:)),'--','LineWidth',2)
            plot(valley_locs(:,ii), valleys(:,ii), '*', 'MarkerSize', 7)
            title(sprintf('Valley %i', ii))
        end
    end
end

% Find sensitivities
x_ri = RI(:);
for kk=1:n_peaks
    y = peaks(:,kk);
    p = polyfit(x_ri,y,1);
    pp = polyval(p,x_ri);
    sens_peaks(kk) = p(1);
    r2_peaks(kk) = rsquare(y,pp);
end
for kk=1:n_valleys
    y = valleys(:,kk);
    p = polyfit(x_ri,y,1);
    pp = polyval(p,x_ri);
    sens_valleys(kk) = p(1);
    r2_valleys(kk) = rsquare(y,pp);
end

% Filtering r2 > 0.9
good_peaks_sens = sens_peaks(r2_peaks>0.9);
good_peaks_indices = find(r2_peaks>0.9);
n_good_peaks = length(good_peaks_indices);
good_valleys_sens = sens_valleys(r2_valleys>0.9);
good_valleys_indices = find(r2_valleys>0.9);
n_good_valleys = length(good_valleys_indices);

% Plot sensitive peaks and valleys
if ~isempty(good_peaks_sens)
    figure
    for ii=1:n_good_peaks
        ind = good_peaks_indices(ii);
        peak_i = pre_peak_locs(1,ind);
        subplot(5,ceil(n_good_peaks/5), ii)
        x = peak_intervals(ind,:);
        y = CHF_sens(:,peak_i-interval:peak_i+interval);
        plot(x, y, 'LineWidth',2)
        hold on
        plot(x,squeeze(peak_polyvals(:,ind,:)),'--','LineWidth',2)
        plot(peak_locs(:,ind), peaks(:,ind), '*', 'MarkerSize', 7)
        title(sprintf('Peak %i (%f dB/RIU)', ind, good_peaks_sens(ii)))
    end
end

if ~isempty(good_valleys_sens)
    figure
    for ii=1:n_good_valleys
        ind = good_valleys_indices(ii);
        valley_i = pre_valley_locs(1,ind);
        subplot(5,ceil(n_good_valleys/5), ii)
        x = valley_intervals(ind,:);
        y = CHF_sens(:,valley_i-interval:valley_i+interval);
        plot(x, y, 'LineWidth',2)
        hold on
        plot(x,squeeze(valley_polyvals(:,ind,:)),'--','LineWidth',2)
        plot(valley_locs(:,ind), valleys(:,ind), '*', 'MarkerSize', 7)
        title(sprintf('Valley %i (%f dB/RIU)', ind, good_valleys_sens(ii)))
    end
end

% Plot sensitivities
figure
if ~isempty(good_peaks_sens)
    plot(peak_locs(1,good_peaks_indices), good_peaks_sens, '.-', 'LineWidth', 2, 'MarkerSize', 15);
end
hold on
if ~isempty(good_valleys_sens)
    plot(valley_locs(1,good_valleys_indices), good_valleys_sens, '.-', 'LineWidth', 2, 'MarkerSize', 15);
end
if ~isempty(good_peaks_sens) && ~isempty(good_valleys_sens)
    if max(abs(good_peaks_sens)) > max(abs(good_valleys_sens))
        [m,ind] = max(abs(good_peaks_sens));
        plot(peak_locs(1,good_peaks_indices(ind)), good_peaks_sens(ind), 'm*', 'MarkerSize', 10)
    else
        [m,ind] = max(abs(good_valleys_sens));
        plot(valley_locs(1,good_valleys_indices(ind)), good_valleys_sens(ind), 'm*', 'MarkerSize', 10)
    end
    legend('peaks', 'valleys', strcat("Max sens = ", num2str(m), ' dB/RIU'))
else
    legend('peaks', 'valleys')
end
ylabel('Sensitivity (dB/RIU)');
xlabel('Wavelength (nm)');
title('Sensitivities')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% UNDER Construction %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the folder path and file name
outputFolder = strcat(path, '\MATLAB_Output');


% Check if the folder exists and create it if it doesn't
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Now save the matrix



% Modifications for probe signature creation
if savedata == 1
    writematrix(pre_peak_locs, strcat(outputFolder, '\', probe_name, '_pre_peak_locs', '.csv'))
    writematrix(pre_valley_locs, strcat(outputFolder, '\', probe_name, '_pre_valley_locs', '.csv'))
    writematrix(sens_peaks, strcat(outputFolder, '\', probe_name, '_sens_peaks', '.csv'))
    writematrix(sens_valleys, strcat(outputFolder, '\', probe_name, '_sens_valleys', '.csv'))
    writematrix(r2_peaks, strcat(outputFolder, '\', probe_name, '_r2_peaks', '.csv'))
    writematrix(r2_valleys, strcat(outputFolder, '\', probe_name, '_r2_valleys', '.csv'))
end

end

% Local helper function to calculate R-squared
function r = rsquare(y, f)
    % R-squared = 1 - (sum of squares of residuals / total sum of squares)
    r = 1 - sum((y - f).^2) / sum((y - mean(y)).^2);
end
