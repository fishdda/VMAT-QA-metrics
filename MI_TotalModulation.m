function VMAT_PLN_INFO = MI_TotalModulation(VMAT_PLN_INFO)
%UNTITLED4 Summary of this function goes here
%   Comprehensively consider gantry speed, dose rate 

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

Gantry_Acceleration = zeros(size(Gantry_Angle,1)-2,1);
for kk = 1:length(Gantry_Acceleration)
    Gantry_Acceleration(kk) = abs(Gantry_Speed(kk)-Gantry_Speed(kk+1));
end


end
