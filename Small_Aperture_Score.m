function VMAT_PLN_INFO = Small_Aperture_Score(VMAT_PLN_INFO,BLD_type)

%   The small aperture score (SAS) was calculated as the ratio of open leaf
%   pairs where the aperture was less than a defined criteria (2, 5, 10 and
%   20 mm in this study) to all open leaf pairs. Note: the leaf pair should
%   not be positioned under the jaws.
%   doi: https://doi.org/10.1088/0031-9155/60/6/2587

%   This aperture metrics would have some issues because minimal leaf gap
%   should be 3.4 mm


% given threshold distance should be less than 5mm, 10mm, 20mm
D_thres = [2,5,10,20];  % unit (mm)
%% calculate the MU weights
weighted_MU = VMAT_PLN_INFO.CP_info(:,2);
for i=1:length(weighted_MU)-1
    MU_weight(i) =  (weighted_MU{i+1,1} - weighted_MU{i,1})/VMAT_PLN_INFO.Total_MU;
end

%% calculate SAS
SAS = zeros(VMAT_PLN_INFO.Total_CPs-1,4);
for k= 1:size(SAS,1)
    % segment serial number
        if BLD_type == 'synergy'
            mlc_leaf = reshape(mlc_leaf,[size(mlc_leaf,1)/2,2]);
            VMAT_PLN_INFO.CP_info{1, 3};
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
            
            % enumerate the leaf pair to calculate the threshold
            leaf_gap = mlc_leaf(start_point:end_point,2)-mlc_leaf(start_point:end_point,1);
            exposed_open_leaf_pairs = sum(leaf_gap > 0);
            for kk = 1:length(D_thres)
                small_aperture_leaf_pairs(kk) = length(leaf_gap(leaf_gap>0 & leaf_gap<D_thres(kk)));
                SAS(k,kk) = small_aperture_leaf_pairs(kk)/exposed_open_leaf_pairs;
            end
            
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) == 0

            start_point = floor((200+yjaw(1))/mlc_width)+1;
            % enumerate the leaf pair to calculate the threshold
            leaf_gap = mlc_leaf(start_point+1:end_point,2)-mlc_leaf(start_point+1:end_point,1);
            exposed_open_leaf_pairs = sum(leaf_gap > 0);
            for kk = 1:length(D_thres)
                small_aperture_leaf_pairs(kk) = length(leaf_gap(leaf_gap>0 & leaf_gap<D_thres(kk)));
                SAS(k,kk) = small_aperture_leaf_pairs(kk)/exposed_open_leaf_pairs;
            end

        elseif rem(start_point,1) == 0 && rem(end_point,1) ~= 0
            
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            % enumerate the leaf pair to calculate the threshold
            leaf_gap = mlc_leaf(start_point:end_point,2)-mlc_leaf(start_point:end_point,1);
            exposed_open_leaf_pairs = sum(leaf_gap > 0);
            for kk = 1:length(D_thres)
                small_aperture_leaf_pairs(kk) = length(leaf_gap(leaf_gap>0 & leaf_gap<D_thres(kk)));
                SAS(k,kk) = small_aperture_leaf_pairs(kk)/exposed_open_leaf_pairs;
            end
            
        elseif rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0

            start_point = floor((200+yjaw(1))/mlc_width)+1;
            end_point = size(mlc_leaf,1)/2 + floor(yjaw(2)/mlc_width);
            % enumerate the leaf pair to calculate the threshold
            leaf_gap = mlc_leaf(start_point+1:end_point,2)-mlc_leaf(start_point+1:end_point,1);
            exposed_open_leaf_pairs = sum(leaf_gap > 0);
            for kk = 1:length(D_thres)
                small_aperture_leaf_pairs(kk) = length(leaf_gap(leaf_gap>0 & leaf_gap<D_thres(kk)));
                SAS(k,kk) = small_aperture_leaf_pairs(kk)/exposed_open_leaf_pairs;
            end
            

        end


end

figure(1); histogram(SAS(:,1));title('SAS(D=2mm)');
figure(2); histogram(SAS(:,2));title('SAS(D=5mm)');
figure(3); histogram(SAS(:,3));title('SAS(D=10mm)');
figure(4); histogram(SAS(:,4));title('SAS(D=20mm)');


VMAT_PLN_INFO.SAS.Distance_02 = sum(SAS(:,1).*MU_weight');
VMAT_PLN_INFO.SAS.Distance_05 = sum(SAS(:,2).*MU_weight');
VMAT_PLN_INFO.SAS.Distance_10 = sum(SAS(:,3).*MU_weight');
VMAT_PLN_INFO.SAS.Distance_20 = sum(SAS(:,4).*MU_weight');



end





