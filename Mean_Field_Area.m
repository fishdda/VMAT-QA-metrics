function VMAT_PLN_INFO = Mean_Field_Area(VMAT_PLN_INFO)
%Mean_Field_Area (MFA)
%   The metric calculated the average weighted field area
%   MFA = sum(aperture*weight)

weighted_MU = VMAT_PLN_INFO.CP_info(:,2);
for i=1:length(weighted_MU)-1
    MU_weight(i) =  (weighted_MU{i+1,1} - weighted_MU{i,1})/VMAT_PLN_INFO.Total_MU;
end
aperture_area = cell2mat(VMAT_PLN_INFO.CP_info(2:end,5)); % extract aperture area

VMAT_PLN_INFO.MFA = sum(aperture_area.*MU_weight');

end

