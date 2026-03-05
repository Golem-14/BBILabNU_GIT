%%%          Nazarbayev University              %%%
%%% Laboratory of Biosensors and Bioinstruments %%%
%%%        Author: Bissen Aidana                %%%


clear; close all; clc;

%% === Choose which color channel to analyze ===
channel_set = 'b';   % r, g, or b
% photos_per_min = 18;          % 3 photos every 10 s
% dt_min = 1 / photos_per_min; % minutes per photo


%% === Define .mat file names and RI values ===
RI_prefixes = {'RI1', 'RI2', 'RI3', 'RI4', 'RI5', 'RI6'};
RI_values   = [1.3478, 1.3509, 1.3541, 1.3573, 1.3606, 1.3648];

mat_files = cell(1, numel(RI_prefixes));
for i = 1:numel(RI_prefixes)
    mat_files{i} = sprintf('%s_%s.mat', RI_prefixes{i}, channel_set);
    
end

colors = {[0 0 0], [0 0.4 1], [1 0.2 0.2], [0.2 0.8 0.2], ...
          [0.7 0.3 1], [0.9 0.7 0], [0.5, 0.5, 0.6]};

%% === Storage variables ===
segment_times = cell(1, numel(mat_files));
segment_intensities = cell(1, numel(mat_files));
avg_intensities = zeros(1, numel(mat_files));
avg_intensities_airnorm = zeros(1, numel(mat_files));

time_offset = 0;
all_time = [];
all_intensity = [];

%% === Load and process each RI ===
for i = 1:numel(mat_files)
    data = load(mat_files{i});  % loads intensity_values, time_points

    % === Convert photo index → time in MINUTES (CHANGED) ===
    %time_points = (data.time_points - 1) * dt_min + time_offset;
    time_points = data.time_points + time_offset;
    intensity_values = data.intensity_values;

    % === LOW-PASS FILTER ===
    fs = 1;
    cutoff = 0.05;
    [b, a] = butter(4, cutoff/(fs/2), 'low');
    intensity_values = filtfilt(b, a, double(intensity_values));

    segment_times{i} = time_points;
    segment_intensities{i} = intensity_values;

    avg_intensities(i) = mean(intensity_values);

    all_time = [all_time, time_points];
    all_intensity = [all_intensity, intensity_values];

    time_offset = time_points(end);
end

%% === AIR NORMALIZATION (SEPARATE FILE) ===
% Load RI1 for air normalization
data_air = load(sprintf('%s_%s.mat', 'RI1', channel_set));
air_intensity = data_air.intensity_values;
air_mean = mean(air_intensity);

segment_airnorm = cell(1, numel(mat_files));

% Normalize each RI (RI2 to RI7) by RI1
for i = 1:numel(mat_files)
    segment_airnorm{i} = segment_intensities{i} ./ air_mean;
    avg_intensities_airnorm(i) = mean(segment_airnorm{i});
end

%% === Plot 1: Filtered Intensity vs Time (RAW) (Continuous) ===
figure('Color','w'); hold on;
for i = 1:numel(mat_files)
    plot(segment_times{i}, segment_intensities{i}, ...
         'Color', colors{i}, 'LineWidth', 1.5);
end
xlabel('Time (minutes)');
ylabel('Filtered Intensity (pixel value)');
title(sprintf('Filtered Intensity vs Time — %s channel', upper(channel_set)));
legend(arrayfun(@(x) sprintf('RI = %.4f', x), RI_values, 'UniformOutput', false), ...
       'Location','best');
grid on; hold off;

%% === Plot 2: Filtered Intensity vs Time (AIR-NORMALIZED) (Continuous) ===
figure('Color','w'); hold on;
for i = 1:numel(mat_files)
    plot(segment_times{i}, segment_airnorm{i}, ...
         'Color', colors{i}, 'LineWidth', 1.5);
end
xlabel('Time (minutes)');
ylabel('Normalized Intensity (I / I_{air})');
title(sprintf('Air-Normalized Intensity vs Time — %s channel', upper(channel_set)));
legend(arrayfun(@(x) sprintf('RI = %.4f', x), RI_values, 'UniformOutput', false), ...
       'Location','best');
grid on; hold off;

%% === Plot 3: Average Intensity vs RI (RAW) ===
figure('Color','w');
plot(RI_values, avg_intensities, '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Refractive Index (RIU)');
ylabel('Average Intensity (pixel value)');
title(sprintf('Average Intensity vs RI — %s channel', upper(channel_set)));
grid on;

%% === Plot 4: Average Intensity vs RI (AIR-NORMALIZED) ===
figure('Color','w');
plot(RI_values, avg_intensities_airnorm, '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Refractive Index (RIU)');
ylabel('Normalized Average Intensity (I / I_{air})');
title(sprintf('Air-Normalized Average Intensity vs RI — %s channel', upper(channel_set)));
grid on;

%% === Linear Fit (AIR-NORMALIZED) ===
p = polyfit(RI_values, avg_intensities_airnorm, 1);
sensitivity_air = p(1);
fit_vals = polyval(p, RI_values);

fprintf('Air-normalized sensitivity (%s channel): %.4f (1/RIU)\n', ...
        channel_set, sensitivity_air);

%% === Plot 5: Linear Fit (AIR-NORMALIZED) ===
figure('Color','w');
plot(RI_values, avg_intensities_airnorm, 'o', 'MarkerSize', 8); hold on;
plot(RI_values, fit_vals, '-r', 'LineWidth', 2);
xlabel('Refractive Index (RIU)');
ylabel('Normalized Average Intensity');
title(sprintf('Air-Normalized Linear Fit — %s Channel (Slope: %.4f /RIU)', ...
      upper(channel_set), sensitivity_air));
legend('Data', 'Linear Fit', 'Location', 'best');
grid on; hold off;

%% === Display Summary ===
fprintf('\nAir-normalized average intensities (%s channel):\n', upper(channel_set));
for i = 1:numel(RI_values)
    fprintf('RI %.4f → %.4f\n', RI_values(i), avg_intensities_airnorm(i));
end
