function VMAT_PLN_INFO = Leaf_Sequence_Variability(VMAT_PLN_INFO,BLD_type)
%Leaf_Sequence_Variability characterize the variability in segment shape
%for a specific plan.
%   The shape of each segment is considered based on the change in leaf 
%   position between adjacent MLC leaves. This is calculated for leaves
%   on each bank that define a specific segment. The LSV is defined using
%   N, the number of open leaves constituting the beam and the coordinates
%   of the leaf positions (pos). Leaves are not considered if they are 
%   positioned under the jaws.


%% calculate the MU weights
weighted_MU = VMAT_PLN_INFO.CP_info(:,2);
for i=1:length(weighted_MU)-1
    MU_weight(i) =  (weighted_MU{i+1,1} - weighted_MU{i,1})/VMAT_PLN_INFO.Total_MU;
end

%% calculate LSV of each segment
LSV = zeros(VMAT_PLN_INFO.Total_CPs,1);
for k= 1:length(LSV)
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
            
            % determine the pos_max for each leaf bank
            pos_max_left = max(mlc_leaf(start_point:end_point,1))-min(mlc_leaf(start_point:end_point,1));
            pos_max_right =  max(mlc_leaf(start_point:end_point,2))-min(mlc_leaf(start_point:end_point,2));
            
            LSV_left = sum(pos_max_left*ones(length(mlc_leaf(start_point:end_point,1)),1)...
                -(mlc_leaf(start_point:end_point,1) - mlc_leaf(start_point+1:end_point+1,1)))...
                /(pos_max_left*length(mlc_leaf(start_point:end_point,1)));
            
            LSV_right = sum(pos_max_right*ones(length(mlc_leaf(start_point:end_point,2)),1)...
                -(mlc_leaf(start_point:end_point,2) - mlc_leaf(start_point+1:end_point+1,2)))...
                /(pos_max_right*length(mlc_leaf(start_point:end_point,2)));
            
            LSV(k) = LSV_left * LSV_right;
                        
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) == 0
            
            start_point = floor((200+yjaw(1))/mlc_width)+1;
            
            % determine the pos_max for each leaf bank
            pos_max_left = max(mlc_leaf(start_point+1:end_point,1))-min(mlc_leaf(start_point+1:end_point,1));
            pos_max_right =  max(mlc_leaf(start_point+1:end_point,2))-min(mlc_leaf(start_point+1:end_point,2));  

            
            LSV_left = sum(pos_max_left*ones(length(mlc_leaf(start_point+1:end_point,1)),1)...
                -(mlc_leaf(start_point+1:end_point,1) - mlc_leaf(start_point+2:end_point+1,1)))...
                /(pos_max_left*length(mlc_leaf(start_point+1:end_point,1)));
            
            LSV_right = sum(pos_max_right*ones(length(mlc_leaf(start_point+1:end_point,2)),1)...
                -(mlc_leaf(start_point+1:end_point,2) - mlc_leaf(start_point+2:end_point+1,2)))...
                /(pos_max_right*length(mlc_leaf(start_point+1:end_point,2)));
            
            LSV(k) = LSV_left * LSV_right;
            
        elseif rem(start_point,1) == 0 && rem(end_point,1) ~= 0
            
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            
            % determine the pos_max for each leaf bank
            pos_max_left = max(mlc_leaf(start_point:end_point,1))-min(mlc_leaf(start_point:end_point,1));
            pos_max_right =  max(mlc_leaf(start_point:end_point,2))-min(mlc_leaf(start_point:end_point,2));           
            

            LSV_left = sum(pos_max_left*ones(length(mlc_leaf(start_point:end_point,1)),1)...
                -(mlc_leaf(start_point:end_point,1) - mlc_leaf(start_point+1:end_point+1,1)))...
                /(pos_max_left*length(mlc_leaf(start_point:end_point,1)));
            
            LSV_right = sum(pos_max_right*ones(length(mlc_leaf(start_point:end_point,2)),1)...
                -(mlc_leaf(start_point:end_point,2) - mlc_leaf(start_point+1:end_point+1,2)))...
                /(pos_max_right*length(mlc_leaf(start_point:end_point,2)));
            
            LSV(k) = LSV_left * LSV_right;
            
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0
        
            start_point = floor((200+yjaw(1))/mlc_width)+1;
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            
            % determine the pos_max for each leaf bank
            pos_max_left = max(mlc_leaf(start_point+1:end_point,1))-min(mlc_leaf(start_point+1:end_point,1));
            pos_max_right =  max(mlc_leaf(start_point+1:end_point,2))-min(mlc_leaf(start_point+1:end_point,2));  
            
            LSV_left = sum(pos_max_left*ones(length(mlc_leaf(start_point+1:end_point,1)),1)...
                -(mlc_leaf(start_point+1:end_point,1) - mlc_leaf(start_point+2:end_point+1,1)))...
                /(pos_max_left*length(mlc_leaf(start_point+1:end_point,1)));
            
            LSV_right = sum(pos_max_right*ones(length(mlc_leaf(start_point+1:end_point,2)),1)...
                -(mlc_leaf(start_point+1:end_point,2) - mlc_leaf(start_point+2:end_point+1,2)))...
                /(pos_max_right*length(mlc_leaf(start_point+1:end_point,2)));
            
            LSV(k) = LSV_left * LSV_right;
            
        end


end

VMAT_PLN_INFO.LSV = LSV;

VMAT_PLN_INFO.LSV_weighted = sum(LSV(2:end).*MU_weight');
end

