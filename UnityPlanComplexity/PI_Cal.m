function Unity_PLN_INFO = PI_Cal(Unity_PLN_INFO)
%PI_Cal: This function was mainly used for calculate plan irregularities
% 
num_adapt = size(fieldnames(Unity_PLN_INFO),1);
nam_adapt = fieldnames(Unity_PLN_INFO);
for jj = 1:num_adapt  
    Unity_PLN_INFO.(nam_adapt{jj}).AI = (cell2mat(Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_(:,7))).^2./(4*pi*cell2mat(Unity_PLN_INFO.(nam_adapt{1}).CP_info_unity_(:,6))); 
    % gantry angles
    G_angles = cell2mat(Unity_PLN_INFO.Unity_10FIMRTApp.CP_info_unity_(:,1));
    G_angles_uni = unique(cell2mat(Unity_PLN_INFO.Unity_10FIMRTApp.CP_info_unity_(:,1)));
    Unity_PLN_INFO.(nam_adapt{jj}).PI = 0;
    for kk = 1:length(G_angles_uni)
        flag = G_angles == G_angles_uni(kk);
        ele = sum(flag.*cell2mat(Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_(:,2)).*Unity_PLN_INFO.(nam_adapt{jj}).AI)/Unity_PLN_INFO.(nam_adapt{jj}).Beam_MU(kk);
        Unity_PLN_INFO.(nam_adapt{jj}).PI = Unity_PLN_INFO.(nam_adapt{jj}).PI + ele*Unity_PLN_INFO.(nam_adapt{jj}).Beam_MU(kk)/Unity_PLN_INFO.(nam_adapt{jj}).Total_MU;
    end
end




end

