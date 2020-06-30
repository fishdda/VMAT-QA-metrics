function VMAT_PLN_INFO = MI_SPORT(VMAT_PLN_INFO)
%Modulation_Index_Li_Xing: calculate a modulation index for VMAT treatment
%planning and this method was quoted from Xing Lei's paper
%    https://doi.org/10.1118/1.4802748

%% calculate the MU weights
weighted_MU = VMAT_PLN_INFO.CP_info(:,2);
for i=1:length(weighted_MU)-1
    MU_weight(i) =  (weighted_MU{i+1,1} - weighted_MU{i,1})/VMAT_PLN_INFO.Total_MU;
end

%% K = 5
% determine the neighbouring num of CPs
K = 5; % default number
iteration = [-K:-1,1:K];
MI = zeros(VMAT_PLN_INFO.Total_CPs,length(iteration));
for s = 1:size(MI,1)
    for j =1:length(iteration)
        fprintf('This is %dth cp and %dth iteration \n ',s,j);
        if s+iteration(j) > 0 && s+ iteration(j) < size(MI,1)+1
            factor = abs((VMAT_PLN_INFO.CP_info{s,2}-...
                VMAT_PLN_INFO.CP_info{s+iteration(j),2})/(VMAT_PLN_INFO.CP_info{s,1}-...
                VMAT_PLN_INFO.CP_info{s+iteration(j),1}));
            mlc = VMAT_PLN_INFO.CP_info{s,3}; % mlc position leaf a and leaf b
            mlc_k = VMAT_PLN_INFO.CP_info{s+iteration(j),3}; % mlc position leaf a and leaf b
            MI(s,j) = sum(abs(mlc-mlc_k))*factor;
        else
            MI(s,j) = 0;
        end
    end
end

VMAT_PLN_INFO.MI_SPORT_K_05 = sum(MI,2);
VMAT_PLN_INFO.MI_SPORT_weighted_K_05 = sum(VMAT_PLN_INFO.MI_SPORT_K_05(2:end).*MU_weight');

%% K = 10
K = 10; % default number
iteration = [-K:-1,1:K];
MI = zeros(VMAT_PLN_INFO.Total_CPs,length(iteration));
for s = 1:size(MI,1)
    for j =1:length(iteration)
        fprintf('This is %dth cp and %dth iteration \n ',s,j);
        if s+iteration(j) > 0 && s+ iteration(j) < size(MI,1)+1
            factor = abs((VMAT_PLN_INFO.CP_info{s,2}-...
                VMAT_PLN_INFO.CP_info{s+iteration(j),2})/(VMAT_PLN_INFO.CP_info{s,1}-...
                VMAT_PLN_INFO.CP_info{s+iteration(j),1}));
            mlc = VMAT_PLN_INFO.CP_info{s,3}; % mlc position leaf a and leaf b
            mlc_k = VMAT_PLN_INFO.CP_info{s+iteration(j),3}; % mlc position leaf a and leaf b
            MI(s,j) = sum(abs(mlc-mlc_k))*factor;
        else
            MI(s,j) = 0;
        end
    end
end

VMAT_PLN_INFO.MI_SPORT_K_10 = sum(MI,2);
VMAT_PLN_INFO.MI_SPORT_weighted_K_10 = sum(VMAT_PLN_INFO.MI_SPORT_K_10(2:end).*MU_weight');

figure;
plot(1:length(VMAT_PLN_INFO.MI_SPORT_K_05),VMAT_PLN_INFO.MI_SPORT_K_05,'r-');
hold on;
plot(1:length(VMAT_PLN_INFO.MI_SPORT_K_10),VMAT_PLN_INFO.MI_SPORT_K_10,'b-');
xlabel('control point');
ylabel('Modulation Index (SPORT)');
legend('K = 5','K=10');

end

