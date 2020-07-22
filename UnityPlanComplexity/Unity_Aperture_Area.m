function Unity_PLN_INFO = Unity_Aperture_Area(Unity_PLN_INFO)
%Unity_Aperture_Area calculate the aperture area in Unity Step&Shoot Delivery
%Methods. Note: MLC direction is Y, Diaphgram direction is X. MLC width =
%7mm.

num_adapt = size(fieldnames(Unity_PLN_INFO),1);
nam_adapt = fieldnames(Unity_PLN_INFO);
mlc_width = 7; %7mm mlc width for unity
for jj = 1:num_adapt
    CPS = Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_;
    for k = 1:size(CPS,1)
        seg_area = 0;
        mlc_leaf = reshape(CPS{k,4},[size(CPS{k,4},1)/2,2]);
        xjaw = CPS{k,3};
        start_point = ((280+xjaw(1))/mlc_width)+1;
        end_point = size(mlc_leaf,1)-(280-xjaw(2))/mlc_width;
        if rem(start_point,1) == 0 && rem(end_point,1) == 0
            % calculate segment area
            for j = start_point:end_point
                 seg_area =  seg_area + (mlc_leaf(j,2)-mlc_leaf(j,1))*mlc_width/100;
            end
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) == 0
            % calculate segment area
            start_point = floor((280+xjaw(1))/mlc_width)+1;
            first_width = mlc_width - mod(280+xjaw(1),mlc_width); % first leaf should be only 2mm width
            seg_area = seg_area + (mlc_leaf(start_point,2)-mlc_leaf(start_point,1))*first_width/100;
            for j = start_point+1:end_point
                 seg_area =  seg_area + (mlc_leaf(j,2)-mlc_leaf(j,1))*mlc_width/100;   
            end
%             disp('rem(start_point,1) ~= 0 && rem(end_point,1) == 0');
%             disp([k,i]);
        elseif rem(start_point,1) == 0 && rem(end_point,1) ~= 0
            
            end_point = size(mlc_leaf,1)/2 + floor(xjaw(2)/mlc_width);
            last_width = mod(xjaw(2),mlc_width); % first leaf should be only 2mm width
            disp(end_point+1)
            seg_area = seg_area + (mlc_leaf(end_point+1,2)-mlc_leaf(end_point+1,1))*last_width/100;
            for j = start_point:end_point
                 seg_area =  seg_area + (mlc_leaf(j,2)-mlc_leaf(j,1))*mlc_width/100;   
            end
%             disp('rem(start_point,1) == 0 && rem(end_point,1) ~= 0');
%             disp([k,i]);
%             disp(seg_area);
            
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0

            start_point = floor((280+xjaw(1))/mlc_width)+1;
            end_point = size(mlc_leaf,1)/2 + floor(xjaw(2)/mlc_width);
            last_width = mod(xjaw(2),mlc_width); % first leaf should be only 2mm width
            first_width = mlc_width - mod(280+xjaw(1),mlc_width); % first leaf should be only 2mm width
            
            seg_area = seg_area + (mlc_leaf(start_point,2)-mlc_leaf(start_point,1))*first_width/100;
            seg_area = seg_area + (mlc_leaf(end_point+1,2)-mlc_leaf(end_point+1,1))*last_width/100;
            for j = start_point+1:end_point
                 seg_area =  seg_area + (mlc_leaf(j,2)-mlc_leaf(j,1))*mlc_width/100;   
            end
            disp('rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0');
            disp([k,i]);
            disp(seg_area);
            

        end
        
        Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{k,6} = seg_area; % to save segment area in column 6
    end
end

end


