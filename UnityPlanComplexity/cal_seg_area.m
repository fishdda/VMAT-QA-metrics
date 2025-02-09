function seg_area = cal_seg_area(plan_path,mlc_width,machine_type)
%
% notes: number of mlc leaf: 160 agility
% plan_path = 'C:\Users\xhuae08006\Downloads\003_stepshootAP.dcm';
% mlc_width = 5; % mlc width = 5mm


plan_info = dicominfo(plan_path);
beam_num = fieldnames(plan_info.BeamSequence);
seg_num = zeros(size(beam_num,1),1);
for j=1:size(beam_num,1)
    eval(['seg_num(j) = size(fieldnames(plan_info.BeamSequence.Item_',int2str(j),...
        '.ControlPointSequence),1)/2;'])    
end

seg_area = zeros(size(beam_num,1),max(seg_num));

for k= 1:length(seg_num)
    % kth beam
    for i=1:seg_num(k)
        if machine_type == 'synergy'
            eval(['mlc_leaf = plan_info.BeamSequence.Item_',int2str(k),...
                '.ControlPointSequence.Item_',int2str(2*i-1),...
                '.BeamLimitingDevicePositionSequence.Item_3.LeafJawPositions;'])
        % ith segments 
    %         eval(['mlc_leaf = plan_info.BeamSequence.Item_',int2str(k),...
    %             '.ControlPointSequence.Item_',int2str(2*i-1),...
    %             '.BeamLimitingDevicePositionSequence.Item_2.LeafJawPositions;'])

            mlc_leaf = reshape(mlc_leaf,[size(mlc_leaf,1)/2,2]);
    %         eval(['yjaw = plan_info.BeamSequence.Item_',int2str(k),...
    %             '.ControlPointSequence.Item_',int2str(2*i-1),...
    %             '.BeamLimitingDevicePositionSequence.Item_1.LeafJawPositions;'])
            eval(['yjaw = plan_info.BeamSequence.Item_',int2str(k),...
                '.ControlPointSequence.Item_',int2str(2*i-1),...
                '.BeamLimitingDevicePositionSequence.Item_2.LeafJawPositions;'])
        elseif machine_type == 'agility'
            eval(['mlc_leaf = plan_info.BeamSequence.Item_',int2str(k),...
                '.ControlPointSequence.Item_',int2str(2*i-1),...
                '.BeamLimitingDevicePositionSequence.Item_2.LeafJawPositions;'])  
            mlc_leaf = reshape(mlc_leaf,[size(mlc_leaf,1)/2,2]);
            eval(['yjaw = plan_info.BeamSequence.Item_',int2str(k),...
                '.ControlPointSequence.Item_',int2str(2*i-1),...
                '.BeamLimitingDevicePositionSequence.Item_1.LeafJawPositions;'])
        end
        
        start_point = ((200+yjaw(1))/mlc_width)+1;
        end_point = size(mlc_leaf,1)-(200-yjaw(2))/mlc_width;
        if rem(start_point,1) == 0 && rem(end_point,1) == 0
            % calculate segment area
            for j = start_point:end_point
                 seg_area(k,i) =  seg_area(k,i) + (mlc_leaf(j,2)-mlc_leaf(j,1))*mlc_width/100;
            end
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) == 0
            % calculate segment area
            start_point = floor((200+yjaw(1))/mlc_width)+1;
            first_width = mlc_width - mod(200+yjaw(1),mlc_width); % first leaf should be only 2mm width
            seg_area(k,i) = seg_area(k,i) + (mlc_leaf(start_point,2)-mlc_leaf(start_point,1))*first_width/100;
            for j = start_point+1:end_point
                 seg_area(k,i) =  seg_area(k,i) + (mlc_leaf(j,2)-mlc_leaf(j,1))*mlc_width/100;   
            end
%             disp('rem(start_point,1) ~= 0 && rem(end_point,1) == 0');
%             disp([k,i]);
        elseif rem(start_point,1) == 0 && rem(end_point,1) ~= 0
            
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            last_width = mod(yjaw(2),mlc_width); % first leaf should be only 2mm width
            disp(end_point+1)
            seg_area(k,i) = seg_area(k,i) + (mlc_leaf(end_point+1,2)-mlc_leaf(end_point+1,1))*last_width/100;
            for j = start_point:end_point
                 seg_area(k,i) =  seg_area(k,i) + (mlc_leaf(j,2)-mlc_leaf(j,1))*mlc_width/100;   
            end
%             disp('rem(start_point,1) == 0 && rem(end_point,1) ~= 0');
%             disp([k,i]);
%             disp(seg_area(k,i));
            
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0

            start_point = floor((200+yjaw(1))/mlc_width)+1;
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            last_width = mod(yjaw(2),mlc_width); % first leaf should be only 2mm width
            first_width = mlc_width - mod(200+yjaw(1),mlc_width); % first leaf should be only 2mm width
            
            seg_area(k,i) = seg_area(k,i) + (mlc_leaf(start_point,2)-mlc_leaf(start_point,1))*first_width/100;
            seg_area(k,i) = seg_area(k,i) + (mlc_leaf(end_point+1,2)-mlc_leaf(end_point+1,1))*last_width/100;
            for j = start_point+1:end_point
                 seg_area(k,i) =  seg_area(k,i) + (mlc_leaf(j,2)-mlc_leaf(j,1))*mlc_width/100;   
            end
            disp('rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0');
            disp([k,i]);
            disp(seg_area(k,i));
            

        end
            
    end
end
end