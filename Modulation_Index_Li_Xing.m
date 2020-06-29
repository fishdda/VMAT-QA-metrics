function VMAT_PLN_INFO = Modulation_Index_Li_Xing(VMAT_PLN_INFO)
%Modulation_Index_Li_Xing: calculate a modulation index for VMAT treatment
%planning and this method was quoted from Xing Lei's paper
%    https://doi.org/10.1118/1.4802748

% determine the neighbouring num of CPs
K = 10; % default number
iteration = [-K:-1,1:K];
MI = zeros(VMAT_PLN_INFO.Total_CPs,length(iteration));
for s = 1:size(MI,1)
    for j =1:length(iteration)
        if s+K(j) > 0 
        factor = abs((VMAT_PLN_INFO.CP_info{s,2}-...
            VMAT_PLN_INFO.CP_info{s+K(j),2})/(VMAT_PLN_INFO.CP_info{s,1}-...
            VMAT_PLN_INFO.CP_info{s+K(j),1}));
        mlc = VMAT_PLN_INFO.CP_info{s,3}; % mlc position leaf a and leaf b
        mlc_k = VMAT_PLN_INFO.CP_info{s+K(j),3}; % mlc position leaf a and leaf b
        MI(s,j) = sum(abs(mlc-mlc_k))*factor;
    end
end


end

