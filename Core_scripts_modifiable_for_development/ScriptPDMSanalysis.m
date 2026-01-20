clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Parameters initialization %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% Path to data

pathToData = "C:\Users\User\Documents\Micron Optics\ENLIGHT\Data\ZM and DK exp\Alpha-syn detection"; %the path to you folder (copy from the address line)
% You do NOT need to move the script or the data files


N_Conc = 6; % Number of Conc. values
N_Val = 20; % Number of times each Conc. was sampled

% return % Comment for loading the whole file


% Low-pass filter
[b,a] = butter(5,0.1);

% Channel for analysis
% Note: select as they appear in the text files,
% So if in text files you have CH1 CH2 CH5 CH6 CH7 CH8
% and you want to analyze CH1 and CH8 then here type [1 6]
% since they appear in 1st and 6th position

% Note: I tested only for one channel

Channel_For_Analysis = [5];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Load data from files %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

kk = 1;
for ii = 1:N_Conc
    for jj = 1:N_Val
        
        
        Fname = strcat(pathToData, '\', 'concentration', num2str(ii), '_measurement', num2str(jj), '.txt');
        Data = importdata(Fname);
        Mat = Data.data;
        
        [D1,D2] = size(Mat);
        
        % Load data on each channel
        if (kk==1)
            Wavelength = Mat(:,1);
        end
        
        if (D2>=2)
            CH1(kk,:) = Mat(:,2);
        else
            CH1(kk,:) = zeros(D1,1);
        end
        
        if (D2>=3)
            CH2(kk,:) = Mat(:,3);
        else
            CH2(kk,:) = zeros(D1,1);
        end
        
        if (D2>=4)
            CH3(kk,:) = Mat(:,4);
        else
            CH3(kk,:) = zeros(D1,1);
        end
        
        if (D2>=5)
            CH4(kk,:) = Mat(:,5);
        else
            CH4(kk,:) = zeros(D1,1);
        end
        
        if (D2>=6)
            CH5(kk,:) = Mat(:,6);
        else
            CH5(kk,:) = zeros(D1,1);
        end
        
        if (D2>=7)
            CH6(kk,:) = Mat(:,7);
        else
            CH6(kk,:) = zeros(D1,1);
        end
        
        if (D2>=8)
            CH7(kk,:) = Mat(:,8);
        else
            CH7(kk,:) = zeros(D1,1);
        end
        
        if (D2>=9)
            CH8(kk,:) = Mat(:,9);
        else
            CH8(kk,:) = zeros(D1,1);
        end

  
        kk = kk+1;
        
    end
end

kk = kk-1;

%%% Filter data

for ii = 1:kk
    CHF1(ii,:) = filter(b,a,CH1(ii,:));
    CHF2(ii,:) = filter(b,a,CH2(ii,:));
    CHF3(ii,:) = filter(b,a,CH3(ii,:));
    CHF4(ii,:) = filter(b,a,CH4(ii,:));
    CHF5(ii,:) = filter(b,a,CH5(ii,:));
    CHF6(ii,:) = filter(b,a,CH6(ii,:));
    CHF7(ii,:) = filter(b,a,CH7(ii,:));
    CHF8(ii,:) = filter(b,a,CH8(ii,:));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Analysis %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for zz = 1:length(Channel_For_Analysis)
    
    % Select each channel for analysis
    NC = Channel_For_Analysis(zz);
    switch(NC)
        case (1)
            FData = CHF1;
        case(2)
            FData = CHF2;
        case(3)
            FData = CHF3;
        case(4)
            FData = CHF4;
        case(5)
            FData = CHF5;
        case(6)
            FData = CHF6;
        case(7)
            FData = CHF7;
        case(8)
            FData = CHF8;
            
    end
    
    % Set transient values and remove FBGs: edit this values accordingly
    
    TRANSIENT = 1000; % Length of filter transient
    FBG_LEFT = 10900; % Leftmost part of the FBG spectrum
    FBG_RIGHT = 12000; % Rightmost part of the FBG spectrum
    
    SpectrumSDI = FData(:, [TRANSIENT:FBG_LEFT, FBG_RIGHT:20000]);
    WavSDI  = Wavelength ([TRANSIENT:FBG_LEFT, FBG_RIGHT:20000]);
    
    % Peak tracking
    RefSp = SpectrumSDI(1,:); % Change if peak detection is incorrect
    MPP = 1.5; % Min. peak prominence, change if you want to track differently
    
    [P, LocPeaks] = findpeaks(RefSp, 'MinPeakProminence',MPP);
    [P, LocValleys] = findpeaks(-RefSp, 'MinPeakProminence',MPP);
    
    % Set window for each analysis
    NW = 50; % means it searches for NW left and NW right of the identified peaks
    NW2 = 20; % narrower window to refine the search
  
    % Collect all peaks, intensity and wavelength shift
    jj = 1;
    for ii = 1:length(LocPeaks)
        
        for ss = 1:kk
            if ( LocPeaks(ii)-NW > 0)
                if ( LocPeaks(ii)+NW < length(WavSDI))
                    
                    xx = WavSDI(LocPeaks(ii)-NW : LocPeaks(ii)+NW)';
                    yy = SpectrumSDI(ss,LocPeaks(ii)-NW : LocPeaks(ii)+NW);
                    
                    [xm,im] = max(yy);
                    I1 = max([1, im-NW2]);
                    I2 = min([im + NW2, NW*2+1]);
                    IND_SEL = I1:I2;
                    
                    xxx = xx(IND_SEL);
                    yyy = yy(IND_SEL);
                    
                    
                    % 2nd order fit
                    p = polyfit(xxx,yyy,2);
                    clc;
                    WavPeak(jj,ss) = -p(2) ./ (2*p(1));
                    IntPeak(jj,ss) = p(3) - p(2).^2 ./ (4*p(1));
                    
                    [jj ss]
                    
                end
            end
        end
        jj = jj+1;
        S1 = jj-1;
    end
    
       
    % Collect all valleys, intensity and wavelength shift
    jj = 1;
    for ii = 1:length(LocValleys)
        
        for ss = 1:kk
            if ( LocValleys(ii)-NW > 0)
                if ( LocValleys(ii)+NW < length(WavSDI))
                    
                    xx = WavSDI(LocValleys(ii)-NW : LocValleys(ii)+NW)';
                    yy = SpectrumSDI(ss,LocValleys(ii)-NW : LocValleys(ii)+NW);
                    
                    [xm,im] = min(yy);
                    I1 = max([1, im-NW2]);
                    I2 = min([im + NW2, NW*2+1]);
                    IND_SEL = I1:I2;
                    
                    xxx = xx(IND_SEL);
                    yyy = yy(IND_SEL);
                    
                    
                    % 2nd order fit
                    p = polyfit(xxx,yyy,2);
                    clc;
                    WavValley(jj,ss) = -p(2) ./ (2*p(1));
                    IntValley(jj,ss) = p(3) - p(2).^2 ./ (4*p(1));
                    
                    [jj ss]
                    
                end
            end
        end
        jj = jj+1;
        S2 = jj-1;
    end
    
    clc
    
    
    % Build timelines of peaks and valleys though statistical distribution
    
    for jj = 1:kk
        
        wp = WavPeak(:,jj) - WavPeak(:,1);
        ip = IntPeak(:,jj) - IntPeak(:,1);
        wv = WavValley(:,jj) - WavValley(:,1);
        iv = IntValley(:,jj) - IntValley(:,1);
        
        % Remove outliers
        TH_INT = 5;
        TH_WAV = 3;
        
        wpt = wp(abs(wp) < TH_WAV);
        wvt = wv(abs(wv) < TH_WAV);
        ipt = ip(abs(ip) < TH_INT);
        ivt = iv(abs(iv) < TH_INT);
        
        % Fit to normal distributions
        PD1 = fitdist(wpt, 'normal');
        PD2 = fitdist(wvt, 'normal');
        PD3 = fitdist(ipt, 'normal');
        PD4 = fitdist(ivt, 'normal');
        
        % Select mean value
        WavShiftPeak(jj) = PD1.mu;
        WavShiftValley(jj) = PD2.mu;
        IntChangePeak(jj) = PD3.mu;
        IntChangeValley(jj) = PD4.mu;
        
    end
    
    figure
    time = 1:kk;
    subplot(1,2,1)
    plot(time,WavShiftPeak,'LineWidth',2)
    hold on
    plot(time,WavShiftValley,'LineWidth',2)
    xlabel('sampling');
    ylabel('wav. shift (nm)');
    legend('Peak','Valley')

    subplot(1,2,2)
    plot(time,IntChangePeak,'LineWidth',2)
    hold on
    plot(time,IntChangeValley,'LineWidth',2)
    xlabel('sampling');
    ylabel('intensity change (dB)');
    legend('Peak','Valley')

    
        
end



