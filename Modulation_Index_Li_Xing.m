function VMAT_PLN_INFO = Modulation_Index_Li_Xing(VMAT_PLN_INFO)
%Modulation_Index_Li_Xing: calculate a modulation index for VMAT treatment
%planning and this method was quoted from Xing Lei's paper
%    https://doi.org/10.1118/1.4802748

% determine the neighbouring num of CPs
K = 10; % default number
iteration = [-K:-1,1:K];
MI = zeros(VMAT_PLN_INFO.Total_CPs,length(iteration));
for j =1:length(iteration)
    VMAT_PLN_INFO.CP_info(:,1) % gantry
    VMAT_PLN_INFO.CP_info(:,2) % cumulative mu
    for jj 
    VMAT_PLN_INFO.CP_info(:,3) % mlc position leaf a and leaf b
    
end

end

