%%%          Nazarbayev University              %%%
%%% Laboratory of Biosensors and Bioinstruments %%%
%%%        Author: Bissen Aidana                %%%


close all; clear;

% ===========================
% Image filenames
% ===========================
image_files = {'RI1_90.jpg', ...
               'RI3_30.jpg', ...
               'RI5_27.jpg'};
concentration = [0 2 4];

% ===========================
% Storage arrays
% ===========================
imgs = cell(1,3);
blue_ch = cell(1,3);
I_mean = zeros(1,3);

% ===========================
% ROI coordinates (modify if needed)
% ===========================
roi_x = 800:1200;
roi_y = 300:700;

% ===========================
% Load and preprocess
% ===========================
for i = 1:3
    img = imread(image_files{i});
    imgs{i} = double(img(:,:,3));   % blue channel
    
    blue_ch{i} = imgs{i};
    roi = imgs{i}(roi_y, roi_x);
    I_mean(i) = mean(roi(:));
end

% ============================================================
%  FIGURE 1-3: 3D SURFACE of raw blue channel
% ============================================================
for i = 1:3
    figure('Color','w');
    [rows, cols] = size(blue_ch{i});
    [x,y] = meshgrid(0:cols-1, 0:rows-1);
    
    surf(x,y,blue_ch{i},'EdgeColor','none');
    view(2);
    axis tight;
    colormap jet;
    colorbar;
    title(sprintf('3D Blue Channel of %s', image_files{i}), 'Interpreter','none');
end

% ============================================================
%  FIGURE 4-5: ABSOLUTE DIFF (0 µM vs 2 µM and 0 µM vs 4 µM)
% ============================================================
diff_02 = abs(blue_ch{2} - blue_ch{1});
diff_04 = abs(blue_ch{3} - blue_ch{1});

figure('Color','w');
imshow(diff_02,[]); colormap jet; colorbar;
title('ABSOLUTE DIFFERENCE: 2 µM  -  0 µM');

figure('Color','w');
imshow(diff_04,[]); colormap jet; colorbar;
title('ABSOLUTE DIFFERENCE: 4 µM  -  0 µM');

% ============================================================
%  FIGURE 6: LINE INTENSITY PROFILE (row cross-section)
% ============================================================
row = 500;

figure('Color','w');
plot(blue_ch{1}(row,:),'b','LineWidth',2); hold on;
plot(blue_ch{2}(row,:),'g','LineWidth',2);
plot(blue_ch{3}(row,:),'r','LineWidth',2);
xlabel('Pixel position');
ylabel('Intensity');
title('Intensity Profile Comparison (Row 500)');
legend('0 µM','2 µM','4 µM');
grid on;

% ============================================================
%  FIGURE 7: HISTOGRAM COMPARISON
% ============================================================
figure('Color','w');
histogram(blue_ch{1}(:),50,'FaceAlpha',0.4,'FaceColor','b'); hold on;
histogram(blue_ch{2}(:),50,'FaceAlpha',0.4,'FaceColor','g');
histogram(blue_ch{3}(:),50,'FaceAlpha',0.4,'FaceColor','r');
legend('0 µM','2 µM','4 µM');
title('Histogram Comparison of Intensities');
xlabel('Intensity');
ylabel('Count');

% ============================================================
%  FIGURE 8: MEAN INTENSITY vs CONCENTRATION
% ============================================================
figure('Color','w');
plot(concentration,I_mean,'o-','LineWidth',2,'MarkerSize',8);
xlabel('Concentration (µM)');
ylabel('Mean Intensity (ROI)');
title('Calibration Curve: Mean ROI Intensity vs Concentration');
grid on;

% ============================================================
%  FIGURE 9-10: HEATMAP OF DIFFERENCE (ROI ONLY)
% ============================================================
roi_diff02 = diff_02(roi_y, roi_x);
roi_diff04 = diff_04(roi_y, roi_x);

figure('Color','w');
imagesc(roi_diff02); axis equal tight; colormap jet; colorbar;
title('Difference Heatmap ROI: 2 µM - 0 µM');

figure('Color','w');
imagesc(roi_diff04); axis equal tight; colormap jet; colorbar;
title('Difference Heatmap ROI: 4 µM - 0 µM');
