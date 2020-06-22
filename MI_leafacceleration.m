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

MLC_acceleration_std = std(VMAT_PLN_INFO.MLC_acceleration_mat,0,2); % calculate the deviation of acceleration

% initialize the Z distribution
f = 0:0.01:2; 
Z = zeros(size(MLC_std,1),length(f));
X = abs(MLC_speed_mat); % absolute value of leaf speed








for ii = 1:size(Z,1)
    f_threshold = f*MLC_std(ii); % the serial number of leaf position (e.g 2nd leaf of 160 leaves)
    for jj = 1:size(Z,2)      
        Z(ii,jj) = sum(X(ii,:)>f_threshold(ii))/VMAT_PLN_INFO.Total_CPs;
    end
end

idx1 = find(f==0.2);idx2 = find(f==0.5);idx3 = find(f==1);idx4 = find(f==2);
VMAT_PLN_INFO.MI_S_02 = sum(0.01*sum(Z(:,1:idx1),2));
VMAT_PLN_INFO.MI_S_05 = sum(0.01*sum(Z(:,1:idx2),2));
VMAT_PLN_INFO.MI_S_1 = sum(0.01*sum(Z(:,1:idx3),2));
VMAT_PLN_INFO.MI_S_2 = sum(0.01*sum(Z(:,1:idx4),2));

VMAT_PLN_INFO.MLC_speed_mat = MLC_speed_mat; % a matrix (160 leaf x 219 control points)
VMAT_PLN_INFO.CP_time_interval = time_interval; % time interval between different control points
end

