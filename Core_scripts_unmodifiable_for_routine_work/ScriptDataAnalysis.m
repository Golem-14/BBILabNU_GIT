%%clear all
close all
clc

%%load Experiments3

%%%%% Data analysis: apply this code to the channel that you consider

ChannelData = CHF2; %%% Replace here the channel you want to analyze

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




