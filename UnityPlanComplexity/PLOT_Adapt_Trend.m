function PLOT_Adapt_Trend(Unity_PLN_INFO)
%PLOT_TREND This script was used to plot the trend of adaptive plans
%   To show the difference between each adaptive plans 

%% Plot the change of PI and total MUs
num_adapt = size(fieldnames(Unity_PLN_INFO),1);
nam_adapt = fieldnames(Unity_PLN_INFO);
for jj = 1:num_adapt  
    PI(jj) = Unity_PLN_INFO.(nam_adapt{jj}).PI;
    MU(jj) = Unity_PLN_INFO.(nam_adapt{jj}).Total_MU;
end

%% plot Total MU changes and Plan complexities changes
figure;
names = fieldnames(Unity_PLN_INFO); Total_MUs = [];Plan_complexity = [];
fractions = 1:length(names);
for k = 1:length(names)
    eval(['Total_MUs =  [Total_MUs,Unity_PLN_INFO.',names{k,1},'.Total_MU];']);
    eval(['Plan_complexity =  [Plan_complexity,Unity_PLN_INFO.',names{k,1},'.PI];']);
end 
[hAxes,hBar,hLine] = plotyy(fractions,Total_MUs,fractions,Plan_complexity,'bar','plot')
set(hLine,'LineWidth',2,'Color',[0,0.7,0.7],'Marker','o')
set(gca,'XTickLabel',{'RePlan','ADT01','ADT02','ADT03','ADT04','ADT05'});
set(gca,'FontSize',10,'FontWeight','bold')    %对坐标轴字体大小和粗细更改
set(gcf,'color','white')
xlabel('Fractions');
ylabel(hAxes(1),'Total MU number');
ylabel(hAxes(2),'Plan Complexity Index');
title('Trend in Adaptive Workflow');

%% plot Total MU changes and Plan Aperture*MU changes
figure;
names = fieldnames(Unity_PLN_INFO); Total_MUs = [];Aperture_MU = [];
fractions = 1:length(names);
for k = 1:length(names)
    eval(['Total_MUs =  [Total_MUs,Unity_PLN_INFO.',names{k,1},'.Total_MU];']);
    eval(['Aperture_MU =  [Aperture_MU,Unity_PLN_INFO.',names{k,1},'.Aperture_MU];']);
end 
[hAxes,hBar,hLine] = plotyy(fractions,Total_MUs,fractions,Aperture_MU,'bar','plot')
set(hLine,'LineWidth',2,'Color',[0,0.7,0.7],'Marker','o')
set(gca,'XTickLabel',{'RePlan','ADT01','ADT02','ADT03','ADT04','ADT05'});
set(gca,'FontSize',10,'FontWeight','bold')    %对坐标轴字体大小和粗细更改
set(gcf,'color','white')
xlabel('Fractions');
ylabel(hAxes(1),'Total MU number');
ylabel(hAxes(2),'Aperture*MU');
title('Trend in Adaptive Workflow');





days = 0:5:35;
conc = [515,420,370,250,135,120,60,20]
temp = [29,23,27,25,20,23,23,27]
figure;
[hAxes,hBar,hLine] = plotyy(days,temp,days,conc,'bar','plot')

% 修改属性
set(hLine,'LineWidth',2,'Color',[0,0.7,0.7],'Marker','o')

title('Trend Chart for Concentration')
xlabel('Day')
ylabel(hAxes(1),'Temperature (^{o}C)')
ylabel(hAxes(2),'Concentration')









% plot the MU comparison of each gantry
Beam_MUs = [Unity_PLN_INFO.Unity_10FIMRTApp.Beam_MU',...
            Unity_PLN_INFO.Unity_10FIMRTAppADT01.Beam_MU',...
            Unity_PLN_INFO.Unity_10FIMRTAppADT02.Beam_MU',...
            Unity_PLN_INFO.Unity_10FIMRTAppADT03.Beam_MU',...
            Unity_PLN_INFO.Unity_10FIMRTAppADT04.Beam_MU',...
            Unity_PLN_INFO.Unity_10FIMRTAppADT05.Beam_MU'];
bar(Beam_MUs); 
Gantry_Angle = Unity_PLN_INFO.Unity_10FIMRTApp.Gantry_Angle;
for x=1:length(Gantry_Angle)
    gantry_name{1,x} = ['G',int2str(Gantry_Angle(x))];
end
set(gca,'XTickLabel',gantry_name);
 
set(gca,'FontSize',10,'FontWeight','bold')    %对坐标轴字体大小和粗细更改
set(gcf,'color','white')
xlabel('Gantry Angle');
ylabel('Total MU');
legend('Unity10FIMRTApp',...
       'Unity10FIMRTAppADT01',...
       'Unity10FIMRTAppADT02',...
       'Unity10FIMRTAppADT03',...
       'Unity10FIMRTAppADT04',...
       'Unity10FIMRTAppADT05');
title('203006 plans (Adapt to position).')



% plot the MU comparison 
Beam_MUs = [Unity_PLN_INFO.Unity_TEST1.Beam_MU',...
            Unity_PLN_INFO.Unity_TEST2.Beam_MU'];
bar(Beam_MUs); 
Gantry_Angle = Unity_PLN_INFO.Unity_TEST1.Gantry_Angle;
for x=1:length(Gantry_Angle)
    gantry_name{1,x} = ['G',int2str(Gantry_Angle(x))];
end
set(gca,'XTickLabel',gantry_name);
 
set(gca,'FontSize',10,'FontWeight','bold')    %对坐标轴字体大小和粗细更改
set(gcf,'color','white')
xlabel('Gantry Angle');
ylabel('Total MU');
legend('UnityPros3625U2',...
       'UnityPros3625U2ADT02');
title('Reoptimization in offline planning.')



end

 