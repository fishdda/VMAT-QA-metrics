function TRF_write_TEL(TRF_CSV_path,Tel_path)
%TRF_write_TEL This script was used to extract MLC information from TRF to
%TEL file.
%   TRF file stored all MLC,JAW,MU information. This function was to write
%   the corresponding MLC position, Jaw position into tel file.

num_leaf_pair = 80;
TRF_CSV_path = 'C:\GitFolder\VMAT-QA-metrics\example\test_case\VMAT1Arc\0028_VMAT202003181Arc_table.csv';
Tel_path = 'C:\GitFolder\VMAT-QA-metrics\example\test_case\VMAT1Arc\tel.1';
Log_TRF = readtable(TRF_CSV_path);

for i=1:num_leaf_pair
    Y1{1,i} = ['Y1Leaf',int2str(i),'_ScaledActual_mm_']; 
    Y2{1,i} = ['Y2Leaf',int2str(i),'_ScaledActual_mm_'];
end

inf_ = {'Var1','LinacState_ActualValue_None_',...
        'StepGantry_ScaledActual_deg_',...
        'ActualDoseRate_ActualValue_Mu_min_',...
        'StepDose_ActualValue_Mu_',...
        'DlgY1_ScaledActual_mm_',...
        'DlgY2_ScaledActual_mm_',...
        'X1Diaphragm_ScaledActual_mm_',...
        'X2Diaphragm_ScaledActual_mm_'};
    
for jj = 1:VMAT_PLN_INFO.Total_CPs-1    
    eval(['VMAT_PLN_INFO.TRF.CP',int2str(jj),...
        '= Log_TRF(Log_TRF.ControlPoint_ActualValue_None_ == jj & cell2mat(Log_TRF.LinacState_ActualValue_None_) == ''Radiation On'',{inf_{:},Y1{:},Y2{:}});']);
    
    eval(['time_interval(jj) = VMAT_PLN_INFO.TRF.CP',int2str(jj),'.Var1(end)-VMAT_PLN_INFO.TRF.CP',int2str(jj),'.Var1(1);'])
    eval(['VMAT_PLN_INFO.TRF_Gantry_Speed(jj) = (VMAT_PLN_INFO.TRF.CP',int2str(jj),'.StepGantry_ScaledActual_deg_(end)-'...
        'VMAT_PLN_INFO.TRF.CP',int2str(jj),'.StepGantry_ScaledActual_deg_(1))/time_interval(jj);'])
    VMAT_PLN_INFO.TRF_time_interval(jj) = time_interval(jj);
    eval(['VMAT_PLN_INFO.TRF_Differential_MU(jj) = VMAT_PLN_INFO.TRF.CP',int2str(jj),...
        '.StepDose_ActualValue_Mu_(end)-VMAT_PLN_INFO.TRF.CP',int2str(jj),'.StepDose_ActualValue_Mu_(1);']);
    
end

end

