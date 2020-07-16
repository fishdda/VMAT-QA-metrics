function PLOT_Adapt_Trend(Unity_PLN_INFO)
%PLOT_TREND This script was used to plot the trend of adaptive plans
%   To show the difference between each adaptive plans 

% Plot the change of PI and total MUs
num_adapt = size(fieldnames(Unity_PLN_INFO),1);
nam_adapt = fieldnames(Unity_PLN_INFO);
for jj = 1:num_adapt  
    PI(jj) = Unity_PLN_INFO.(nam_adapt{jj}).PI;
    MU(jj) = Unity_PLN_INFO.(nam_adapt{jj}).Total_MU;
end


Beam_MUs = [Unity_PLN_INFO.Unity_Pros3625U2.Beam_MU;];




end

