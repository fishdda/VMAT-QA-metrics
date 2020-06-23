function VMAT_PLN_INFO = MI_leafacceleration(VMAT_PLN_INFO)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% calculate acceleration between CPs
% construct the MLC speed matrix (num of MLC leaves x num of control points)
VMAT_PLN_INFO.MLC_acceleration_mat = zeros(size(VMAT_PLN_INFO.CP_info{1, 3},1),VMAT_PLN_INFO.Total_CPs-2); 
   
for jj=1:VMAT_PLN_INFO.Total_CPs-2
    VMAT_PLN_INFO.MLC_acceleration_mat(:,jj) = abs(VMAT_PLN_INFO.MLC_speed_mat(:,jj)-...
        VMAT_PLN_INFO.MLC_speed_mat(:,jj+1))./VMAT_PLN_INFO.CP_time_interval(jj);  %mm/s
end

% VMAT_PLN_INFO.MLC_acceleration_mat(:,117) = 0;
VMAT_PLN_INFO.MLC_acceleration_mat(isinf(VMAT_PLN_INFO.MLC_acceleration_mat...
    )|isnan(VMAT_PLN_INFO.MLC_acceleration_mat)) = 0; % Replace NaNs and infinite values with zeros

VMAT_PLN_INFO.MLC_acceleration_std = std(VMAT_PLN_INFO.MLC_acceleration_mat,0,2); % calculate the deviation of acceleration

% initialize the Z distribution
f = 0:0.01:2; 
Z = zeros(length(VMAT_PLN_INFO.MLC_acceleration_std),length(f));
% X = abs(MLC_speed_mat); % absolute value of leaf speed

for ii = 1:size(Z,1)
    
    f_threshold1 = f*VMAT_PLN_INFO.MLC_speed_std(ii); % the serial number of leaf position (e.g 2nd leaf of 160 leaves)
    f_threshold2 = f*VMAT_PLN_INFO.MLC_acceleration_std(ii); % the serial number of leaf position (e.g 2nd leaf of 160 leaves)
    for jj = 1:size(Z,2)
        N = 0; % count the N satisfied the constraints MLC speed > f*std_MLC_speed; MLC acceleration > f*std_MLC_acceleration/time_interval
        for kk = 1:size(VMAT_PLN_INFO.MLC_acceleration_mat,2)
            if VMAT_PLN_INFO.MLC_speed_mat(ii,kk) >  f_threshold1(jj) ...
            || VMAT_PLN_INFO.MLC_acceleration_mat(ii,kk) > f_threshold2(jj)/VMAT_PLN_INFO.CP_time_interval(kk)
                    N = N + 1;
            end
               
        end
        Z(ii,jj) = N/(VMAT_PLN_INFO.Total_CPs-2);
    end
end

idx1 = find(f==0.2);idx2 = find(f==0.5);idx3 = find(f==1);idx4 = find(f==2);
VMAT_PLN_INFO.MI_Accelerate_02 = sum(0.01*sum(Z(:,1:idx1),2));
VMAT_PLN_INFO.MI_Accelerate_05 = sum(0.01*sum(Z(:,1:idx2),2));
VMAT_PLN_INFO.MI_Accelerate_1 = sum(0.01*sum(Z(:,1:idx3),2));
VMAT_PLN_INFO.MI_Accelerate_2 = sum(0.01*sum(Z(:,1:idx4),2));

% calculate average leaf speed and standard deviation of leaf speed
VMAT_PLN_INFO.ALA = mean(mean(VMAT_PLN_INFO.MLC_acceleration_mat)); % mm/s
VMAT_PLN_INFO.SLA = mean(VMAT_PLN_INFO.MLC_acceleration_std); % mm/s

end

