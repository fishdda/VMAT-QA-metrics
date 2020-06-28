function VMAT_PLN_INFO = Aperture_Perimeter(VMAT_PLN_INFO,BLD_type)

% Aperture_Perimeter.m : calculate the perimeter of each control point
% doi: http://dx.doi.org/10.1118/1.4861821

seg_perimeter = zeros(VMAT_PLN_INFO.Total_CPs,1);
for k= 1:length(seg_perimeter)
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
            
            % calculate segment perimeter
            for j = start_point:end_point
                
                X_leaf_ends = 2*mlc_width/10; % determine x axis leaf width
                
                if j == start_point
                    
                    Y_leaf_ends = abs(mlc_leaf(j,2)-mlc_leaf(j,1))/10;
                    
                elseif j == end_point
                    
                    Y_leaf_ends = abs(mlc_leaf(j,2)-mlc_leaf(j,1))/10 + ...
                        abs(mlc_leaf(j,2)-mlc_leaf(j-1,2))/10 + ...
                        abs(mlc_leaf(j,1)-mlc_leaf(j-1,1))/10;
                    
                else
                    
                    Y_leaf_ends =  abs(mlc_leaf(j,2)-mlc_leaf(j-1,2))/10 + ...
                        abs(mlc_leaf(j,1)-mlc_leaf(j-1,1))/10;
                    
                end
                
                seg_perimeter(k) =  seg_perimeter(k) + X_leaf_ends + Y_leaf_ends; % change the parameters
            end
            
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) == 0
            % calculate segment perimeter
            start_point = floor((200+yjaw(1))/mlc_width)+1;
            first_width = mlc_width - mod(200+yjaw(1),mlc_width); % first leaf should be only 2mm width
            seg_perimeter(k) = seg_perimeter(k) + (mlc_leaf(start_point,2)-mlc_leaf(start_point,1))/10 + 2*first_width/10; 
            % calculate segment perimeter
            for j = start_point+1:end_point
                
                X_leaf_ends = 2*mlc_width/10; % determine x axis leaf width
                
                if j == start_point
                    
                    continue;
                  
%                   Y_leaf_ends = abs(mlc_leaf(j,2)-mlc_leaf(j,1))/10;
                    
                elseif j == end_point
                    
                    Y_leaf_ends = abs(mlc_leaf(j,2)-mlc_leaf(j,1))/10 + ...
                        abs(mlc_leaf(j,2)-mlc_leaf(j-1,2))/10 + ...
                        abs(mlc_leaf(j,1)-mlc_leaf(j-1,1))/10;
                    
                else
                    
                    Y_leaf_ends =  abs(mlc_leaf(j,2)-mlc_leaf(j-1,2))/10 + ...
                        abs(mlc_leaf(j,1)-mlc_leaf(j-1,1))/10;
                    
                end
                
                seg_perimeter(k) =  seg_perimeter(k) + X_leaf_ends + Y_leaf_ends; % change the parameters
            end
            
        elseif rem(start_point,1) == 0 && rem(end_point,1) ~= 0
            
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            last_width = mod(yjaw(2),mlc_width); % e.g. last leaf should be only 2mm width

            seg_perimeter(k) = seg_perimeter(k) + (mlc_leaf(end_point+1,2)-mlc_leaf(end_point+1,1))/10 + 2*last_width/10;
            
            % calculate segment perimeter
            for j = start_point:end_point
                
                X_leaf_ends = 2*mlc_width/10; % determine x axis leaf width
                
                if j == start_point
                    
                    Y_leaf_ends = abs(mlc_leaf(j,2)-mlc_leaf(j,1))/10;
                    
                elseif j == end_point
                    
                    continue;
                    
%                     Y_leaf_ends = abs(mlc_leaf(j,2)-mlc_leaf(j,1))/10 + ...
%                         abs(mlc_leaf(j,2)-mlc_leaf(j-1,2))/10 + ...
%                         abs(mlc_leaf(j,1)-mlc_leaf(j-1,1))/10;
                    
                else
                    
                    Y_leaf_ends =  abs(mlc_leaf(j,2)-mlc_leaf(j-1,2))/10 + ...
                        abs(mlc_leaf(j,1)-mlc_leaf(j-1,1))/10;
                    
                end
                
                seg_perimeter(k) =  seg_perimeter(k) + X_leaf_ends + Y_leaf_ends; % change the parameters
            end
            
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0

            start_point = floor((200+yjaw(1))/mlc_width)+1;
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            last_width = mod(yjaw(2),mlc_width); % first leaf should be only 2mm width
            first_width = mlc_width - mod(200+yjaw(1),mlc_width); % first leaf should be only 2mm width
            
            seg_perimeter(k) = seg_perimeter(k) + (mlc_leaf(start_point,2)-mlc_leaf(start_point,1))/10 + 2*first_width/10;
            seg_perimeter(k) = seg_perimeter(k) + (mlc_leaf(end_point+1,2)-mlc_leaf(end_point+1,1))/10 + 2*last_width/10;
            
            % calculate segment perimeter
            for j = start_point+1:end_point
                
                X_leaf_ends = 2*mlc_width/10; % determine x axis leaf width
                
                if j == start_point
                    
                    continue;
                    
%                     Y_leaf_ends = abs(mlc_leaf(j,2)-mlc_leaf(j,1))/10;
                    
                elseif j == end_point
                    
                    continue;
                    
%                     Y_leaf_ends = abs(mlc_leaf(j,2)-mlc_leaf(j,1))/10 + ...
%                         abs(mlc_leaf(j,2)-mlc_leaf(j-1,2))/10 + ...
%                         abs(mlc_leaf(j,1)-mlc_leaf(j-1,1))/10;
                    
                else
                    
                    Y_leaf_ends =  abs(mlc_leaf(j,2)-mlc_leaf(j-1,2))/10 + ...
                        abs(mlc_leaf(j,1)-mlc_leaf(j-1,1))/10;
                    
                end
                
                seg_perimeter(k) =  seg_perimeter(k) + X_leaf_ends + Y_leaf_ends; % change the parameters
            end
            disp('rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0');
            fprintf('perimeter for %dth control point is %f cm',k,seg_perimeter(k));
            
        end


end
VMAT_PLN_INFO.AP= seg_perimeter; 
end
