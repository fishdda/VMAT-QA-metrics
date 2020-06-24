function VMAT_PLN_INFO = MI_TotalModulation(VMAT_PLN_INFO)
%MI_TotalModulation Summary of this function goes here
%   MI_TotalModulation.m Comprehensively consider gantry acceleration,
%   dose rate variation, mlc leaf speed and acceleration to calculate
%   Modulation Index for VMAT
%   doi: https://doi.org/10.1016/j.ijrobp.2019.07.049

%% calculate gantry speed and acceleration (GA = abs(Gantry_Speed_i - Gantry_Speed_i+1))
Gantry_Angle = VMAT_PLN_INFO.CP_info(:,1);
Gantry_Speed = zeros(size(Gantry_Angle,1)-1,1);

for kk = 1:length(Gantry_Speed)
    Gantry_Speed(kk) = abs(Gantry_Angle{kk,1}-Gantry_Angle{kk+1,1})/VMAT_PLN_INFO.CP_time_interval(kk);
end

Gantry_Acceleration = zeros(size(Gantry_Angle,1)-2,1);
for kk = 1:length(Gantry_Acceleration)
    Gantry_Acceleration(kk) = abs(Gantry_Speed(kk)-Gantry_Speed(kk+1));
end

%% calculate dose rate variation (DRV = abs(DR_i - DR_i+1)) 

MU_vector = VMAT_PLN_INFO.CP_info(:,2);  
Dose_Rate = zeros(size(MU_vector,1)-1,1);

for kk = 1:length(Dose_Rate)
    Dose_Rate(kk) = abs(MU_vector{kk,1}-MU_vector{kk+1,1})/VMAT_PLN_INFO.CP_time_interval(kk);
end

Dose_Rate_Variation = zeros(length(Dose_Rate)-1,1);
for kk = 1:length(Dose_Rate_Variation)
    Dose_Rate_Variation(kk) = abs(Dose_Rate(kk)-Dose_Rate(kk+1));
end

%% calculate W_GA and W_MU (W_GA = beta/(1+(beta-1)*exp(-GA/gamma)), W_MU = beta/(1+(beta-1)*exp(-DRV/gamma)))

beta = 2; gamma = 2; 
W_GA = zeros(length(Gantry_Acceleration),1); W_MU = zeros(length(Dose_Rate_Variation),1);
for ss = 1:length(Dose_Rate_Variation)
    W_GA(ss) = beta/(1+(beta-1)*exp(-Gantry_Acceleration(ss)/gamma));
    W_MU(ss) = beta/(1+(beta-1)*exp(-Dose_Rate_Variation(ss)/gamma));
end


%% calculate index of total modulation

f = 0:0.01:2;
Z = zeros(size(VMAT_PLN_INFO.MLC_speed_std,1),length(f)); % leaf number X 0,0.01,0.02,...2
% MLC_Speed = VMAT_PLN_INFO.MLC_speed_mat; % leaf number X number of CPs  

for ii = 1:size(Z,1)
    f_threshold1 = f*VMAT_PLN_INFO.MLC_speed_std(ii); % the serial number of leaf position (e.g 2nd leaf of 160 leaves)
    f_threshold2 = f*VMAT_PLN_INFO.MLC_acceleration_std(ii); % the serial number of leaf position (e.g 2nd leaf of 160 leaves)
    for jj = 1:size(Z,2) % f = 0,0.01,0.02
        N = 0;
        for kk = 1:length(W_GA)
            if VMAT_PLN_INFO.MLC_speed_mat(ii,kk) >  f_threshold1(jj) || ...
                    VMAT_PLN_INFO.MLC_acceleration_mat(ii,kk) > f_threshold2(jj)/VMAT_PLN_INFO.CP_time_interval(kk)
                N = N + W_GA(kk)*W_MU(kk);
            end
        
        end
        Z(ii,jj) = N/(VMAT_PLN_INFO.Total_CPs-2);
        
    end
end

idx1 = find(f==0.2);idx2 = find(f==0.5);idx3 = find(f==1);idx4 = find(f==2);
VMAT_PLN_INFO.MI_TotalModulation_02 = sum(0.01*sum(Z(:,1:idx1),2));
VMAT_PLN_INFO.MI_TotalModulation_05 = sum(0.01*sum(Z(:,1:idx2),2));
VMAT_PLN_INFO.MI_TotalModulation_1 = sum(0.01*sum(Z(:,1:idx3),2));
VMAT_PLN_INFO.MI_TotalModulation_2 = sum(0.01*sum(Z(:,1:idx4),2));

VMAT_PLN_INFO.DOSERATE = Dose_Rate;
VMAT_PLN_INFO.GantrySpeed = Gantry_Speed;

% average dose rate and standard deviation of dose rate (ADR, SDR)
VMAT_PLN_INFO.ADR = mean(Dose_Rate);
VMAT_PLN_INFO.SDR = std(Dose_Rate);

end

