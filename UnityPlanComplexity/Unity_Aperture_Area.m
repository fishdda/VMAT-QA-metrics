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
        mlc_leaf = reshape(CPS{k,4},[size(CPS{k,4},1)/2,2]);
        xjaw = CPS{k,3};
        seg_area = 0;
        
        % determine start and end point
%         half_leaf_pair = size(mlc_leaf,1)/2*mlc_width;
        start_point = find(CPS{k,5} == xjaw(1));
        end_point = find(CPS{k,5} == xjaw(2));
        fprintf("start_point is %dth jaws & end_point is %dth jaws\n",start_point,end_point);
        
        % calculate segment area
        for j = start_point:end_point
             seg_area =  seg_area + (mlc_leaf(j,2)-mlc_leaf(j,1))*mlc_width/100;
        end
        
        Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{k,6} = seg_area; % to save segment area in column 6
    end
end

end