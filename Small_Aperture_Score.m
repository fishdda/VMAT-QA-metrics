function VMAT_PLN_INFO = Small_Aperture_Score(VMAT_PLN_INFO,BLD_type)

% the proportion of open leaf pairs that were separated by less than a given threshold distance 
% doi: https://doi.org/10.1088/0031-9155/60/6/2587

% given threshold distance should be less than 5mm, 10mm, 20mm
D_thres = [5,10,20]; 
VMAT_PLN_INFO.SAS.Distance_05 = zeros(VMAT_PLN_INFO.Total_CPs,1);
VMAT_PLN_INFO.SAS.Distance_10 = zeros(VMAT_PLN_INFO.Total_CPs,1);
VMAT_PLN_INFO.SAS.Distance_20 = zeros(VMAT_PLN_INFO.Total_CPs,1);

if BLD_type == 'agility'
    closed_leaf_distance = 1.7-(-1.7); % specific for agility
elseif BLD_type == 'mlci' || BLD_type == 'mlci2'
    closed_leaf_distance = 5;
end

for jj = 1:VMAT_PLN_INFO.Total_CPs
    
    MLC = reshape(VMAT_PLN_INFO.CP_info{jj, 3},[80,2]);
    Dis_leaf = MLC(:,2)-MLC(:,1);
    count1 = 0;count2 = 0;count3 = 0;
    for kk =1:length(Dis_leaf)
        if Dis_leaf(kk) > closed_leaf_distance && Dis_leaf(kk) < D_thres(1)
            count1 = count1 + 1;
        elseif Dis_leaf(kk) > closed_leaf_distance && Dis_leaf(kk) < D_thres(2)
            count2 = count2 + 1;
        elseif Dis_leaf(kk) > closed_leaf_distance && Dis_leaf(kk) < D_thres(3)
            count3 = count3 + 1;
        end
    end
    VMAT_PLN_INFO.SAS.Distance_05(jj) = count1/length(Dis_leaf);
    VMAT_PLN_INFO.SAS.Distance_10(jj) = count2/length(Dis_leaf);
    VMAT_PLN_INFO.SAS.Distance_20(jj) = count3/length(Dis_leaf);
end


end

