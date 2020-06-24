function VMAT_PLN_INFO = Aperture_Area(VMAT_PLN_INFO,BLD_type)
%
% notes: number of mlc leaf: 160 agility

seg_area = zeros(VMAT_PLN_INFO.Total_CPs,1);
for k= 1:length(seg_area)
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
            % calculate segment area
            for j = start_point:end_point
                 seg_area(k) =  seg_area(k) + (mlc_leaf(j,2)-mlc_leaf(j,1))*mlc_width/100;
            end
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) == 0
            % calculate segment area
            start_point = floor((200+yjaw(1))/mlc_width)+1;
            first_width = mlc_width - mod(200+yjaw(1),mlc_width); % first leaf should be only 2mm width
            seg_area(k) = seg_area(k) + (mlc_leaf(start_point,2)-mlc_leaf(start_point,1))*first_width/100;
            for j = start_point+1:end_point
                 seg_area(k) =  seg_area(k) + (mlc_leaf(j,2)-mlc_leaf(j,1))*mlc_width/100;   
            end
%             disp('rem(start_point,1) ~= 0 && rem(end_point,1) == 0');
%             disp([k,i]);
        elseif rem(start_point,1) == 0 && rem(end_point,1) ~= 0
            
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            last_width = mod(yjaw(2),mlc_width); % first leaf should be only 2mm width
            disp(end_point+1)
            seg_area(k) = seg_area(k) + (mlc_leaf(end_point+1,2)-mlc_leaf(end_point+1,1))*last_width/100;
            for j = start_point:end_point
                 seg_area(k) =  seg_area(k) + (mlc_leaf(j,2)-mlc_leaf(j,1))*mlc_width/100;   
            end
            
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0

            start_point = floor((200+yjaw(1))/mlc_width)+1;
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            last_width = mod(yjaw(2),mlc_width); % first leaf should be only 2mm width
            first_width = mlc_width - mod(200+yjaw(1),mlc_width); % first leaf should be only 2mm width
            
            seg_area(k) = seg_area(k) + (mlc_leaf(start_point,2)-mlc_leaf(start_point,1))*first_width/100;
            seg_area(k) = seg_area(k) + (mlc_leaf(end_point+1,2)-mlc_leaf(end_point+1,1))*last_width/100;
            for j = start_point+1:end_point
                 seg_area(k) =  seg_area(k) + (mlc_leaf(j,2)-mlc_leaf(j,1))*mlc_width/100;   
            end
            disp('rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0');
            disp(seg_area(k));
            

        end

VMAT_PLN_INFO.CP_info{k,5} = seg_area(k);

end
end