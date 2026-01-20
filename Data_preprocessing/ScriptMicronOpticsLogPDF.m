clear all
close all
clc

%%%%%% Path to data

pathToData = "C:\Users\User\Documents\Lyubov\Readings\Calib 23.1 Set 28 LV 100625 NEW"; %the path to you folder (copy from the address line)
% You do NOT need to move the script or the data files

%%%%%% Parameters

N_RI = 6; % Number of RI values
N_Val = 10; % Number of times each RI was saved
RI = [1.34761 1.34974 1.35216 1.35457 1.35696 1.35845]; % RI values
sensor_trace = 2;
FBG_trace = sensor_trace;
sensor_name = "LV3";
%%%%%% Load data

kk = 1;
for ii = 1:N_RI
    for jj = 1:N_Val
        
        Fname = strcat(pathToData, '\', 'RI', num2str(ii), '_', num2str(jj), '.txt');
        Data = importdata(Fname);
        Mat = Data.data;
        
        if (kk==1)
            Wavelength = Mat(:,1);
        end
        
        CH1(kk,:) = Mat(:,2);
        try
            CH2(kk,:) = Mat(:,3);
        catch
        end
        try
            CH3(kk,:) = Mat(:,4);
        catch
        end
        try
            CH4(kk,:) = Mat(:,5);
        catch
        end
        try
            CH5(kk,:) = Mat(:,6);
        catch
        end
        try
            CH6(kk,:) = Mat(:,7);
        catch
        end
        try
            CH7(kk,:) = Mat(:,8);
        catch
        end
        try
            CH8(kk,:) = Mat(:,9);
        catch
        end
        
        kk = kk+1;
        
    end
end

kk = kk-1;

%%%%%%
%%%%%% Processing
%%%%%%

% Filtering

[b,a] = butter(5,0.01);

for ii = 1:kk
    CHF1(ii,:) = filter(b,a,CH1(ii,:));
    if exist('CH2')
        CHF2(ii,:) = filter(b,a,CH2(ii,:));
    end
    if exist('CH3')
        CHF3(ii,:) = filter(b,a,CH3(ii,:));
    end
    if exist('CH4')
        CHF4(ii,:) = filter(b,a,CH4(ii,:));
    end
    if exist('CH5')
        CHF5(ii,:) = filter(b,a,CH5(ii,:));
    end
    if exist('CH6')
        CHF6(ii,:) = filter(b,a,CH6(ii,:));
    end
    if exist('CH7')
        CHF7(ii,:) = filter(b,a,CH7(ii,:));
    end
    if exist('CH8')
        CHF8(ii,:) = filter(b,a,CH8(ii,:));
    end
end

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
    CHF1_temp(jj,:) = mean(CHF1(dd:dd+2, :));
    if exist('CH2')
        CHF2_temp(jj,:) = mean(CHF2(dd:dd+2, :));
    end
    if exist('CH3')
        CHF3_temp(jj,:) = mean(CHF3(dd:dd+2, :));
    end
    if exist('CH4')
        CHF4_temp(jj,:) = mean(CHF4(dd:dd+2, :));
    end
    if exist('CH5')
        CHF5_temp(jj,:) = mean(CHF5(dd:dd+2, :));
    end
    if exist('CH6')
        CHF6_temp(jj,:) = mean(CHF6(dd:dd+2, :));
    end
    if exist('CH7')
        CHF7_temp(jj,:) = mean(CHF7(dd:dd+2, :));
    end
    if exist('CH8')
        CHF8_temp(jj,:) = mean(CHF7(dd:dd+2, :));
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
%find peaks with a very clean filter for accurace
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

%peaks
for ii=1:n_peaks
    
    peak_i = pre_peak_locs(1,ii);
    
    if peak_i > interval  && peak_i+interval < length(Wavelength) %skip first few peaks and valleys
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

%plotting peaks
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

%valleys
for ii=1:n_valleys
    
    valley_i = pre_valley_locs(1,ii);
    
    if valley_i > interval && valley_i+interval < length(Wavelength) %skip first few peaks and valleys
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

%plotting valleys
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

% find sensitivities
x = RI(:);
for kk=1:n_peaks
    y = peaks(:,kk);
    p = polyfit(x,y,1);
    pp = polyval(p,x);
    sens_peaks(kk) = p(1);
    r2_peaks(kk) = rsquare(y,pp);
end

for kk=1:n_valleys
    y = valleys(:,kk);
    p = polyfit(x,y,1);
    pp = polyval(p,x);
    sens_valleys(kk) = p(1);
    r2_valleys(kk) = rsquare(y,pp);
end

%filtering r2 > 0.9 
good_peaks_sens = sens_peaks(r2_peaks>0.9);
good_peaks_indices = find(r2_peaks>0.9);
n_good_peaks = length(good_peaks_indices);

good_valleys_sens = sens_valleys(r2_valleys>0.9);
good_valleys_indices = find(r2_valleys>0.9);
n_good_valleys = length(good_valleys_indices);

%plot sensitive peaks and valleys
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



% 1. Import the necessary report libraries
import mlreportgen.dom.*
import mlreportgen.report.*

% 2. Initialize the PDF Report
report_name = fullfile(pathToData, sprintf('Report_%s.pdf', sensor_name));
rpt = Report(report_name, 'pdf');

% 3. Add a Title Page
add(rpt, TitlePage('Title', ['Analysis for Sensor: ' sensor_name], ...
                   'Subtitle', ['Channel: ' num2str(sensor_trace)], ...
                   'Author', 'BBI Lab'));

% 4. Add the Table of Contents
add(rpt, TableOfContents());

% 5. Add a Section for the Results
section = Section('Sensitivity Analysis Results');

% 6. Add the Current Plot (the Sensitivities figure)
% Make sure the figure you want is the active one
fig = gcf; 
frame = getframe(fig);
imwrite(frame.cdata, 'tempFigure.png'); % Captures the current figure
img.Width = '6in';
add(section, img);

% 7. Add your Data Table
% Convert your results into a simple MATLAB table first
T = table(good_peaks_indices', good_peaks_sens', ...
    'VariableNames', {'Index', 'Sensitivity_dB_RIU'});
add(section, T);

% 8. Close and Generate
add(rpt, section);
close(rpt);
rptview(rpt); % This opens the PDF automatically