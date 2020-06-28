function VMAT_PLN_INFO = Mean_Asymmetry_Distance(VMAT_PLN_INFO,BLD_type)
%VMAT_PLN_INFO Calculate the mean asymmetry distance of a treatment beam
%   Mean Asymmetry Distance(MAD) is the weighted average of distance
%   between of the center of every open leaf pair aperture m and the
%   central beam axis

%% calculate the MU weights
weighted_MU = VMAT_PLN_INFO.CP_info(:,2);
for i=1:length(weighted_MU)-1
    MU_weight(i) =  (weighted_MU{i+1,1} - weighted_MU{i,1})/VMAT_PLN_INFO.Total_MU;
end

%% calculate Mean Asymmetry Distance
Aperture_Center = zeros(VMAT_PLN_INFO.Total_CPs-1,1);
for k= 1:length(Aperture_Center)
    % segment serial number
        if BLD_type == "synergy"
            mlc_leaf = reshape(mlc_leaf,[size(mlc_leaf,1)/2,2]);
            VMAT_PLN_INFO.CP_info{1, 3}
    %         eval(['yjaw = plan_info.BeamSequence.Item_',int2str(k),...
    %             '.ControlPointSequence.Item_',int2str(2*i-1),...
    %             '.BeamLimitingDevicePositionSequence.Item_1.LeafJawPositions;'])
            eval(['yjaw = plan_info.BeamSequence.Item_',int2str(k),...
                '.ControlPointSequence.Item_',int2str(2*i-1),...
                '.BeamLimitingDevicePositionSequence.Item_2.LeafJawPositions;'])

        elseif BLD_type == "agility"
            mlc_width = 5; % 5mm
            mlc_leaf = reshape(VMAT_PLN_INFO.CP_info{k, 3},[size(VMAT_PLN_INFO.CP_info{k, 3},1)/2,2]);
            yjaw = VMAT_PLN_INFO.CP_info{k, 4};  
        end
        
        % determine the first leaf positions and last leaf positions
        start_point = ((200+yjaw(1))/mlc_width)+1;
        end_point = size(mlc_leaf,1)-(200-yjaw(2))/mlc_width;
        
        if rem(start_point,1) == 0 && rem(end_point,1) == 0
            
            % calculate segment center 
            Aperture_Center(k) = sum(abs((mlc_leaf(start_point:end_point,1) + mlc_leaf(start_point:end_point,2))./2));
            
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) == 0

            start_point = floor((200+yjaw(1))/mlc_width)+1;
            % calculate segment center 
            Aperture_Center(k) = sum(abs((mlc_leaf(start_point:end_point,1) + mlc_leaf(start_point:end_point,2))./2));
            
        elseif rem(start_point,1) == 0 && rem(end_point,1) ~= 0
            
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            % calculate segment center 
            Aperture_Center(k) = sum(abs((mlc_leaf(start_point:end_point+1,1) + mlc_leaf(start_point:end_point+1,2))./2));

            
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0

            start_point = floor((200+yjaw(1))/mlc_width)+1;
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            % calculate segment center 
            Aperture_Center(k) = sum(abs((mlc_leaf(start_point:end_point+1,1) + mlc_leaf(start_point:end_point+1,2))./2));

 
        end

end
VMAT_PLN_INFO.MAD= sum(Aperture_Center.*MU_weight')/10;  % unit : cm

end

