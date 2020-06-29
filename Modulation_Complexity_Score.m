function VMAT_PLN_INFO = Modulation_Complexity_Score(VMAT_PLN_INFO)
%Modulation_Complexity_Score 
%   the relative segment weight is also incorporated into the final
%   complexity score, with segments with a larger number of MU contributing
%   more to the MCS score. The weight is incorporated along with AAV and 
%   LSV into the MCS calculation. The MCSbeam is the product of the LSVsegment
%   and AAVsegment weighted by the relative MU of each segment in the beam

%   doi: http://dx.doi.org/10.1118/1.3276775
%% calculate the MU weights
weighted_MU = VMAT_PLN_INFO.CP_info(:,2);
for i=1:length(weighted_MU)-1
    MU_weight(i) =  (weighted_MU{i+1,1} - weighted_MU{i,1})/VMAT_PLN_INFO.Total_MU;
end

VMAT_PLN_INFO.MCS = sum(VMAT_PLN_INFO.AAV(2:end).*VMAT_PLN_INFO.LSV(2:end).*MU_weight');
end

