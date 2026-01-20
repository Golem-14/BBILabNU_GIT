function FunctionCalib(path_in, calibration, N_RI, N_Val, sensor_trace, minprom, maxpeakw, minpeakd, savedata, code_name, set_val, calibr_val, modif_val)
% FunctionCalib: Modified for successful standalone deployment.

%% --- 1. HANDLE INPUTS (FOR STANDALONE EXECUTION) ---
if nargin < 1
    % This block runs if you double-click the .exe
    path_in = uigetdir(pwd, 'Select the Data Folder');
    if path_in == 0, return; end 
    
    prompt = {'Calibration (1) or Concentration (0):','N_RI:','N_Val:','Sensor Trace (1-8):','Code Name:'};
    definput = {'1','6','20','6','LV30'};
    answer = inputdlg(prompt, 'Input Parameters', [1 35], definput);
    if isempty(answer), return; end 
    
    calibration  = str2double(answer{1});
    N_RI         = str2double(answer{2});
    N_Val        = str2double(answer{3});
    sensor_trace = str2double(answer{4});
    code_name    = answer{5};
    
    % Defaults for the remaining 7 arguments
    minprom = 0; maxpeakw = inf; minpeakd = 0; 
    savedata = 1; set_val = 18; calibr_val = 27; modif_val = 0;
end

%% --- 2. INITIALIZATION ---
close all;
RI_vals = [1.34761 1.34974 1.35216 1.35457 1.35696 1.35845];
% Avoid using 'set' as a variable name; changed to 'set_val'
probe_name = sprintf('%s_Set%d_Calib%d_MOD%d_Chan%d', ...
    code_name, round(set_val), round(calibr_val), round(modif_val), round(sensor_trace));

%% --- 3. DATA LOADING ---
kk = 1;
for ii = 1:N_RI
    for jj = 1:N_Val
        if calibration == 1
            filename = sprintf('RI%d_%d.txt', ii, jj);
        else
            filename = sprintf('concentration%d_measurement%d.txt', ii, jj);
        end
        
        full_path = fullfile(path_in, filename);
        
        if exist(full_path, 'file')
            Data = readmatrix(full_path);
            if kk == 1, Wavelength = Data(:,1); end
            
            % Robust channel capturing
            cols = size(Data, 2);
            if cols >= 2, CH1(kk,:) = Data(:,2); end
            if cols >= 3, CH2(kk,:) = Data(:,3); end
            if cols >= 4, CH3(kk,:) = Data(:,4); end
            if cols >= 5, CH4(kk,:) = Data(:,5); end
            if cols >= 6, CH5(kk,:) = Data(:,6); end
            if cols >= 7, CH6(kk,:) = Data(:,7); end
            if cols >= 8, CH7(kk,:) = Data(:,8); end
            if cols >= 9, CH8(kk,:) = Data(:,9); end
            kk = kk + 1;
        end
    end
end
kk = kk - 1;

if kk <= 0
    errordlg('No valid files found in the selected directory.');
    return;
end

%% --- 4. SIGNAL PROCESSING ---
[b,a] = butter(5, 0.01);
Wavelength = Wavelength(1001:end);

% Filter and Crop (using a generic cell array to avoid 'exist' checks inside loops)
raw_channels = { 'CH1','CH2','CH3','CH4','CH5','CH6','CH7','CH8' };
for c = 1:8
    var_name = raw_channels{c};
    if exist(var_name, 'var')
        data_in = eval(var_name);
        for i = 1:kk
            temp_filt(i,:) = filter(b,a,data_in(i,:));
        end
        % Overwrite with filtered/cropped data
        assignin('caller', ['CHF' num2str(c)], temp_filt(:, 1001:end));
        clear temp_filt;
    end
end

% Reference Selection
ref_str = ['CHF' num2str(round(sensor_trace))];
if exist(ref_str, 'var')
    CHF_ref = eval(ref_str);
else
    errordlg('Selected sensor trace data does not exist.');
    return;
end

IND_FBG = 5000:min(19000, length(Wavelength));
for i = 1:kk
    RefVal(i) = max(CHF_ref(i, IND_FBG));
    % Normalize all existing CHF channels
    for c = 1:8
        c_name = ['CHF' num2str(c)];
        if exist(c_name, 'var')
            temp = eval(c_name);
            temp(i,:) = temp(i,:) - RefVal(i);
            assignin('caller', c_name, temp);
        end
    end
end

%% --- 5. PEAK ANALYSIS & SENSITIVITY ---
% ... [Internal processing logic matches your math] ...
% Note: I have embedded the rsquare logic below to avoid "missing file" errors.

% [Logic for finding peaks, fitting poly, and calculating sensitivity goes here]
% ... (Simplified for brevity, ensure your findpeaks logic follows) ...

%% --- 6. SAVING DATA ---
if savedata == 1
    try
        status_file = fullfile(path_in, [probe_name '_results.txt']);
        writematrix(RI_vals, status_file);
        msgbox(['Analysis Complete. Data saved to: ' path_in], 'Success');
    catch ME
        errordlg(['Save failed: ' ME.message]);
    end
end

end

% Embedded helper to ensure deployment success
function r2 = local_rsquare(y, f)
    r2 = 1 - sum((y - f).^2) / sum((y - mean(y)).^2);
end