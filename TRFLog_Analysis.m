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
        'StepDoseActualValueMu',...
        'DlgY1ScaledActualmm',...
        'DlgY2ScaledActualmm',...
        'X1DiaphragmScaledActualmm',...
        'X2DiaphragmScaledActualmm'};
    
for jj = 1:VMAT_PLN_INFO.Total_CPs-1    
    eval(['VMAT_PLN_INFO.TRF.CP',int2str(jj),...
        '= Log_TRF(Log_TRF.ControlpointActualValueNone == jj & Log_TRF.LinacStateActualValueNone == ''Radiation On'',{inf_{:},Y1{:},Y2{:}});']);
    
    eval(['time_interval(jj) = VMAT_PLN_INFO.TRF.CP',int2str(jj),'.VarName1(end)-VMAT_PLN_INFO.TRF.CP',int2str(jj),'.VarName1(1);'])
    eval(['VMAT_PLN_INFO.TRF_Gantry_Speed(jj) = (VMAT_PLN_INFO.TRF.CP',int2str(jj),'.StepGantryScaledActualdeg(end)-'...
        'VMAT_PLN_INFO.TRF.CP',int2str(jj),'.StepGantryScaledActualdeg(1))/time_interval(jj);'])
    VMAT_PLN_INFO.TRF_time_interval(jj) = time_interval(jj);
    eval(['VMAT_PLN_INFO.TRF_Differential_MU(jj) = VMAT_PLN_INFO.TRF.CP',int2str(jj),...
        '.StepDoseActualValueMu(end)-VMAT_PLN_INFO.TRF.CP',int2str(jj),'.StepDoseActualValueMu(1);']);
    
end


%% check MU difference betweend treatment planning and delivery
PLAN_MU = VMAT_PLN_INFO.CP_info(:,2);
for i=1:size(PLAN_MU,1)-1
    PLAN_MU_(i) =  PLAN_MU{i+1,1} - PLAN_MU{i,1};
end

figure; 
plot(1:length(PLAN_MU_),PLAN_MU_,'b-');
hold on; 
plot(1:length(VMAT_PLN_INFO.TRF_Differential_MU),VMAT_PLN_INFO.TRF_Differential_MU,'r-');
hold on;
plot(1:length(VMAT_PLN_INFO.TRF_Differential_MU),VMAT_PLN_INFO.TRF_Differential_MU-PLAN_MU_,'g--');
xlabel('number of control points ');
ylabel('differential MU');
legend('PLAN MU','MACHINE MU','Error');
grid on;

%% check time interval between CPs
figure; 
plot(1:length(VMAT_PLN_INFO.TRF_time_interval'),VMAT_PLN_INFO.TRF_time_interval','b-');
hold on; 
plot(1:length(VMAT_PLN_INFO.CP_time_interval),VMAT_PLN_INFO.CP_time_interval,'r-');
hold on;
plot(1:length(VMAT_PLN_INFO.CP_time_interval),VMAT_PLN_INFO.CP_time_interval-VMAT_PLN_INFO.TRF_time_interval','g--');
xlabel('number of control points ');
ylabel('differential Time interval between CPs');
legend('MACHINE Delivery Time Interval','PLANNING Time Interval','Deviation');
grid on;


figure; 
plot(1:length(time1),time1,'b-');
hold on; 
plot(1:length(time2),time2,'r-');
hold on;
plot(1:length(time2),time2-time1,'g--');
xlabel('number of control points ');
ylabel('differential Time interval between CPs');
legend('Max Gantry Speed 6.0, Max DR 720','Max Gantry Speed 4.8, Max DR 600','Deviation');
grid on;


%% check Average Gantry Speed between treatment planning and delivery
figure; 
plot(1:length(VMAT_PLN_INFO.GantrySpeed),VMAT_PLN_INFO.GantrySpeed,'b-');
hold on; 
plot(1:length(VMAT_PLN_INFO.TRF_Gantry_Speed),VMAT_PLN_INFO.TRF_Gantry_Speed,'r-');
hold on;
plot(1:length(VMAT_PLN_INFO.GantrySpeed),VMAT_PLN_INFO.TRF_Gantry_Speed'-VMAT_PLN_INFO.GantrySpeed,'g--');
xlabel('number of control points ');
ylabel('Gantry Speed (deg/s)');
legend('PLAN Gantry Speed','MACHINE Gantry Speed','Speed Error');
grid on;

%% check instant gantry speed and acceleration per 0.04s
Gantry_rotatation_all = VMAT202003181Arctable.StepGantryScaledActualdeg;
gantry_speed_all = Gantry_rotatation_all(2:end);
for i=1:length(gantry_all)-1 
    gantry_speed_all(i) = (gantry_all(i+1) - gantry_all(i))/0.04;
end

for i=1:length(gantry_speed_all)-1 
    gantry_acceleration_all(i) = (gantry_speed_all(i+1) - gantry_speed_all(i))/0.04;
end

figure; plot(1:length(gantry_speed_all(1:end-1)),gantry_speed_all(1:end-1),'m-');title('˲ʱgantry speed per 0.04s');xlabel('time');ylabel('˲ʱgantry speed (deg/s)');
figure; plot(1:length(gantry_acceleration_all(1:end-1)),gantry_acceleration_all(1:end-1),'m-');title('˲ʱgantry accelearation per 0.04s');xlabel('time');ylabel('˲ʱgantry acceleration(deg/s^2)');

%% TEST MLC Speed Alteration within CPs

TEST_CP = table2struct(VMAT_PLN_INFO.TRF.CP3);
Gan_Sped_CP3 = zeros(size(TEST_CP,1)-1,1);
DLGY1_CP3 = zeros(size(TEST_CP,1)-1,1);DLGY2_CP3 = zeros(size(TEST_CP,1)-1,1);
MLC_Speed_CP3_Y1 = zeros(size(TEST_CP,1)-1,80);
MLC_Speed_CP3_Y2 = zeros(size(TEST_CP,1)-1,80);
for j = 1:size(TEST_CP,1)-1
    Gan_Sped_CP3(j) = (TEST_CP(j+1).StepGantryScaledActualdeg...
        -TEST_CP(j).StepGantryScaledActualdeg)/0.04;
    DLGY1_CP3(j) = (TEST_CP(j+1).DlgY1ScaledActualmm...
        -TEST_CP(j).DlgY1ScaledActualmm)/0.04;
    DLGY2_CP3(j) = (TEST_CP(j+1).DlgY2ScaledActualmm...
        -TEST_CP(j).DlgY2ScaledActualmm)/0.04;
    for k = 1:80
        eval(['MLC_Speed_CP3_Y1(j,k) = (TEST_CP(j+1).Y1Leaf',int2str(k),'ScaledActualmm-'...
            'TEST_CP(j).Y1Leaf',int2str(k),'ScaledActualmm)/0.04;'])
        eval(['MLC_Speed_CP3_Y2(j,k) = (TEST_CP(j+1).Y2Leaf',int2str(k),'ScaledActualmm-'...
            'TEST_CP(j).Y2Leaf',int2str(k),'ScaledActualmm)/0.04;'])
    end
end
figure; plot(1:length(Gan_Sped_CP3),Gan_Sped_CP3,'b-');

figure;
h1 = histogram(MLC_Speed_CP3_Y1);
h1.BinWidth = 5;
hold on;
h2 = histogram(MLC_Speed_CP3_Y2);
h2.BinWidth = 5;
xlabel('MLC Speed from CP3 -> CP4 per 0.04s');

% plot MLC speed statics
figure;
subplot(2,1,1);
boxplot(MLC_Speed_CP3_Y1)
xlabel('Y1 Leaf pair');
ylabel('Leaf Speed(mm/s)');
hold on;
subplot(2,1,2);
boxplot(MLC_Speed_CP3_Y2)
xlabel('Y2 Leaf pair');
ylabel('Leaf Speed(mm/s)');


figure; plot(1:length(DLGY1_CP3),DLGY1_CP3,'b-');
hold on; plot(1:length(DLGY2_CP3),DLGY2_CP3,'r-');


% plot MLC speed statics
figure;
subplot(2,1,1);
boxplot(MLC_Speed_CP3_Y1 + DLGY1_CP3)
xlabel('Y1 Leaf pair');
ylabel('MLC+DLG Leaf Speed(mm/s)');
hold on;
subplot(2,1,2);
boxplot(MLC_Speed_CP3_Y2 + DLGY2_CP3)
xlabel('Y2 Leaf pair');
ylabel('MLC+DLG Leaf Speed(mm/s)');

%% check mlc position between control point 3 and control point 4
%%  e.g. Control Point 3

% PLAN CP3 shape 
PLAN_CP3 = flipud(reshape(VMAT_PLN_INFO.CP_info{3, 3},[80,2]));  

% treatment delivery CP3 shape
TRF_CP3 = table2struct(VMAT_PLN_INFO.TRF.CP3);
MLC_TRF_CP3_Y1 = zeros(size(TRF_CP3,1),80); 
MLC_TRF_CP3_Y2 = zeros(size(TRF_CP3,1),80);
MLC_TRF_CP3_X1 = zeros(size(TRF_CP3,1),1); 
MLC_TRF_CP3_X2 = zeros(size(TRF_CP3,1),1);
MLC_TRF_CP3_DoseRate = zeros(size(TRF_CP3,1),1);
MLC_TRF_CP3_CumulativeMU= zeros(size(TRF_CP3,1),1);
for jj = 1: size(TRF_CP3,1)
    MLC_TRF_CP3_X1(jj) = TRF_CP3(jj).X1DiaphragmScaledActualmm;
    MLC_TRF_CP3_X2(jj) = TRF_CP3(jj).X2DiaphragmScaledActualmm;
    MLC_TRF_CP3_DoseRate(jj) = TRF_CP3(jj).ActualDoseRateActualValueMumin;
    MLC_TRF_CP3_CumulativeMU(jj) = TRF_CP3(jj).StepDoseActualValueMu;
    for k = 1:80 
        eval(['MLC_TRF_CP3_Y1(jj,k) = TRF_CP3(jj).Y1Leaf',int2str(k),'ScaledActualmm;']);
        eval(['MLC_TRF_CP3_Y2(jj,k) = TRF_CP3(jj).Y2Leaf',int2str(k),'ScaledActualmm;']);
    end
    
end

MLC_TRF_CP3_Y1 = MLC_TRF_CP3_Y1';MLC_TRF_CP3_Y2 = MLC_TRF_CP3_Y2';

MLC_TRF_CP3 = [MLC_TRF_CP3_Y2(:,1),MLC_TRF_CP3_Y1(:,1)];
MLC_TRF_CP3(1:76,1) = -MLC_TRF_CP3(1:76,1);

Error_MLC_ =  MLC_TRF_CP3-PLAN_CP3;

for s = 1:size(MLC_TRF_CP3_Y1,2)
    MLC_TRF_CP3 = [-MLC_TRF_CP3_Y2(:,s),MLC_TRF_CP3_Y1(:,s)];
    f = figure;
    for i=1:size(MLC_TRF_CP3,1)
        rectangle('Position', [0 1024-i*12.8 512+MLC_TRF_CP3(i,1) 12.8], 'FaceColor', [0 0 1 0.5]);
        hold on;
        rectangle('Position', [512+MLC_TRF_CP3(i,2) 1024-i*12.8 512-MLC_TRF_CP3(i,2) 12.8], 'FaceColor', [0 0 1 0.5]);
        hold on;
        plot(512.5,512.5,'r+');
        axis off;
    end
    close(f)
end










figure;
for i=1:size(MLC_TRF_CP3,1)
rectangle('Position', [0 1024-i*12.8 512+MLC_TRF_CP3(i,1) 12.8], 'FaceColor', [0 0 1 0.5]);
hold on;
rectangle('Position', [512+MLC_TRF_CP3(i,2) 1024-i*12.8 512-MLC_TRF_CP3(i,2) 12.8], 'FaceColor', [0 0 1 0.5]);
hold on;
plot(512.5,512.5,'r+');
axis off;
end


figure;
for i=1:size(PLAN_CP3,1)
% x : 0, [0 y_position MLC_length MLC_leaf_width]
rectangle('Position', [0 1024-i*12.8 512+PLAN_CP3(i,1) 12.8], 'FaceColor', [0 0 1 0.5]);
hold on;
rectangle('Position', [512+PLAN_CP3(i,2) 1024-i*12.8 512-PLAN_CP3(i,2) 12.8], 'FaceColor', [0 0 1 0.5]);
hold on;
plot(512.5,512.5,'r+');
axis off;
end


figure; 




end

