function VMAT_PLN_INFO = Edge_Metric(VMAT_PLN_INFO,BLD_type)
%Edge_Metric quantifies the amount of "edge" in the aperture.
% doi: http://dx.doi.org/10.1118/1.4762566

%% calculate the MU weights
weighted_MU = VMAT_PLN_INFO.CP_info(:,2);
for i=1:length(weighted_MU)-1
    MU_weight(i) =  (weighted_MU{i+1,1} - weighted_MU{i,1})/VMAT_PLN_INFO.Total_MU;
end

scaling_factor1 = 0.4;
scaling_factor2 = 0.6;

Edge_Metrics = zeros(length(MU_weight),1);

for k= 1:length(MU_weight)
    % segment serial number
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
            mlc_leaf = reshape(VMAT_PLN_INFO.CP_info{k, 3},[size(VMAT_PLN_INFO.CP_info{k, 3},1)/2,2]);
            yjaw = VMAT_PLN_INFO.CP_info{k, 4};  
        end
        
        start_point = ((200+yjaw(1))/mlc_width)+1;
        end_point = size(mlc_leaf,1)-(200-yjaw(2))/mlc_width;
        
        if rem(start_point,1) == 0 && rem(end_point,1) == 0
            
            % calculate segment edge metrics           
            X_end = mlc_width*length(start_point:end_point);
            Y_end = VMAT_PLN_INFO.AP(k+1) - X_end;
            Edge_Metrics(k) = X_end*scaling_factor1 + Y_end*scaling_factor2;
            
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) == 0
            % calculate segment area
            start_point = floor((200+yjaw(1))/mlc_width)+1;
            X_end = mlc_width*length(start_point+1:end_point);
            Y_end = VMAT_PLN_INFO.AP(k+1) - X_end;
            Edge_Metrics(k) = X_end*scaling_factor1 + Y_end*scaling_factor2;
            
        elseif rem(start_point,1) == 0 && rem(end_point,1) ~= 0
            
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            X_end = mlc_width*length(start_point:end_point);
            Y_end = VMAT_PLN_INFO.AP(k+1) - X_end;
            Edge_Metrics(k) = X_end*scaling_factor1 + Y_end*scaling_factor2;
            
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0

            start_point = floor((200+yjaw(1))/mlc_width)+1;
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            X_end = mlc_width*length(start_point:end_point);
            Y_end = VMAT_PLN_INFO.AP(k+1) - X_end;
            Edge_Metrics(k) = X_end*scaling_factor1 + Y_end*scaling_factor2;
            
        end



end

VMAT_PLN_INFO.EM = sum(Edge_Metrics.*MU_weight'./VMAT_PLN_INFO.AA(2:end));

end

