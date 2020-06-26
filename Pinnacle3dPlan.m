function PLN_INFO = Pinnacle3dPlan(DICOM_path)


%% read plan dicom
path = cd;
DICOM_path = [path,'/example/Pinnacle_irregular_beam/2.16.840.1.113669.2.931128.88619170.20200624155934.888624.dcm'];


% read rtplan dicom file to extract the leaf position and MU
% DICOM_path = '/Users/henryhuang/Desktop/VMAT-QA-metrics-master/0028_VMAT20200318.dcm';
plan_info = dicominfo(DICOM_path);

% total MU
PLN_INFO.Total_MU = plan_info.FractionGroupSequence.Item_1.ReferencedBeamSequence.Item_1.BeamMeterset;
fprintf('Total MU:%3f \n',PLN_INFO.Total_MU);

% total control points
PLN_INFO.Total_CPs = length(fieldnames(plan_info.BeamSequence));
fprintf('Total control points: %d \n',PLN_INFO.Total_CPs);

% fractions
% PLN_INFO.FX = plan_info.FractionGroupSequence.Item_1.NumberOfFractionsPlanned;
% fprintf('Fractions:%d \n',PLN_INFO.FX);

% target prescription dose
% PLN_INFO.TPD = plan_info.DoseReferenceSequence.Item_1.TargetPrescriptionDose;
% fprintf('Target prescription dose(Gy):%2f \n',PLN_INFO.TPD);

%extract CP and MU
% e.g CP1 : 180, MU, MLC position,jaw position, 
PLN_INFO.CP_info = cell(PLN_INFO.Total_CPs,4);

for j=1:PLN_INFO.Total_CPs
    eval(['PLN_INFO.CP_info{',int2str(j),',1} = plan_info.BeamSequence.Item_',int2str(j),...
        '.ControlPointSequence.Item_1.GantryAngle;']) % gantry angle

    eval(['PLN_INFO.CP_info{',int2str(j),',2} = plan_info.BeamSequence.Item_',int2str(j),...
        '.ControlPointSequence.Item_1.BeamLimitingDevicePositionSequence.Item_1.LeafJawPositions;']) % XJaw position
    eval(['PLN_INFO.CP_info{',int2str(j),',3} = plan_info.BeamSequence.Item_',int2str(j),...
        '.ControlPointSequence.Item_1.BeamLimitingDevicePositionSequence.Item_2.LeafJawPositions;']) % YJaw position
    eval(['PLN_INFO.CP_info{',int2str(j),',4} = reshape(plan_info.BeamSequence.Item_',int2str(j),...
        '.ControlPointSequence.Item_1.BeamLimitingDevicePositionSequence.Item_3.LeafJawPositions,[80,2]);']) % MLC position  
    fprintf("This is %d th control point \n",j);
end

%% plot segment shape
MLC = PLN_INFO.CP_info(:,4);
JAW = PLN_INFO.CP_info{1, 2};
mlc_width = 5;
num_seg = 1; beam_num = 1;
goal_path = cd;
plot_mlc_pinnacle_static(MLC,JAW,mlc_width,num_seg,beam_num,goal_path,'Agility')


end

