function VMAT_PLN_INFO = Small_Aperture_Score(VMAT_PLN_INFO,BLD_type)

%   The small aperture score (SAS) was calculated as the ratio of open leaf
%   pairs where the aperture was less than a defined criteria (2, 5, 10 and
%   20 mm in this study) to all open leaf pairs. Note: the leaf pair should
%   not be positioned under the jaws.
%   doi: https://doi.org/10.1088/0031-9155/60/6/2587

% given threshold distance should be less than 5mm, 10mm, 20mm
D_thres = [2,5,10,20]; 
%% calculate the MU weights
weighted_MU = VMAT_PLN_INFO.CP_info(:,2);
for i=1:length(weighted_MU)-1
    MU_weight(i) =  (weighted_MU{i+1,1} - weighted_MU{i,1})/VMAT_PLN_INFO.Total_MU;
end

%% calculate SAS
SAS = zeros(VMAT_PLN_INFO.Total_CPs-1,4);
for k= 2:length(VMAT_PLN_INFO.Total_CPs)
    % segment serial number
        if BLD_type == 'agility'
            mlc_width = 5; % 5mm leaf width at isocenter
            mlc_leaf = reshape(VMAT_PLN_INFO.CP_info{k, 3},[size(VMAT_PLN_INFO.CP_info{k, 3},1)/2,2]);
            yjaw = VMAT_PLN_INFO.CP_info{k, 4};  
        end
        
        start_point = floor(((200+yjaw(1))/mlc_width)+1);
        end_point = ceil(size(mlc_leaf,1)-(200-yjaw(2))/mlc_width);
        N_1 = 0; N_2 = 0; N_3 = 0; N_4 = 0;
        for j = start_point:end_point
           if abs(mlc_leaf(j,2)-mlc_leaf(j,1))>3.4 && abs(mlc_leaf(j,2)-mlc_leaf(j,1))<D_thres(1)
               N_1 = N_1 + 1;
               disp('N1 appearance!!')
           elseif abs(mlc_leaf(j,2)-mlc_leaf(j,1))>3.4 && abs(mlc_leaf(j,2)-mlc_leaf(j,1))<D_thres(2)
               N_2 = N_2 + 1;
               disp('N2 appearance!!')
           elseif abs(mlc_leaf(j,2)-mlc_leaf(j,1))>3.4 && abs(mlc_leaf(j,2)-mlc_leaf(j,1))<D_thres(3)
               N_3 = N_3 + 1;
               disp('N3 appearance!!')
           elseif abs(mlc_leaf(j,2)-mlc_leaf(j,1))>3.4 && abs(mlc_leaf(j,2)-mlc_leaf(j,1))<D_thres(4)
               N_4 = N_4 + 1;
               disp('N4 appearance!!')
           end
        end
        
        SAS(k-1,1) = MU_weight(k-1)*N_1/(end_point-start_point+1);
        SAS(k-1,2) = MU_weight(k-1)*N_2/(end_point-start_point+1);
        SAS(k-1,3) = MU_weight(k-1)*N_3/(end_point-start_point+1);
        SAS(k-1,4) = MU_weight(k-1)*N_4/(end_point-start_point+1);

end

VMAT_PLN_INFO.SAS.Distance_02= sum(SAS(:,1));
VMAT_PLN_INFO.SAS.Distance_05= sum(SAS(:,2));
VMAT_PLN_INFO.SAS.Distance_10 = sum(SAS(:,3));
VMAT_PLN_INFO.SAS.Distance_20= sum(SAS(:,4));

end

