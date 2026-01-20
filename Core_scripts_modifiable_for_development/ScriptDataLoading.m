clear all
close all
clc

%%%%%% Path to data

pathToData = "C:\Users\User\Documents\Micron Optics\ENLIGHT\Data\ZM and DK exp\Alpha-syn detection"; %the path to you folder (copy from the address line)
% You do NOT need to move the script or the data files


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Parameters initialization %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_Conc = 6; % Number of Conc. values
N_Val = 10; % Number of times each Conc. was sampled

% Low-pass filter
[b,a] = butter(5,0.01);


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




