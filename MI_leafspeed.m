function [time_interval,MLC_speed_mat] = MI_leafspeed(VMAT_PLN_INFO)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Max_gantry_speed = 6; % degree/s
Max_dose_rate = 720;  % MU/min

%% calculate time interval between CPs
time_interval = zeros(VMAT_PLN_INFO.Total_CPs-1,1);

% Arc1
for j=1:VMAT_PLN_INFO.Total_CPs-1
    
   if VMAT_PLN_INFO.CP_info{j,1} ~= VMAT_PLN_INFO.CP_info{j+1,1}
       
       if VMAT_PLN_INFO.CP_info{j,1} < VMAT_PLN_INFO.CP_info{j+1,1}
           delta_gantry = VMAT_PLN_INFO.CP_info{j+1,1} - VMAT_PLN_INFO.CP_info{j,1}; % gantry interval
       else
           delta_gantry = 360 + VMAT_PLN_INFO.CP_info{j+1,1} - VMAT_PLN_INFO.CP_info{j,1}; % gantry interval
       end
       delta_MU = VMAT_PLN_INFO.CP_info{j+1,2} - VMAT_PLN_INFO.CP_info{j,2};     % MU interval
       max_MU_interval = delta_gantry/Max_gantry_speed*Max_dose_rate/60;
       
       if delta_MU <= max_MU_interval
           
           time_interval(j) = delta_gantry/Max_gantry_speed; % time interval
           
       else
           
           time_interval(j) = delta_MU/(Max_dose_rate/60);   % time interval
       end
       
   else
       fprintf('This is %d control point with gantry angle: %d',...
           j,VMAT_PLN_INFO.CP_info{j,1});
       break
   end
end

flag = j; % flag the first point of second arc

% Par2: the second arc
for jj=j+1:VMAT_PLN_INFO.Total_CPs-1
    
   if VMAT_PLN_INFO.CP_info{jj,1} ~= VMAT_PLN_INFO.CP_info{jj+1,1}
       
       if VMAT_PLN_INFO.CP_info{jj,1} > VMAT_PLN_INFO.CP_info{jj+1,1}
           delta_gantry = abs(VMAT_PLN_INFO.CP_info{jj+1,1} - VMAT_PLN_INFO.CP_info{jj,1}); % gantry interval
       else
           % 0, 357.34
           delta_gantry = VMAT_PLN_INFO.CP_info{jj,1} - (VMAT_PLN_INFO.CP_info{jj+1,1}-360); % gantry interval
       end
       delta_MU = VMAT_PLN_INFO.CP_info{jj+1,2} - VMAT_PLN_INFO.CP_info{jj,2};     % MU interval
       max_MU_interval = delta_gantry/Max_gantry_speed*Max_dose_rate/60;
       
       if delta_MU <= max_MU_interval
           
           time_interval(jj) = delta_gantry/Max_gantry_speed; % time interval
           
       else
           
           time_interval(jj) = delta_MU/(Max_dose_rate/60);   % time interval
       end
       
   else
       fprintf('This is %d control point with gantry angle: %d',...
           j,VMAT_PLN_INFO.CP_info{j,1});
       break
   end
end   
   
%% calculate modulation index for leaf speed
    
MLC_speed_mat = zeros(size(VMAT_PLN_INFO.CP_info{1, 3},1),VMAT_PLN_INFO.Total_CPs-1);

for jj=1:VMAT_PLN_INFO.Total_CPs-1
    MLC_speed_mat(:,jj) = (VMAT_PLN_INFO.CP_info{jj+1, 3}-...
        VMAT_PLN_INFO.CP_info{jj, 3})./time_interval(jj);  %mm/s
end

MLC_speed_mat(:,flag) = 0;

MLC_std = zeros(size(MLC_speed_mat,1),1);

for k=1:size(MLC_speed_mat,1)
    MLC_std(k) = std(abs(MLC_speed_mat(k,:)));
end

% the first leaf position
X = (abs(MLC_speed_mat(1,:)));
f = 0:0.01:2;
f_threshold = f*MLC_std(1);
z_distribution = zeros(length(f_threshold),1);
for kk = 1:length(f)
    
    z_distribution(kk) = sum(X>f_threshold(kk))/length(X);
    
end

Z_dis = z_distribution(kk).*f;
MI_1 = sum(Z_dis(1:101));
MI_2 = sum(Z_dis);
end



