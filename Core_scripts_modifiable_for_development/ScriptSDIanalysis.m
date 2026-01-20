clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Parameters initialization %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_Conc = 10; % Number of Conc. values
N_Val = 20; % Number of times each Conc. was sampled

% return % Comment for loading the whole file


% Low-pass filter
[b,a] = butter(5,0.01);

% Channel for analysis
% Note: select as they appear in the text files,
% So if in text files you have CH1 CH2 CH5 CH6 CH7 CH8
% and you want to analyze CH1 and CH8 then here type [1 6]
% since they appear in 1st and 6th position

Channel_For_Analysis = [1 2 3 4 5];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Load data from files %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

kk = 1;
for ii = 1:N_Conc
    for jj = 1:N_Val
        
        
        Fname = strcat('concentration', num2str(ii), '_measurement', num2str(jj), '.txt');
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

for ii = 1:length(Channel_For_Analysis)
    
    % Select each channel for analysis
    NC = Channel_For_Analysis(ii);
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
    
    % Set transient values and remove FBGs
    
    TRANSIENT = 1000; % Length of filter transient
    FBG_LEFT = 11000; % Leftmost part of the FBG spectrum
    FBG_RIGHT = 12000; % Rightmost part of the FBG spectrum
    
    SpectrumSDI = FData(:, [TRANSIENT:FBG_LEFT, FBG_RIGHT:20000]);
    WavSDI  = Wavelength ([TRANSIENT:FBG_LEFT, FBG_RIGHT:20000]);
    
    % Peak tracking
    RefSp = SpectrumSDI(1,:); % Change if peak detection is incorrect
    MPP = 1.5; % Min. peak prominence
    
    [P, LocPeak] = findpeaks(RefSp, 'MinPeakProminence',MPP);
    [P, LocValleys] = findpeaks(-RefSp, 'MinPeakProminence',MPP);
    
    figure
    subplot(2,3,1)
    plot(WavSDI, RefSp);
    hold on
    plot(WavSDI(LocPeak), RefSp(LocPeak), 'x');
    plot(WavSDI(LocValleys), RefSp(LocValleys), 'o');
    xlabel('Wavelength');
    ylabel('Intensity (dB)');
    title('Sensor spectrum')
    
    % Peak tracking over the timeline
    
    PeaksM = SpectrumSDI(:, LocPeak);
    ValleysM = SpectrumSDI(:, LocValleys);
    
    for jj = 1:length(LocPeak)
        PeakTimeline = PeaksM(:,jj);
        PeakTimelineNorm(jj,:) = PeakTimeline-PeakTimeline(1);
    end
    for jj = 1:length(LocValleys)
        ValleyTimeline =ValleysM(:,jj);
        ValleyTimelineNorm(jj,:) = ValleyTimeline-ValleyTimeline(1);
    end
    
    % Statistical distribution: fit to Gaussian distribution
    
    for jj = 1:kk
        
        PP = PeakTimelineNorm(:,jj);
        VV = ValleyTimelineNorm(:,jj);
        
        PDP = fitdist(PP,'normal');
        PDV = fitdist(VV,'normal');
        
        ResponseMuP(jj) = PDP.mu;
        ResponseSigmaP(jj) = PDP.sigma;
        
        ResponseMuV(jj) = PDV.mu;
        ResponseSigmaV(jj) = PDV.sigma;
        
    end
    
    time = 1:kk;
    subplot(2,3,2);
    plot(time, ResponseMuP);
    hold on
    plot(time, ResponseMuV);
    legend('Peaks','Valleys');
    title('Timeline, mean distrib.')
    
    subplot(2,3,3);
    plot(time, ResponseSigmaP);
    hold on
    plot(time, ResponseSigmaV);
    legend('Peaks','Valleys');
    title('Timeline, st.d. distrib.')
    
    % Measure response using the mean value
    
    ind=1;
    for mm = 1:N_Val:kk
        XC = 0; % Increase if you want to cut the first minutes
        ssP = ResponseMuP(mm+XC: mm+N_Val-1);
        ssV = ResponseMuV(mm+XC: mm+N_Val-1);
       
        RP_Mean(ind) = mean(ssP);
        RP_Std(ind) = std(ssP);
        RV_Mean(ind) = mean(ssV);
        RV_Std(ind) = std(ssV);
        ind = ind+1;
        
    end
    
    subplot(2,3,4);
    ConcIndex = 1:N_Conc; % here can replace with actual concentrations
    errorbar(ConcIndex, RP_Mean, RP_Std);
    p = polyfit(ConcIndex, RP_Mean, 1);
    pp = polyval(p,ConcIndex);
    hold on
    plot(ConcIndex,pp);
    title('Peak response');
    
    subplot(2,3,5);
    ConcIndex = 1:N_Conc; % here can replace with actual concentrations
    errorbar(ConcIndex, RV_Mean, RV_Std);
    p = polyfit(ConcIndex, RV_Mean, 1);
    pp = polyval(p,ConcIndex);
    hold on
    plot(ConcIndex,pp);
    title('Valley response');
    
    % Most significant spectral feature (to compare if more reliable)
    % Select out of the all peaks/valleys only those with R2>0.9 
    % in a linear fit, and keep the most sensitive one
    % If the chart is empty it means no feature is displayed
    % i.e. the set of R2>0.9 features is a null set
    
    ind = 1;
    for jj = 1:length(LocPeak)
        nn=1;
        for mm = 1:N_Val:kk
            sss = SpectrumSDI(mm+XC: mm+N_Val-1, LocPeak(jj));
            ResponseM(nn) = mean(sss);
            ResponseS(nn) = std(sss);
            nn = nn+1;
        end
        ResponseM = ResponseM-ResponseM(1);
        p = polyfit(ConcIndex, ResponseM,1);
        pp = polyval(p, ConcIndex);
        
        R2(ind) = rsquare(ResponseM,pp);
        Sensitivity(ind) = p(1);
        ResAllM(ind,:) = ResponseM;
        ResAllS(ind,:) = ResponseS;
        ind = ind+1;
    end
    for jj = 1:length(LocValleys)
        nn=1;
        for mm = 1:N_Val:kk
            sss = SpectrumSDI(mm+XC: mm+N_Val-1, LocValleys(jj));
            ResponseM(nn) = mean(sss);
            ResponseS(nn) = std(sss);
            nn = nn+1;
        end
        ResponseM = ResponseM-ResponseM(1);
        p = polyfit(ConcIndex, ResponseM,1);
        pp = polyval(p, ConcIndex);
        
        R2(ind) = rsquare(ResponseM,pp);
        Sensitivity(ind) = abs(p(1));
        ResAllM(ind,:) = ResponseM;
        ResAllS(ind,:) = ResponseS;
        ind = ind+1;
    end
    
    AcceptedInd = (R2>0.9); % change if you want a different threshold
    SensitivityA = Sensitivity(AcceptedInd);
    [Y,IndM]=max(SensitivityA);
    
    subplot(2,3,6)
    YY = ResAllM(AcceptedInd,:);
    SS = ResAllS(AcceptedInd,:);
    [s1,s2] = size(YY);
    if (s1>0)
        errorbar(ConcIndex, YY(IndM,:), SS(IndM,:) );
    end
    title('Most significant feature');
    
    clear LocPeak LocValleys ii jj mm nn sss ssP ssV ValleysM PeaksM
    clear PeakTimelineNorm PeakTimeline ValleyTimeline ValleyTimelineNorm
    clear SpectrumSDI Sensitivity SensitivityA s1 s2 RV_Std RV_Mean
    clear RP_Std RP_Mean ResponseSigmaP ResponseSigmaV Response S
    clear Response MuP ResponseMuV ResponseM ResAllS ResAllM
    clear RefSp R2 PP pp P PDV PDP Mat 
    
    
        
        
        
end



