%%%          Nazarbayev University              %%%
%%% Laboratory of Biosensors and Bioinstruments %%%
%%%        Author: Bissen Aidana                %%%

clear; close all; clc;

%% === Choose which color channel to analyze ===
channel_set = 'b';   % example: analyze blue channel

%% === EXPERIMENT TIMING (NEW) ===
photos_per_min = 18;          % 3 photos every 10 s
dt_min = 1 / photos_per_min; % minutes per photo

%% === Define .mat file names and concentration labels ===
concentrations = {'Artificial Saliva', '100 aM', '100 fM', '100 pM', '100 nM'};
concentration_levels = [0, 1, 2, 3, 4];
RI_prefixes = {'concentration0', 'concentration1', 'concentration2', 'concentration3', 'concentration4'};

mat_files = cell(1, numel(RI_prefixes));
for i = 1:numel(RI_prefixes)
    mat_files{i} = sprintf('%s_%s.mat', RI_prefixes{i}, channel_set);
end

colors = {[0, 0, 0], [0 0.4 1], [1 0.2 0.2], [0.2 0.8 0.2], [0.7 0.3 1]};

%% === Storage variables ===
segment_times = cell(1, numel(mat_files));
segment_intensities = cell(1, numel(mat_files));
avg_intensities = zeros(1, numel(mat_files));
time_offset = 0;        % minutes
all_time = [];
all_intensity = [];

%% ========================================================================
%% === PROCESS EACH CONCENTRATION SEGMENT ===
%% ========================================================================
for i = 1:numel(mat_files)

    data = load(mat_files{i});  % requires time_points, intensity_values

    % === Convert photo index → time in MINUTES (CHANGED) ===
    time_points = (data.time_points - 1) * dt_min + time_offset;

    y = double(data.intensity_values(:));

    %% === Remove first 100 points BEFORE resampling ===
    removeN = 100;
    if length(y) > removeN
        y = y(removeN+1:end);
        time_points = time_points(removeN+1:end);
    end

    %% ============================================================
    %% === ZERO-RIPPLE RESAMPLING PIPELINE
    %% ============================================================
    y = medfilt1(y, 5);              % remove camera spikes
    y_smooth = sgolayfilt(y, 3, 11); % smooth (no ripples)

    % Pad to avoid boundary artifacts
    padN = 50;
    y_pad = [repmat(y_smooth(1), padN, 1); ...
             y_smooth; ...
             repmat(y_smooth(end), padN, 1)];

    % Downsample
    y_down = y_pad(1:3:end);

    % PCHIP interpolation (monotonic)
    x_down = linspace(1, length(y_pad), length(y_down));
    x_full = 1:length(y_pad);
    y_resampled = interp1(x_down, y_down, x_full, 'pchip')';

    % Remove padding
    y_resampled = y_resampled(padN+1:end-padN);

    % Final mild smoothing
    y_resampled = sgolayfilt(y_resampled, 3, 9);

    %% === TRIM FIRST & LAST 6 POINTS ===
    trimN = 6;
    if length(y_resampled) > 2*trimN
        y_resampled = y_resampled(trimN+1:end-trimN);
        time_points = time_points(trimN+1:end-trimN);
    end

    %% === SAVE CLEANED SIGNAL ===
    intensity_values = y_resampled(:);

    segment_times{i} = time_points;
    segment_intensities{i} = intensity_values;

    all_time = [all_time, time_points];
    all_intensity = [all_intensity; intensity_values];

    avg_intensities(i) = mean(intensity_values);

    % === Update time offset in MINUTES (CHANGED) ===
    time_offset = time_points(end);
end

%% ========================================================================
%% === NORMALIZATION ===
%% ========================================================================
norm_all_intensity = 100 * ...
    (all_intensity - min(all_intensity)) / ...
    (max(all_intensity) - min(all_intensity));

segment_norm_intensities = cell(1, numel(mat_files));
start_idx = 1;
for i = 1:numel(mat_files)
    len_i = length(segment_intensities{i});
    end_idx = min(start_idx + len_i - 1, length(norm_all_intensity));
    segment_norm_intensities{i} = norm_all_intensity(start_idx:end_idx);
    start_idx = end_idx + 1;
end

norm_avg_intensities = 100 * ...
    (avg_intensities - min(avg_intensities)) / ...
    (max(avg_intensities) - min(avg_intensities));

max_avg = max(avg_intensities);
min_avg = min(avg_intensities);

%% ========================================================================
%% === PLOT 1: RESAMPLED SIGNAL (TIME IN MINUTES) ===
%% ========================================================================
figure('Color','w'); hold on;
for i = 1:numel(mat_files)
    plot(segment_times{i}, segment_intensities{i}, ...
         'Color', colors{i}, 'LineWidth', 1.5);
end
xlabel('Time (min)');
ylabel('Intensity (pixels)');
title('Resampled Intensity vs Time');
legend(concentrations, 'Location','best');
grid on; hold off;

%% ========================================================================
%% === PLOT 2: NORMALIZED SIGNAL ===
%% ========================================================================
figure('Color','w'); hold on;
for i = 1:numel(mat_files)
    plot(segment_times{i}, segment_norm_intensities{i}, ...
         'Color', colors{i}, 'LineWidth', 1.5);
end
xlabel('Time (min)');
ylabel('Normalized Intensity (%)');
title('Normalized Intensity vs Time');
legend(concentrations, 'Location','best');
grid on; hold off;

%% ========================================================================
%% === PLOT 3: AVERAGE INTENSITY ===
%% ========================================================================
figure('Color','w');
plot(0:length(avg_intensities)-1, avg_intensities, '-o', ...
     'MarkerSize', 8, 'LineWidth', 2);
xlabel('Concentration');
ylabel('Average Intensity (pixels)');
title('Average Intensity vs Concentration');
grid on;
xticks(0:length(concentrations)-1);
xticklabels(concentrations);

%% ========================================================================
%% === PLOT 4: NORMALIZED AVERAGE INTENSITY ===
%% ========================================================================
figure('Color','w');
plot(0:length(norm_avg_intensities)-1, norm_avg_intensities, '-o', ...
     'MarkerSize', 8, 'LineWidth', 2);
xlabel('Concentration');
ylabel('Normalized Average Intensity (%)');
title('Normalized Average Intensity vs Concentration');
grid on;
xticks(0:length(concentrations)-1);
xticklabels(concentrations);

%% ========================================================================
%% === REGRESSION ===
%% ========================================================================
p_time = polyfit(all_time, norm_all_intensity, 1);
time_slope = p_time(1);

p_conc = polyfit(concentration_levels, norm_avg_intensities, 1);
p_conc_avg = polyfit(concentration_levels, avg_intensities, 1);

conc_slope = p_conc(1);
conc_slope_avg = p_conc_avg(1);

%% ========================================================================
%% === SUMMARY ===
%% ========================================================================
fprintf('\n=== SUMMARY (%s channel) ===\n', upper(channel_set));
for i = 1:numel(concentrations)
    fprintf('%-15s → Avg Intensity = %.2f | Norm = %.2f%%\n', ...
        concentrations{i}, avg_intensities(i), norm_avg_intensities(i));
end
fprintf('----------------------------------------------\n');
fprintf('Time slope sensitivity     : %.3f %%/min\n', time_slope);
fprintf('Conc slope (normalized)    : %.3f %%/a.u.\n', conc_slope);
fprintf('Conc slope (raw intensity) : %.3f pixels/a.u.\n', conc_slope_avg);
fprintf('Difference sensitivity     : %.3f pixels\n', max_avg - min_avg);
