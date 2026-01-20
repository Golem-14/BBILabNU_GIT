%%clear all
close all
clc

%%load Experiments3

%%%%% Data analysis: apply this code to the channel that you consider

ChannelData = CHF3; %%% Replace here the channel you want to analyze
channelNumber = 3; % input here the number of channel which will be saved in the log
ProbeName = "J3"; % input the code name of your probe here

% Select spectral portions

TRANSIENT = 1000; % Length of filter transient
FBG_LEFT = 11000; % Leftmost part of the FBG spectrum
FBG_RIGHT = 12000; % Rightmost part of the FBG spectrum
SpectrumLeft = ChannelData(:,TRANSIENT:FBG_LEFT); % Left spectrum: cut out the transient, for SDI analysis
SpectrumFBG = ChannelData(:,FBG_LEFT:FBG_RIGHT); % Spectral portion containing the FBG
SpectrumRight = ChannelData(:,FBG_RIGHT:end); % Right part of the spectrum for SDI analysis
WavelengthLeft = Wavelength(TRANSIENT:FBG_LEFT);
WavelengthFBG = Wavelength(FBG_LEFT:FBG_RIGHT);
WavelengthRight = Wavelength(FBG_RIGHT:end);


% Identify peaks and valleys

N_Index = 1; % Index of the spectral measurement for peak search
MPP = 1.5; % Min. peak prominence

SpectrumLeft_P = SpectrumLeft(N_Index,:);
SpectrumFBG_P = SpectrumFBG(N_Index,:);
SpectrumRight_P = SpectrumRight(N_Index,:);

% Peaks
[P, LocPeakLeft] = findpeaks(SpectrumLeft_P, 'MinPeakProminence',MPP);
[P, LocPeakRight] = findpeaks(SpectrumRight_P, 'MinPeakProminence',MPP);

% Valleys
[P, LocValleyLeft] = findpeaks(-SpectrumLeft_P, 'MinPeakProminence',MPP);
[P, LocValleyRight] = findpeaks(-SpectrumRight_P, 'MinPeakProminence',MPP);


% Extract timeline

time = 0 : (kk-1);

% Peaks
figure
subplot(1,2,1)
for ii = 1:length(LocPeakLeft)
    
    hold on
    plot(time, SpectrumLeft(:,LocPeakLeft(ii)), '-o');

end
title('Left peaks');
xlabel('Time (min)');
ylabel('Spectral intensity (dB)');
axis([0 140 -55 -40])


subplot(1,2,2)
for ii = 1:length(LocPeakRight)
    
    hold on
    plot(time, SpectrumLeft(:,LocPeakRight(ii)), '-o');

end
title('Right peaks');
xlabel('Time (min)');
ylabel('Spectral intensity (dB)');
axis([0 140 -55 -40])



% Valleys
figure
subplot(1,2,1)
for ii = 1:length(LocValleyLeft)
    
    hold on
    plot(time, SpectrumLeft(:,LocValleyLeft(ii)), '-o');

end
title('Left valleys');
xlabel('Time (min)');
ylabel('Spectral intensity (dB)');
axis([0 140 -60 -45])


subplot(1,2,2)
for ii = 1:length(LocValleyRight)
    
    hold on
    plot(time, SpectrumLeft(:,LocValleyRight(ii)), '-o');

end
title('Right valleys');
xlabel('Time (min)');
ylabel('Spectral intensity (dB)');
axis([0 140 -60 -45])

% 3D plots

figure
for ii = 1:length(LocPeakLeft)
    
    hold on
    plot3(WavelengthLeft(LocPeakLeft(ii)) * ones(1,length(time)), time, SpectrumLeft(:,LocPeakLeft(ii)), '-o');

end
for ii = 1:length(LocPeakRight)
    
    hold on
    plot3(WavelengthRight(LocPeakRight(ii)) * ones(1,length(time)), time, SpectrumRight(:,LocPeakRight(ii)), '-o');

end
xlabel('Wavelength (nm)');
ylabel('Time (min)');
zlabel('Spectral intensity (dB)');
title ('Peaks');

figure
for ii = 1:length(LocValleyLeft)
    
    hold on
    plot3(WavelengthLeft(LocValleyLeft(ii)) * ones(1,length(time)), time, SpectrumLeft(:,LocValleyLeft(ii)), '-o');

end
for ii = 1:length(LocValleyRight)
    
    hold on
    plot3(WavelengthRight(LocValleyRight(ii)) * ones(1,length(time)), time, SpectrumRight(:,LocValleyRight(ii)), '-o');

end
xlabel('Wavelength (nm)');
ylabel('Time (min)');
zlabel('Spectral intensity (dB)');
title ('Valleys');


% Extract levels for each concentration

ConcentrationIndex = 1:N_Conc;

figure
subplot(1,2,1)
for ii = 1:length(LocPeakLeft)
    
    zz=1;
    for jj = 1:N_Val:(kk-1)
        
        
        sequence = SpectrumLeft(jj:jj+N_Val-1,LocPeakLeft(ii));
        
        ResponsePeakLeft(ii,zz) = mean(sequence);
        StDevPeakLeft(ii,zz) = std(sequence);
        zz = zz+1;
    end
    
    hold on
    errorbar(ConcentrationIndex, ResponsePeakLeft(ii,:),StDevPeakLeft(ii,:),'-o');
    
end

subplot(1,2,2)
for ii = 1:length(LocPeakRight)
    
    zz=1;
    for jj = 1:N_Val:(kk-1)
        
        
        sequence = SpectrumRight(jj:jj+N_Val-1,LocPeakRight(ii));
        
        ResponsePeakRight(ii,zz) = mean(sequence);
        StDevPeakRight(ii,zz) = std(sequence);
        zz = zz+1;
    end
    
    hold on
    errorbar(ConcentrationIndex, ResponsePeakRight(ii,:),StDevPeakRight(ii,:),'-o');
    
end



figure
subplot(1,2,1)
for ii = 1:length(LocValleyLeft)
    
    zz=1;
    for jj = 1:N_Val:(kk-1)
        
        
        sequence = SpectrumLeft(jj:jj+N_Val-1,LocValleyLeft(ii));
        
        ResponseValleyLeft(ii,zz) = mean(sequence);
        StDevValleyLeft(ii,zz) = std(sequence);
        zz = zz+1;
    end
    
    hold on
    errorbar(ConcentrationIndex, ResponseValleyLeft(ii,:),StDevValleyLeft(ii,:),'-o');
    
end

subplot(1,2,2)
for ii = 1:length(LocValleyRight)
    
    zz=1;
    for jj = 1:N_Val:(kk-1)
        
        
        sequence = SpectrumRight(jj:jj+N_Val-1,LocValleyRight(ii));
        
        ResponseValleyRight(ii,zz) = mean(sequence);
        StDevValleyRight(ii,zz) = std(sequence);
        zz = zz+1;
    end
    
    hold on
    errorbar(ConcentrationIndex, ResponseValleyRight(ii,:),StDevValleyRight(ii,:),'-o');
    
end




%%%%%% 
%%%%%% Logging Results to Text File (with Absolute Indices)
%%%%%%


% 1. Setup File and Header info 
log_name = sprintf('Experiment_Log_Probe_%s_channel_%d.txt', ProbeName, channelNumber); 
if exist('pathToData', 'var')
    log_full_path = fullfile(pathToData, log_name);
else
    log_full_path = log_name;
end

fileID = fopen(log_full_path, 'a');
current_time = datetime('now','Format','yyyy-MM-dd HH:mm:ss');

% --- Header ---
fprintf(fileID, '\n%s\n', repmat('=', 1, 100));
fprintf(fileID, 'Experiment Report: Probe - %s, Channel - %d\n', ProbeName, channelNumber);
fprintf(fileID, 'Timestamp:         %s\n', char(current_time));
fprintf(fileID, 'Path to data: %s\n', pathToData);
fprintf(fileID, 'Note: Right-side indices adjusted by +%d for absolute spectrum position.\n', FBG_RIGHT);
fprintf(fileID, '%s\n', repmat('=', 1, 100));

% Define table helper: {Label, Relative Indices, Response Matrix, IsRightSide}
% We add a flag (true/false) to know when to add the offset
tables_to_write = {
    'LEFT PEAKS',   LocPeakLeft,   ResponsePeakLeft,   false;
    'RIGHT PEAKS',  LocPeakRight,  ResponsePeakRight,  true;
    'LEFT VALLEYS', LocValleyLeft, ResponseValleyLeft,  false;
    'RIGHT VALLEYS',LocValleyRight,ResponseValleyRight, true
};

% Loop through each of the 4 categories
for t = 1:size(tables_to_write, 1)
    label    = tables_to_write{t, 1};
    locs     = tables_to_write{t, 2};
    resp     = tables_to_write{t, 3};
    isRight  = tables_to_write{t, 4};
    
    fprintf(fileID, '\n--- %s ---\n', label);
    
    % Header
    header_str = sprintf('%-12s | ', 'Abs Index');
    for c = 1:size(resp, 2)
        header_str = [header_str, sprintf('Conc_%-7d ', c)];
    end
    fprintf(fileID, '%s\n', header_str);
    fprintf(fileID, '%s\n', repmat('-', 1, length(header_str)));

    % Write each row
    for r = 1:length(locs)
        % APPLY OFFSET: If it is a Right-side table, add FBG_RIGHT (12000)
        if isRight
            abs_index = locs(r) + FBG_RIGHT;
        else
            abs_index = locs(r); % No change for left side
        end
        
        row_data = resp(r, :);
        
        % Print Absolute Index and the 6 Concentration values
        fprintf(fileID, '%-12d | ', abs_index);
        fprintf(fileID, '%-12.4f ', row_data); 
        fprintf(fileID, '\n');
    end
    fprintf(fileID, '%s\n', repmat('-', 1, length(header_str)));
end

fprintf(fileID, '\n%s\n\n', repmat('=', 1, 100));
fclose(fileID);

fprintf('Log with absolute indices saved to: %s\n', log_full_path);