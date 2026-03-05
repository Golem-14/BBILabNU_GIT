%%%          Nazarbayev University              %%%
%%% Laboratory of Biosensors and Bioinstruments %%%
%%%        Author: Bissen Aidana                %%%


clear; close all; clc;

% Use the folder currently open in MATLAB's File Browser
img_folder = pwd;
fprintf('Using current folder: %s\n', img_folder);

prefixes = {'RI1', 'RI2', 'RI3', 'RI4', 'RI5', 'RI6', 'RI7'};
channels = {'r', 'g', 'b'};

% Get both .jpg and .jpeg files in this folder
all_files = [dir(fullfile(img_folder, '*.jpg')); dir(fullfile(img_folder, '*.jpeg'))];
all_files = sort({all_files.name});  % alphabetical sorting

for p = 1:length(prefixes)
    prefix = prefixes{p};
    fprintf('\nProcessing %s...\n', prefix);

    % Select matching files
    mask = startsWith(all_files, [prefix '_']);
    files = all_files(mask);

    nPhotos = numel(files);
    time_points = 1:nPhotos;

    for c = 1:length(channels)
        ch = channels{c};
        fprintf('  Channel: %s\n', ch);

        intensity_values = zeros(1, nPhotos);

        for i = 1:nPhotos
            img_path = fullfile(img_folder, files{i});
            frame = imread(img_path);

            switch ch
                case 'r'
                    channel_data = frame(:,:,1);
                case 'g'
                    channel_data = frame(:,:,2);
                case 'b'
                    channel_data = frame(:,:,3);
            end

            outer_integral = sum(channel_data(:) .* uint8(channel_data(:) >= 135));
            inner_integral = sum(channel_data(:) .* uint8(channel_data(:) >= 250));
            intensity_values(i) = abs(outer_integral - inner_integral);

            if mod(i,10) == 0
                fprintf('    %s photo %d/%d\n', prefix, i, nPhotos);
            end
        end

        output_name = sprintf('%s_%s.mat', prefix, ch);
        save(output_name, 'intensity_values', 'time_points');
        fprintf('  Saved %s (%d photos)\n', output_name, nPhotos);
    end
end
