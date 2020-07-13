function Unity_PLN_INFO = Unity_PLAN(DICOM_path)

% read rtplan dicom file to extract the leaf position and MU
% DICOM_path = '/Users/henryhuang/Desktop/VMAT-QA-metrics-master/0028_VMAT20200318.dcm';
%   Note: In Monaco TPS, a VMAT plan could have more than one arc, such as
%   two or three arcs. But two different approaches could be used: 1) max.
%   num of arcs setting in sequencing parameters. 2) add more arc beams in
%   the beam column. Here in this script, currently we only compatible to
%   the first situation.
DICOM_path = [folder_names(1).folder,'\',folder_names(1).name];
plan_info = dicominfo(DICOM_path);


% total Number of Beams
Unity_PLN_INFO.Field_Nums = size(fieldnames(plan_info.FractionGroupSequence.Item_1.ReferencedBeamSequence),1);

% total MU and each beam MU
Unity_PLN_INFO.Total_MU = 0;
for k = 1:Unity_PLN_INFO.Field_Nums
    Unity_PLN_INFO.CP_info.Beam_ko
    
    
    
    eval(['Unity_PLN_INFO.Total_MU = Unity_PLN_INFO.Total_MU + plan_info.FractionGroupSequence.Item_1.ReferencedBeamSequence.Item_',...
        int2str(k),'.BeamMeterset;']);
end
fprintf('Total MU:%3f \n',Unity_PLN_INFO.Total_MU);

% total control points
Unity_PLN_INFO.Total_CPs = plan_info.BeamSequence.Item_1.NumberOfControlPoints;
fprintf('Total control points: %d \n',Unity_PLN_INFO.Total_CPs);

% fractions
Unity_PLN_INFO.FX = plan_info.FractionGroupSequence.Item_1.NumberOfFractionsPlanned;
fprintf('Fractions:%d \n',Unity_PLN_INFO.FX);

% target prescription dose
Unity_PLN_INFO.TPD = plan_info.DoseReferenceSequence.Item_1.TargetPrescriptionDose;
fprintf('Target prescription dose(Gy):%2f \n',Unity_PLN_INFO.TPD);

%extract CP and MU
% e.g CP1 : 180, MU, MLC position,jaw position, 
Unity_PLN_INFO.CP_info = cell(Unity_PLN_INFO.Total_CPs,4);

for j=1:Unity_PLN_INFO.Total_CPs
    eval(['Unity_PLN_INFO.CP_info{',int2str(j),',1} = plan_info.BeamSequence.Item_1.ControlPointSequence.Item_',...
        int2str(j),'.GantryAngle;']) % gantry angle
    eval(['Unity_PLN_INFO.CP_info{',int2str(j),',2} = Unity_PLN_INFO.Total_MU*plan_info.BeamSequence.Item_1.ControlPointSequence.Item_',...
        int2str(j),'.CumulativeMetersetWeight;']) %cumulative mu weight
    eval(['Unity_PLN_INFO.CP_info{',int2str(j),',3} = plan_info.BeamSequence.Item_1.ControlPointSequence.Item_',...
        int2str(j),'.BeamLimitingDevicePositionSequence.Item_2.LeafJawPositions;']) % Jaw position   
    eval(['Unity_PLN_INFO.CP_info{',int2str(j),',4} = plan_info.BeamSequence.Item_1.ControlPointSequence.Item_',...
        int2str(j),'.BeamLimitingDevicePositionSequence.Item_1.LeafJawPositions;']) % MLC position  
    fprintf("This is %d th control point \n",j);
end

% to analyze the plan has how many arcs.
index = cell2mat(Unity_PLN_INFO.CP_info(:,1)) == 180;
index2 = find(index == 1);
var = index2(2:end) - index2(1:end-1);
Unity_PLN_INFO.Arc_Num = 1 + sum(var == 1);

end

