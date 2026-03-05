%%%          Nazarbayev University              %%%
%%% Laboratory of Biosensors and Bioinstruments %%%
%%%        Author: Bissen Aidana                %%%


clear; close all; clc;

% Use the folder currently opened in MATLAB's File Browser
img_folder = pwd;
fprintf('Using current folder: %s\n', img_folder);

prefixes = {'concentration0', 'concentration1', 'concentration2', 'concentration3', 'concentration4'};
channels = {'r', 'g', 'b'};

% Get both .jpg and .jpeg files in the current folder
all_files = [dir(fullfile(img_folder, '*.jpg')); dir(fullfile(img_folder, '*.jpeg'))];
all_files = sort({all_files.name});  % alphabetical sort

for p = 1:length(prefixes)
    prefix = prefixes{p};
    fprintf('\nProcessing %s...\n', prefix);

    % Select files starting with prefix_
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

            % Extract channel data
            switch ch
                case 'r'
                    channel_data = frame(:,:,1);
                case 'g'
                    channel_data = frame(:,:,2);
                case 'b'
                    channel_data = frame(:,:,3);
            end

            % Integrals
            outer_integral = sum(channel_data(:) .* uint8(channel_data(:) >= 135));
            inner_integral = sum(channel_data(:) .* uint8(channel_data(:) >= 250));
            intensity_values(i) = abs(outer_integral - inner_integral);

            if mod(i,10) == 0
                fprintf('    %s photo %d/%d\n', prefix, i, nPhotos);
            end
        end

        % Save output
        output_name = sprintf('%s_%s.mat', prefix, ch);
        save(output_name, 'intensity_values', 'time_points');
        fprintf('  Saved %s (%d photos)\n', output_name, nPhotos);
    end
end
