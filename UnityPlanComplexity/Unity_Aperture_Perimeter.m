function Unity_PLN_INFO = Unity_Aperture_Perimeter(Unity_PLN_INFO)
% Unity_Aperture_Perimeter.m : calculate the perimeter of each control point
% doi: http://dx.doi.org/10.1118/1.4861821

num_adapt = size(fieldnames(Unity_PLN_INFO),1);
nam_adapt = fieldnames(Unity_PLN_INFO);
mlc_width = 7; %7mm mlc width for unity

for jj = 1:num_adapt
    % iterate number of adaption
    CPS = Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_;
    
    for k= 1:size(CPS,1)
        mlc_leaf = reshape(CPS{k,4},[size(CPS{k,4},1)/2,2]);
        xjaw = CPS{k,3};
        seg_perimeter = 0;
        
        % determine the first leaf positions and last leaf positions
%         half_leaf_pair = size(mlc_leaf,1)/2*mlc_width;
        start_point = find(CPS{k,5} == xjaw(1));
        end_point = find(CPS{k,5} == xjaw(2));
%         start_point = floor((half_leaf_pair+xjaw(1))/mlc_width)+1;
%         end_point = size(mlc_leaf,1)/2 + floor(xjaw(2)/mlc_width);
            
            % calculate segment perimeter
        for j = start_point:end_point+1

            X_leaf_ends = 2*mlc_width/10; % determine x axis leaf width

            if j == start_point

                Y_leaf_ends = abs(mlc_leaf(j,2)-mlc_leaf(j,1))/10;
                fprintf("This is %d th\n",j);
                fprintf("The Y_leaf_ends is %f cm\n",Y_leaf_ends);        

            elseif j == end_point+1

                Y_leaf_ends = abs(mlc_leaf(j,2)-mlc_leaf(j,1))/10;
                fprintf("This is %d th",j);
                fprintf("The Y_leaf_ends is %f cm\n",Y_leaf_ends);

            else

                Y_leaf_ends =  abs(mlc_leaf(j,2)-mlc_leaf(j-1,2))/10 + ...
                    abs(mlc_leaf(j,1)-mlc_leaf(j-1,1))/10;
                fprintf("This is %d th",j);

                % consider interdigitation leaves for certain aperture
                if mlc_leaf(j-1,1) > mlc_leaf(j,2) 
                    fprintf('This is %d th leaf pair is interdigitation \n',j);
                    fprintf("The distance for interdigitation: %f cm\n",abs(mlc_leaf(j-1,1)-mlc_leaf(j,2))/10);

                    Y_leaf_ends = Y_leaf_ends - 2*abs(mlc_leaf(j-1,1)-mlc_leaf(j,2))/10;
%                         fprintf("after interdigitation Y_leaf_ends: %f cm\n",Y_leaf_ends);
                elseif mlc_leaf(j-1,2) < mlc_leaf(j,1)
                    fprintf('This is %d th leaf pair is interdigitation \n',j);
                    fprintf("The distance for interdigitation: %f cm\n",abs(mlc_leaf(j-1,2)-mlc_leaf(j,1))/10);

                    Y_leaf_ends = Y_leaf_ends - 2*abs(mlc_leaf(j,1)-mlc_leaf(j-1,2))/10;        
%                         fprintf("after interdigitation Y_leaf_ends: %f cm\n",Y_leaf_ends);
                end
                fprintf("The Y_leaf_ends is %f cm\n",Y_leaf_ends);                    
            end

            seg_perimeter =  seg_perimeter + X_leaf_ends + Y_leaf_ends; % change the parameters
        end    
        Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{k,7} = seg_perimeter;
    end
        
end
end

