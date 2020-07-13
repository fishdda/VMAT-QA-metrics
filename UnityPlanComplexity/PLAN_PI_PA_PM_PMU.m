function VMAT_PLN_INFO = PLAN_PI_PA_PM_PMU(VMAT_PLN_INFO,BLD_type)
%PLAN_PI_PA_PM_PMU calculate plan area, plan irregularity, plan modulation 
%   and plan normalized MU
%   Note: union aperture area is greater than or equal to the area of any
%   individual aperture.

%   doi: 10.1118/1.4861821
%% calculate the differential MU weights
weighted_MU = VMAT_PLN_INFO.CP_info(:,2);
for i=1:length(weighted_MU)-1
    MU_weight(i) =  (weighted_MU{i+1,1} - weighted_MU{i,1})/VMAT_PLN_INFO.Total_MU;
end

%% Union aperture area and remove the first control point
MLC =VMAT_PLN_INFO.CP_info(:,3);
JAW = VMAT_PLN_INFO.CP_info(:,4);
Union_Aperture_MLC = zeros(size(MLC{1,1},1),size(MLC,1));
Union_Aperture_JAW = zeros(2,size(MLC,1));
for k =1:size(MLC,1)
    Union_Aperture_MLC(:,k) = MLC{k,1};
    Union_Aperture_JAW(:,k) = JAW{k,1};
end

Union_Aperture_MLC_1 = Union_Aperture_MLC(1:size(MLC{1,1},1)/2,:);
Union_Aperture_MLC_2 = Union_Aperture_MLC(size(MLC{1,1},1)/2+1:size(MLC{1,1},1),:);

% calculate the most extended aperture region for union
Union_Aperture_MLC_ = [min(Union_Aperture_MLC_1(:,2:end),[],2),max(Union_Aperture_MLC_2(:,2:end),[],2)];
Union_Aperture_JAW_ = [min(Union_Aperture_JAW(2:end),[],2);max(Union_Aperture_JAW(2:end),[],2)];
Union_Aperture_Area = 0;

if BLD_type == 'synergy'
    mlc_leaf = reshape(mlc_leaf,[size(mlc_leaf,1)/2,2]);
    VMAT_PLN_INFO.CP_info{1, 3}
%         eval(['yjaw = plan_info.BeamSequence.Item_',int2str(k),...
%             '.ControlPointSequence.Item_',int2str(2*i-1),...
%             '.BeamLimitingDevicePositionSequence.Item_1.LeafJawPositions;'])
    eval(['yjaw = plan_info.BeamSequence.Item_',int2str(k),...
        '.ControlPointSequence.Item_',int2str(2*i-1),...
        '.BeamLimitingDevicePositionSequence.Item_2.LeafJawPositions;'])

elseif BLD_type == 'agility'
    mlc_width = 5; % 5mm
end

start_point = ((200+Union_Aperture_JAW_(1))/mlc_width)+1;
end_point = size(Union_Aperture_MLC_,1)-(200-Union_Aperture_JAW_(2))/mlc_width;
if rem(start_point,1) == 0 && rem(end_point,1) == 0
    % calculate segment area
    for j = start_point:end_point
         Union_Aperture_Area =  Union_Aperture_Area + (Union_Aperture_MLC_(j,2)-Union_Aperture_MLC_(j,1))*mlc_width/100;
    end
    
elseif rem(start_point,1) ~= 0 && rem(end_point,1) == 0
    % calculate segment area
    start_point = floor((200+Union_Aperture_JAW_(1))/mlc_width)+1;
    first_width = mlc_width - mod(200+Union_Aperture_JAW_(1),mlc_width); % first leaf should be only 2mm width
    Union_Aperture_Area =  Union_Aperture_Area + (Union_Aperture_MLC_(start_point,2)-Union_Aperture_MLC_(start_point,1))*first_width/100;
    
    for j = start_point+1:end_point
         Union_Aperture_Area =  Union_Aperture_Area + (Union_Aperture_MLC_(j,2)-Union_Aperture_MLC_(j,1))*mlc_width/100;   
    end

elseif rem(start_point,1) == 0 && rem(end_point,1) ~= 0

    end_point = size(Union_Aperture_MLC_,1)/2 + floor(Union_Aperture_JAW_(2)/mlc_width);
    last_width = mod(Union_Aperture_JAW_(2),mlc_width); % first leaf should be only 2mm width
    disp(end_point+1)
    Union_Aperture_Area =  Union_Aperture_Area + (Union_Aperture_MLC_(end_point+1,2)-Union_Aperture_MLC_(end_point+1,1))*last_width/100;
    for j = start_point:end_point
         Union_Aperture_Area =  Union_Aperture_Area + (Union_Aperture_MLC_(j,2)-Union_Aperture_MLC_(j,1))*mlc_width/100;   
    end

elseif rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0

    start_point = floor((200+Union_Aperture_JAW_(1))/mlc_width)+1;
    end_point = size(Union_Aperture_MLC_,1)/2 + floor(yjaw(2)/mlc_width);
    last_width = mod(yjaw(2),mlc_width); % first leaf should be only 2mm width
    first_width = mlc_width - mod(200+Union_Aperture_JAW_(1),mlc_width); % first leaf should be only 2mm width

    Union_Aperture_Area =  Union_Aperture_Area + (Union_Aperture_MLC_(start_point,2)-Union_Aperture_MLC_(start_point,1))*first_width/100;
    Union_Aperture_Area =  Union_Aperture_Area + (Union_Aperture_MLC_(end_point+1,2)-Union_Aperture_MLC_(end_point+1,1))*last_width/100;
    for j = start_point+1:end_point
         Union_Aperture_Area =  Union_Aperture_Area + (Union_Aperture_MLC_(j,2)-Union_Aperture_MLC_(j,1))*mlc_width/100;   
    end
    disp('rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0');
end

VMAT_PLN_INFO.UAA =  Union_Aperture_Area;
%% plan area
VMAT_PLN_INFO.PA = VMAT_PLN_INFO.MFA;

%% plan irregularity 
VMAT_PLN_INFO.AI = (VMAT_PLN_INFO.AP).^2./(4*pi*VMAT_PLN_INFO.AA); 
VMAT_PLN_INFO.PI = sum(VMAT_PLN_INFO.AI(2:end).*MU_weight');

%% plan modulation remove the first control point
VMAT_PLN_INFO.PM = 1- sum(VMAT_PLN_INFO.AA(2:end).*MU_weight')/Union_Aperture_Area;

%% plan normalized MU
VMAT_PLN_INFO.PMU = VMAT_PLN_INFO.Total_MU*2/(VMAT_PLN_INFO.TPD/VMAT_PLN_INFO.FX);

end

