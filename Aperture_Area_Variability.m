function VMAT_PLN_INFO = Aperture_Area_Variability(VMAT_PLN_INFO,BLD_type)
%Aperture_Area_Variability Calculate the aperture area variability of a treatment beam
%   The aperture area variability (AAV) is used to characterize the
%   variation in segment area relative to the maximum aperture defined
%   by all of the segments. Segments that are more similar in area to 
%   the maximum beam aperture contribute to a larger score.


AAV = zeros(VMAT_PLN_INFO.Total_CPs,1);
for k= 1:length(AAV)
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
            
            AAV(k) = sum(abs(mlc_leaf(start_point:end_point,1)-mlc_leaf(start_point:end_point,2)))/...
                (length(start_point:end_point)*max(abs(mlc_leaf(start_point:end_point,1)-mlc_leaf(start_point:end_point,2))));
                        
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) == 0

            start_point = floor((200+yjaw(1))/mlc_width)+1;
            
            AAV(k) = sum(abs(mlc_leaf(start_point+1:end_point,1)-mlc_leaf(start_point+1:end_point,2)))/...
                (length(start_point+1:end_point)*max(abs(mlc_leaf(start_point+1:end_point,1)-mlc_leaf(start_point+1:end_point,2))));
            
        elseif rem(start_point,1) == 0 && rem(end_point,1) ~= 0
            
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);

            AAV(k) = sum(abs(mlc_leaf(start_point:end_point,1)-mlc_leaf(start_point:end_point,2)))/...
                (length(start_point:end_point)*max(abs(mlc_leaf(start_point:end_point,1)-mlc_leaf(start_point:end_point,2))));
            
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0

            start_point = floor((200+yjaw(1))/mlc_width)+1;
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            
            AAV(k) = sum(abs(mlc_leaf(start_point+1:end_point,1)-mlc_leaf(start_point+1:end_point,2)))/...
                (length(start_point+1:end_point)*max(abs(mlc_leaf(start_point+1:end_point,1)-mlc_leaf(start_point+1:end_point,2))));
            
        end


end

VMAT_PLN_INFO.AAV = AAV;

end

