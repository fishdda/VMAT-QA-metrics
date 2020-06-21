function VMAT_PLN_INFO = VMAT_PLAN(DICOM_path)

% read rtplan dicom file to extract the leaf position and MU
% DICOM_path = '/Users/henryhuang/Desktop/VMAT-QA-metrics-master/0028_VMAT20200318.dcm';
plan_info = dicominfo(DICOM_path);

% total MU
VMAT_PLN_INFO.Total_MU = plan_info.FractionGroupSequence.Item_1.ReferencedBeamSequence.Item_1.BeamMeterset;
fprintf('Total MU:%3f \n',VMAT_PLN_INFO.Total_MU);

% total control points
VMAT_PLN_INFO.Total_CPs = plan_info.BeamSequence.Item_1.NumberOfControlPoints;
fprintf('Total control points: %d \n',VMAT_PLN_INFO.Total_CPs);

% fractions
VMAT_PLN_INFO.FX = plan_info.FractionGroupSequence.Item_1.NumberOfFractionsPlanned;
fprintf('Fractions:%d \n',VMAT_PLN_INFO.FX);

% target prescription dose
VMAT_PLN_INFO.TPD = plan_info.DoseReferenceSequence.Item_1.TargetPrescriptionDose;
fprintf('Target prescription dose(Gy):%2f \n',VMAT_PLN_INFO.TPD);

%extract CP and MU
% e.g CP1 : 180, MU, MLC position,jaw position, 
VMAT_PLN_INFO.CP_info = cell(VMAT_PLN_INFO.Total_CPs,4);

for j=1:VMAT_PLN_INFO.Total_CPs
    eval(['VMAT_PLN_INFO.CP_info{',int2str(j),',1} = plan_info.BeamSequence.Item_1.ControlPointSequence.Item_',...
        int2str(j),'.GantryAngle;']) % gantry angle
    eval(['VMAT_PLN_INFO.CP_info{',int2str(j),',2} = VMAT_PLN_INFO.Total_MU*plan_info.BeamSequence.Item_1.ControlPointSequence.Item_',...
        int2str(j),'.CumulativeMetersetWeight;']) %cumulative mu weight
    eval(['VMAT_PLN_INFO.CP_info{',int2str(j),',3} = plan_info.BeamSequence.Item_1.ControlPointSequence.Item_',...
        int2str(j),'.BeamLimitingDevicePositionSequence.Item_2.LeafJawPositions;']) % Jaw position   
    eval(['VMAT_PLN_INFO.CP_info{',int2str(j),',4} = plan_info.BeamSequence.Item_1.ControlPointSequence.Item_',...
        int2str(j),'.BeamLimitingDevicePositionSequence.Item_1.LeafJawPositions;']) % MLC position  
    fprintf("This is %d th control point \n",j);
end

end

