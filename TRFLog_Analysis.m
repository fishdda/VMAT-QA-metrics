function [outputArg1,outputArg2] = TRFLog_Analysis(TRF_DATA,VMAT_PLN_INFO)
%TRFLog_Analysis 
% This TRF log analysis tool was used to analysis the csv file transfered
% from trf generated via Elekta Linac Integrity. 
num_leaf_pair = 80;

%% load TRF_DATA and cleaning the data
load C:\GitFolder\VMAT-QA-metrics\example\test_case\VMAT1Arc\VMAT202003181Arc.mat;
Log_TRF = VMAT202003181Arctable;
for i=1:num_leaf_pair
    Y1{1,i} = ['Y1Leaf',int2str(i),'ScaledActualmm'];
    Y2{1,i} = ['Y2Leaf',int2str(i),'ScaledActualmm'];
end

inf_ = {'VarName1','LinacStateActualValueNone',...
        'StepGantryScaledActualdeg',...
        'ActualDoseRateActualValueMumin',...
        'StepDoseActualValueMu'};
    
for jj = 1:VMAT_PLN_INFO.Total_CPs-1    
    eval(['VMAT_PLN_INFO.TRF.CP',int2str(jj),...
        '= Log_TRF(Log_TRF.ControlpointActualValueNone == jj & Log_TRF.LinacStateActualValueNone == ''Radiation On'',{inf_{:},Y1{:},Y2{:}});']);
    
    eval(['delta_time = VMAT_PLN_INFO.TRF.CP',int2str(jj),'.VarName1(end)-VMAT_PLN_INFO.TRF.CP',int2str(jj),'.VarName1(1);'])
    eval(['VMAT_PLN_INFO.TRF_Gantry_Speed(jj) = (VMAT_PLN_INFO.TRF.CP',int2str(jj),'.StepGantryScaledActualdeg(end)-'...
        'VMAT_PLN_INFO.TRF.CP',int2str(jj),'.StepGantryScaledActualdeg(1))/delta_time;'])
%     VMAT_PLN_INFO.TRF_MLC_Speed(jj) = VMAT_PLN_INFO.TRF.CP1.;
    eval(['VMAT_PLN_INFO.TRF_Differential_MU(jj) = VMAT_PLN_INFO.TRF.CP',int2str(jj),...
        '.StepDoseActualValueMu(end)-VMAT_PLN_INFO.TRF.CP',int2str(jj),'.StepDoseActualValueMu(1);']);
end

PLAN_MU = VMAT_PLN_INFO.CP_info(:,2);
for i=1:size(PLAN_MU,1)-1
    PLAN_MU_(i) =  PLAN_MU{i+1,1} - PLAN_MU{i,1};
end

figure; 
plot(1:length(PLAN_MU_),PLAN_MU_,'b-');
hold on; 
plot(1:length(Machine_MU),Machine_MU,'r-');
hold on;
plot(1:length(Machine_MU),Machine_MU-PLAN_MU_,'g--');
xlabel('number of control points ');
ylabel('differential MU');
legend('PLAN MU','MACHINE MU','Error');
grid on;

figure; 
plot(1:length(PLN_Gantry_Speed),PLN_Gantry_Speed,'b-');
hold on; 
plot(1:length(TRF_Gantry_Speed),TRF_Gantry_Speed,'r-');
hold on;
plot(1:length(PLN_Gantry_Speed),TRF_Gantry_Speed-PLN_Gantry_Speed,'g--');
xlabel('number of control points ');
ylabel('Gantry Speed (deg/s)');
legend('PLAN Speed','MACHINE Speed','Speed Error');
grid on;








end

