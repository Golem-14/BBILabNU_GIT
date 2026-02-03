clear all
close all
clc

%%%%%% Path to data
pathToData = "path to your data"; % input path to your folder

%%%%%% Parameters
N_RI = 6; 
N_Val = 20; 
RI = [1.34761 1.34974 1.35216 1.35457 1.35696 1.35845]; 
sensor_trace = 1;
FBG_trace = sensor_trace;
sensor_name = "Name_Code";
laser_scan_speed = "1000Hz"; % Enlight saves 1000 Hz by default

%%%%%% Load data with Progress Bar
h = waitbar(0, 'Initializing data loading...', 'Name', 'Processing Fiber Sensor Data');
total_files = N_RI * N_Val;
kk = 1;

for ii = 1:N_RI
    for jj = 1:N_Val
        % Update progress bar
        current_prog = kk / total_files;
        waitbar(current_prog, h, sprintf('Loading RI %d of %d: File %d of %d', ii, N_RI, jj, N_Val));
        
        Fname = strcat(pathToData, '\', 'RI', num2str(ii), '_', num2str(jj), '.txt');
        Data = importdata(Fname);
        Mat = Data.data;
        
        if (kk==1)
            Wavelength = Mat(:,1);
        end
        
        CH1(kk,:) = Mat(:,2);
        % ... (CH2 through CH8 logic remains exactly as you had it)
        try CH2(kk,:) = Mat(:,3); catch; end
        try CH3(kk,:) = Mat(:,4); catch; end
        try CH4(kk,:) = Mat(:,5); catch; end
        try CH5(kk,:) = Mat(:,6); catch; end
        try CH6(kk,:) = Mat(:,7); catch; end
        try CH7(kk,:) = Mat(:,8); catch; end
        try CH8(kk,:) = Mat(:,9); catch; end
        
        kk = kk+1;
    end
end
kk = kk-1;

%%%%%% Processing
% Update progress bar for filtering
waitbar(0, h, 'Applying Butterworth Filter...');

filter_name = "Buttherworth_filter";
[b,a] = butter(5,0.01);

for ii = 1:kk
    waitbar(ii/kk, h, 'Filtering signal traces...');
    CHF1(ii,:) = filter(b,a,CH1(ii,:));
    if exist('CH2','var'); CHF2(ii,:) = filter(b,a,CH2(ii,:)); end
    if exist('CH3','var'); CHF3(ii,:) = filter(b,a,CH3(ii,:)); end
    if exist('CH4','var'); CHF4(ii,:) = filter(b,a,CH4(ii,:)); end
    if exist('CH5','var'); CHF5(ii,:) = filter(b,a,CH5(ii,:)); end
    if exist('CH6','var'); CHF6(ii,:) = filter(b,a,CH6(ii,:)); end
    if exist('CH7','var'); CHF7(ii,:) = filter(b,a,CH7(ii,:)); end
    if exist('CH8','var'); CHF8(ii,:) = filter(b,a,CH8(ii,:)); end
end

% Close progress bar once data is pre-processed
close(h);


%remove left strange peak
Wavelength = Wavelength(1001:end);
CHF1 = CHF1(:,1001:end);
if exist('CHF2')
    CHF2 = CHF2(:,1001:end);
end
if exist('CHF3')
    CHF3 = CHF3(:,1001:end);
end
if exist('CHF4')
    CHF4 = CHF4(:,1001:end);
end
if exist('CHF5')
    CHF5 = CHF5(:,1001:end);
end
if exist('CHF6')
    CHF6 = CHF6(:,1001:end);
end
if exist('CHF7')
    CHF7 = CHF7(:,1001:end);
end
if exist('CHF8')
    CHF8 = CHF8(:,1001:end);
end

% Get reference from FBG
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
    if exist('CHF2')
        CHF2(ii,:) = CHF2(ii,:) - RefVal(ii);
    end
    if exist('CHF3')
        CHF3(ii,:) = CHF3(ii,:) - RefVal(ii);
    end
    if exist('CHF4')
        CHF4(ii,:) = CHF4(ii,:) - RefVal(ii);
    end
    if exist('CHF5')
        CHF5(ii,:) = CHF5(ii,:) - RefVal(ii);
    end
    if exist('CHF6')
        CHF6(ii,:) = CHF6(ii,:) - RefVal(ii);
    end
    if exist('CHF7')
        CHF7(ii,:) = CHF7(ii,:) - RefVal(ii);
    end
    if exist('CHF8')
        CHF8(ii,:) = CHF8(ii,:) - RefVal(ii);
    end
end

%%%%%%
%%%%%% plotting
%%%%%%

%for now take the first of the measurements, later maybe take average
for jj = 1:N_RI
    dd = N_Val*(jj-1)+1;
    CHF1_temp(jj,:) = mean(CHF1(dd:dd+(N_Val-1), :));
    if exist('CH2')
        CHF2_temp(jj,:) = mean(CHF2(dd:dd+(N_Val-1), :));
    end
    if exist('CH3')
        CHF3_temp(jj,:) = mean(CHF3(dd:dd+(N_Val-1), :));
    end
    if exist('CH4')
        CHF4_temp(jj,:) = mean(CHF4(dd:dd+(N_Val-1), :));
    end
    if exist('CH5')
        CHF5_temp(jj,:) = mean(CHF5(dd:dd+(N_Val-1), :));
    end
    if exist('CH6')
        CHF6_temp(jj,:) = mean(CHF6(dd:dd+(N_Val-1), :));
    end
    if exist('CH7')
        CHF7_temp(jj,:) = mean(CHF7(dd:dd+(N_Val-1), :));
    end
    if exist('CH8')
        CHF8_temp(jj,:) = mean(CHF7(dd:dd+(N_Val-1), :));
    end
end

CHF1 = CHF1_temp;
if exist('CH2')
    CHF2 = CHF2_temp;
end
if exist('CH3')
    CHF3 = CHF3_temp;
end
if exist('CH4')
    CHF4 = CHF4_temp;
end
if exist('CH5')
    CHF5 = CHF5_temp;
end
if exist('CH6')
    CHF6 = CHF6_temp;
end
if exist('CH7')
    CHF7 = CHF7_temp;
end
if exist('CH8')
    CHF8 = CHF8_temp;
end

%plotting all traces
figure
plot(Wavelength(1:end), CHF1(1,:), 'LineWidth',2);
hold on
if exist('CHF2')
    plot(Wavelength(1:end), CHF2(1,:), 'LineWidth',2);
end
if exist('CHF3')
    plot(Wavelength(1:end), CHF3(1,:), 'LineWidth',2);
end
if exist('CHF4')
    plot(Wavelength(1:end), CHF4(1,:), 'LineWidth',2);
end
if exist('CHF5')
    plot(Wavelength(1:end), CHF5(1,:), 'LineWidth',2);
end
if exist('CHF6')
    plot(Wavelength(1:end), CHF6(1,:), 'LineWidth',2);
end
if exist('CHF7')
    plot(Wavelength(1:end), CHF7(1,:), 'LineWidth',2);
end
if exist('CH8')
    plot(Wavelength(1:end), CHF8(1,:), 'LineWidth',2);
end
title('all traces')
legend('Trace 1','Trace 2','Trace 3','Trace 4','Trace 5','Trace 6','Trace 7','Trace 8')

xlabel('Wavelength (nm)');
ylabel('Return loss (dB)');


%%%%%%
%%%%%% analysis
%%%%%%

%get the sensor trace
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

%finding peaks
%find peaks with a very clean filter for accuracy
[b,a] = butter(5,0.1);
for ii = 1:N_RI
    CHF_sens_clean(ii,:) = filter(b,a,CHF_sens(ii,:));
end

%getting preliminary peak and valley values and positions
[pre_peaks(1,:), pre_peak_locs(1,:)] = findpeaks(CHF_sens_clean(1,:));
[pre_valleys(1,:), pre_valley_locs(1,:)] = findpeaks(-CHF_sens_clean(1,:));

%plotting peaks
figure 
plot(Wavelength(1:end), CHF_sens(:,:), 'LineWidth',2);
hold on
plot(Wavelength(pre_peak_locs), pre_peaks, '*', 'MarkerSize', 7)
plot(Wavelength(pre_valley_locs), -pre_valleys, '*', 'MarkerSize', 7)
title('Sensor trace')
xlabel('Wavelength (nm)');
ylabel('Return loss (dB)');

%finding peaks and valleys of all measurements via 2nd order fitting of each pre-peak
interval = length(Wavelength)/(length(pre_peak_locs)+200);
n_peaks = length(pre_peak_locs);
n_valleys = length(pre_valley_locs);

%initializing peak and valley arrays
peaks = zeros(N_RI, n_peaks);
peak_locs = zeros(N_RI, n_peaks);
valleys = zeros(N_RI, n_valleys);
valley_locs = zeros(N_RI, n_valleys);


%############### CHANGE 290126 ###############


% Ensure interval is an integer once before starting
int_val = round(interval); 

for ii = 1:n_peaks
    % 1. Enforce integer indexing for the current peak center
    peak_i = round(pre_peak_locs(1, ii));
    
    % 2. Safety Check (using the integer version of interval)
    if peak_i > int_val && peak_i + int_val < length(Wavelength)
        
        % 3. Extract and Center Wavelength (Numerical Stability)
        % Using x_raw for peak_intervals, and x_shifted for polyfit
        idx_range = peak_i - int_val : peak_i + int_val;
        x_raw = Wavelength(idx_range);
        x_raw = x_raw(:); % Ensure column
        
        % Center around the middle of the window
        mid_pt = floor(length(x_raw)/2) + 1;
        x_center = x_raw(mid_pt); 
        x_shifted = x_raw - x_center; 
        
        for jj = 1:N_RI
            y = CHF_sens(jj, idx_range);
            y = y(:); % Ensure column
            
            % 4. Quadratic fit (2nd order)
            p = polyfit(x_shifted, y, 2);
            
            % 5. Peak Amplitude Calculation (c - b^2/4a)
            peaks(jj, ii) = p(3) - (p(2)^2) / (4*p(1));
            
            % 6. Peak Location Calculation
            % Calculate vertex on shifted scale, then add x_center back
            opt_x_shifted = -p(2) / (2*p(1));
            peak_locs(jj, ii) = opt_x_shifted + x_center;
    
            % 7. Store Polyvals (Keep dimensions compatible with original)
            % Note: We use x_shifted to match how 'p' was generated
            peak_polyvals(jj, ii, :) = polyval(p, x_shifted);
        end
    
        % Maintain original variable name
        peak_intervals(ii, :) = x_raw';
    end
end


%#################


% --- Optimized Plotting Peaks ---
figure
for ii = 1:n_peaks
    peak_i = round(pre_peak_locs(1,ii)); % Ensure integer
    int_val = round(interval);           % Ensure integer
    
    if peak_i > int_val && peak_i + int_val < length(Wavelength)
        subplot(5, ceil(n_peaks/5), ii)
        
        % 1. Get X and ensure it's a column
        x = peak_intervals(ii, :);
        x = x(:); 
        
        % 2. Get Y (Matrix of all RI steps for this peak)
        % We transpose it (') to make the columns match the length of x
        y = CHF_sens(:, peak_i - int_val : peak_i + int_val)';
    
        % 3. Plotting Raw Data
        plot(x, y, 'LineWidth', 2) 
        hold on
        
        % 4. Plotting the Fits
        % squeeze() makes it a matrix, transpose (') makes it match x
        y_fit = squeeze(peak_polyvals(:, ii, :))';
        plot(x, y_fit, '--', 'LineWidth', 1)
        
        % 5. Plotting the detected Maxima
        plot(peak_locs(:, ii), peaks(:, ii), '*', 'MarkerSize', 7)
        
        title(sprintf('Peak %i', ii))
        grid on
    end
end


% Ensure interval is an integer once
int_val = round(interval); 

for ii = 1:n_valleys
    % 1. Enforce integer indexing for the current valley center
    valley_i = round(pre_valley_locs(1, ii));
    
    % 2. Safety Check (using integer logic)
    if valley_i > int_val && valley_i + int_val < length(Wavelength)
        
        % Define the integer range for indexing
        idx_range = (valley_i - int_val) : (valley_i + int_val);
        
        % 3. Extract and Center Wavelength
        x_raw = Wavelength(idx_range);
        x_raw = x_raw(:); % Force column orientation
        
        mid_pt = floor(length(x_raw)/2) + 1;
        x_center = x_raw(mid_pt); 
        x_shifted = x_raw - x_center; 
        
        for jj = 1:N_RI
            % Use the pre-calculated integer index range
            y = CHF_sens(jj, idx_range);
            y = y(:); % Force column
            
            % 4. Quadratic fit to shifted data
            p = polyfit(x_shifted, y, 2);
            
            % 5. Valley Amplitude (p(3) - b^2/4a)
            valleys(jj, ii) = p(3) - (p(2)^2) / (4*p(1));
            
            % 6. Valley Location
            opt_x_shifted = -p(2) / (2*p(1));
            valley_locs(jj, ii) = opt_x_shifted + x_center;
    
            % 7. Store Polyvals
            valley_polyvals(jj, ii, :) = polyval(p, x_shifted);
        end
    
        % Maintain original variable name structure
        valley_intervals(ii, :) = x_raw';
    end
end



% --- Plotting Valleys ---
figure
for ii = 1:n_valleys
    % Ensure indices are integers to prevent colon operator warnings
    val_i = round(pre_valley_locs(1,ii));
    int_val = round(interval);
    
    if val_i > int_val && val_i + int_val < length(Wavelength)
        subplot(5, ceil(n_valleys/5), ii)
        
        % 1. Extract X and force it to be a column vector
        x = valley_intervals(ii, :);
        x = x(:); 
        
        % 2. Extract Y and transpose it (') to align with x
        % Original: [N_RI x Window] -> Transposed: [Window x N_RI]
        y = CHF_sens(:, val_i - int_val : val_i + int_val)';
    
        % 3. Plot Raw Data (One line per RI step)
        plot(x, y, 'LineWidth', 2)
        hold on
        
        % 4. Plot the Fits
        % Squeeze turns [RI x 1 x Window] into [RI x Window]
        % Transpose (') makes it [Window x RI] to match x
        y_fit = squeeze(valley_polyvals(:, ii, :))';
        plot(x, y_fit, '--', 'LineWidth', 1)
        
        % 5. Plot the detected Minima (the vertex of the parabola)
        plot(valley_locs(:, ii), valleys(:, ii), '*', 'MarkerSize', 7)
        
        title(sprintf('Valley %i', ii))
        grid on
    end
end


%######################################################################


% SUGGESTED BY GENIMI

% --- Main Logic ---
% Define the design matrix once: y = mx + c
X_mat = [RI(:), ones(numel(RI), 1)];

% Process Peaks
[sens_peaks, r2_peaks] = analyze_sensitivity(peaks, X_mat);

% Process Valleys
[sens_valleys, r2_valleys] = analyze_sensitivity(valleys, X_mat);

% --- Filtering (Keeping your original naming convention) ---
% For Peaks
good_peaks_indices = find(r2_peaks > 0.9);
good_peaks_sens    = sens_peaks(good_peaks_indices);
n_good_peaks       = length(good_peaks_indices);

% For Valleys
good_valleys_indices = find(r2_valleys > 0.9);
good_valleys_sens    = sens_valleys(good_valleys_indices);
n_good_valleys       = length(good_valleys_indices);

% --- Helper Function ---
function [svec, rvec] = analyze_sensitivity(data, X)
    num_features = size(data, 2);
    svec = zeros(1, num_features);
    rvec = zeros(1, num_features);
    
    for kk = 1:num_features
        y = data(:, kk);
        % Solve for [slope; intercept] using backslash operator
        beta = X \ y; 
        svec(kk) = beta(1);
        
        % Calculate R-squared: 1 - (SS_res / SS_tot)
        y_fit = X * beta;
        ss_res = sum((y - y_fit).^2);
        ss_tot = sum((y - mean(y)).^2);
        rvec(kk) = 1 - (ss_res / ss_tot);
    end
end




%###################################################


% --- Plotting Filtered "Good" Peaks ---
figure  
for ii = 1:n_good_peaks
    % Get the original index of the 'good' peak
    ind = good_peaks_indices(ii);
    
    % Ensure indices are integers
    peak_i = round(pre_peak_locs(1, ind));
    int_val = round(interval);
    
    subplot(5, ceil(n_good_peaks/5), ii)
    
    % 1. X as a column vector
    x = peak_intervals(ind, :);
    x = x(:); 
    
    % 2. Y as a matrix where columns match X length
    % Transpose the slice: [N_RI x Window] becomes [Window x N_RI]
    y = CHF_sens(:, peak_i - int_val : peak_i + int_val)';
    
    % 3. Plotting Raw Data (Multiple lines)
    plot(x, y, 'LineWidth', 2)
    hold on
    
    % 4. Plotting the Fits
    % Squeeze and transpose: [N_RI x Window] becomes [Window x N_RI]
    y_fit = squeeze(peak_polyvals(:, ind, :))';
    plot(x, y_fit, '--', 'LineWidth', 1)
    
    % 5. Plotting the detected Maxima
    plot(peak_locs(:, ind), peaks(:, ind), '*', 'MarkerSize', 7)
    
    % Title with sensitivity
    title(sprintf('Peak %i (%.2f dB/RIU)', ind, good_peaks_sens(ii)))
    grid on
end



% --- Plotting Filtered "Good" Valleys ---
figure
for ii = 1:n_good_valleys
    % Get the original index of the 'good' valley
    ind = good_valleys_indices(ii);
    
    % Ensure indices are integers
    val_i = round(pre_valley_locs(1, ind));
    int_val = round(interval);
    
    subplot(5, ceil(n_good_valleys/5), ii)
    
    % 1. X as a column vector
    x = valley_intervals(ind, :);
    x = x(:); 
    
    % 2. Y as a matrix where columns match X length
    % Transpose: [N_RI x Window] becomes [Window x N_RI]
    y = CHF_sens(:, val_i - int_val : val_i + int_val)';
    
    % 3. Plotting Raw Data (Multiple lines for each RI step)
    plot(x, y, 'LineWidth', 2)
    hold on
    
    % 4. Plotting the Fits
    % Squeeze and transpose: [N_RI x Window] becomes [Window x N_RI]
    y_fit = squeeze(valley_polyvals(:, ind, :))';
    plot(x, y_fit, '--', 'LineWidth', 1)
    
    % 5. Plotting the detected Minima
    plot(valley_locs(:, ind), valleys(:, ind), '*', 'MarkerSize', 7)
    
    % Title with sensitivity (rounded to 2 decimal places)
    title(sprintf('Valley %i (%.2f dB/RIU)', ind, good_valleys_sens(ii)))
    grid on
end


%plot sensitivities
figure
plot(peak_locs(1,good_peaks_indices), good_peaks_sens, '.-', 'LineWidth', 2, 'MarkerSize', 15);
hold on
plot(valley_locs(1,good_valleys_indices), good_valleys_sens, '.-', 'LineWidth', 2, 'MarkerSize', 15);
if max(abs(good_peaks_sens)) > max(abs(good_valleys_sens))
    [m,ind] = max(abs(good_peaks_sens));
    plot(peak_locs(1,good_peaks_indices(ind)), good_peaks_sens(ind), 'm*', 'MarkerSize', 10)
else
    [m,ind] = max(abs(good_valleys_sens));
    plot(valley_locs(1,good_valleys_indices(ind)), good_valleys_sens(ind), 'm*', 'MarkerSize', 10)
end

legend('peaks', 'valleys', strcat("Max sens = ", num2str(m), ' dB/RIU'))
ylabel('Sensitivity (dB/RIU)');
xlabel('Wavelength (nm)');
title('Sensitivities')



% ... (previous code ends here)

%%%%%% 
%%%%%% Logging Results to Text File (Updated with Peak Locations)
%%%%%%

% ... (previous code ends here)

%%%%%% 
%%%%%% Logging Results to Text File (Comprehensive Version)
%%%%%%

% ... (previous code ends here)


%%%%%% 
%%%%%% Logging Results to Text File
%%%%%%


% 1. Create the full file path using the existing pathToData
log_name = sprintf('calib_chan_%d_sens_%s_Filter_%s_%s_log.txt', sensor_trace, sensor_name, filter_name, laser_scan_speed);
log_full_path = fullfile(pathToData, log_name);

% 2. Open the file using the path to your data folder
fileID = fopen(log_full_path, 'a');

% 3. Get current date and time
current_time = datetime('now','Format','yyyy-MM-dd HH:mm:ss');

% Determine the number of rows needed
num_peaks = length(good_peaks_indices);
num_valleys = length(good_valleys_indices);
max_rows = max(num_peaks, num_valleys);


% 4. Write Header
fprintf(fileID, '\n%s\n', repmat('=', 1, 125));
fprintf(fileID, 'Run Timestamp:        %s\n', char(current_time));
fprintf(fileID, 'The channel analyzed: %d\n', sensor_trace); 
fprintf(fileID, 'The sensor code name: %s\n', sensor_name);  
fprintf(fileID, 'Data Path:            %s\n', pathToData);
fprintf(fileID, 'Number of RI:         %d\n', N_RI);
fprintf(fileID, 'Number of measurements per RI:            %d\n', N_Val);
fprintf(fileID, 'Filter used:            %s\n', filter_name);
fprintf(fileID, 'Laser scan speed:            %s\n', laser_scan_speed);
fprintf(fileID, '%s\n', repmat('=', 1, 125));

% Header for Peak and Valley columns
fprintf(fileID, '%-8s | %-10s | %-12s | %-8s || %-8s | %-10s | %-12s | %-8s\n', ...
    'Pk Idx', 'Pk Loc', 'Pk Sens', 'Pk R2', 'Vl Idx', 'Vl Loc', 'Vl Sens', 'Vl R2');
fprintf(fileID, '%s\n', repmat('-', 1, 125));

% 5. Write the data columns
for i = 1:max_rows
    % --- Handle Peak data ---
    if i <= num_peaks
        idx_p = good_peaks_indices(i);
        p_idx   = sprintf('%d', idx_p);
        p_loc   = sprintf('%d', pre_peak_locs(1, idx_p)); 
        p_sens  = sprintf('%.4f', good_peaks_sens(i));
        p_r2    = sprintf('%.4f', r2_peaks(idx_p));
    else
        [p_idx, p_loc, p_sens, p_r2] = deal('---');
    end
    
    % --- Handle Valley data ---
    if i <= num_valleys
        idx_v = good_valleys_indices(i);
        v_idx   = sprintf('%d', idx_v);
        v_loc   = sprintf('%d', pre_valley_locs(1, idx_v));
        v_sens  = sprintf('%.4f', good_valleys_sens(i));
        v_r2    = sprintf('%.4f', r2_valleys(idx_v));
    else
        [v_idx, v_loc, v_sens, v_r2] = deal('---');
    end
    
    % Print row to file
    fprintf(fileID, '%-8s | %-10s | %-12s | %-8s || %-8s | %-10s | %-12s | %-8s\n', ...
        p_idx, p_loc, p_sens, p_r2, v_idx, v_loc, v_sens, v_r2);
end

fprintf(fileID, '%s\n\n', repmat('=', 1, 125));

fclose(fileID);

fprintf('Log saved to data folder: %s\n', log_full_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Original script
% Script modified by L. Vassilets (added path to data and log)
% Contact info in case of issues and suggestions:
% lyubov.vassilets@alumni.nu.edu.kz
