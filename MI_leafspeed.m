function VMAT_PLN_INFO= MI_leafspeed(VMAT_PLN_INFO)
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
    
MLC_speed_mat = zeros(size(VMAT_PLN_INFO.CP_info{1, 3},1),VMAT_PLN_INFO.Total_CPs-1); % construct the MLC speed matrix (num of MLC leaves x num of control points)

for jj=1:VMAT_PLN_INFO.Total_CPs-1
    MLC_speed_mat(:,jj) = abs((VMAT_PLN_INFO.CP_info{jj, 3}-...
        VMAT_PLN_INFO.CP_info{jj+1, 3}))./time_interval(jj);  %mm/s
end

MLC_speed_mat(:,flag) = 0;
VMAT_PLN_INFO.MLC_speed_std = std(MLC_speed_mat,0,2);


% initialize the Z distribution
f = 0:0.01:2;
Z = zeros(size(VMAT_PLN_INFO.MLC_speed_std,1),length(f));
X = abs(MLC_speed_mat); % absolute value of leaf speed

for ii = 1:size(Z,1)
    f_threshold = f*VMAT_PLN_INFO.MLC_speed_std(ii); % the serial number of leaf position (e.g 2nd leaf of 160 leaves)
    for jj = 1:size(Z,2)      
        Z(ii,jj) = sum(X(ii,:)>f_threshold(jj))/(VMAT_PLN_INFO.Total_CPs-1);
    end
end

idx1 = find(f==0.2);idx2 = find(f==0.5);idx3 = find(f==1);idx4 = find(f==2);
VMAT_PLN_INFO.MI_S_02 = sum(0.01*sum(Z(:,1:idx1),2));
VMAT_PLN_INFO.MI_S_05 = sum(0.01*sum(Z(:,1:idx2),2));
VMAT_PLN_INFO.MI_S_1 = sum(0.01*sum(Z(:,1:idx3),2));
VMAT_PLN_INFO.MI_S_2 = sum(0.01*sum(Z(:,1:idx4),2));

VMAT_PLN_INFO.MLC_speed_mat = MLC_speed_mat; % a matrix (160 leaf x 219 control points)
VMAT_PLN_INFO.CP_time_interval = time_interval; % time interval between different control points

% calculate average leaf speed
VMAT_PLN_INFO.ALS = mean(mean(VMAT_PLN_INFO.MLC_speed_mat)); % mm/s
end



