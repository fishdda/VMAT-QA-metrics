function Unity_PLN_INFO = Unity_PLAN(folder_path)

% read rtplan dicom file to extract the leaf position and MU
% DICOM_path = '/Users/henryhuang/Desktop/VMAT-QA-metrics-master/0028_VMAT20200318.dcm';
%   Note: In Monaco TPS, a VMAT plan could have more than one arc, such as
%   two or three arcs. But two different approaches could be used: 1) max.
%   num of arcs setting in sequencing parameters. 2) add more arc beams in
%   the beam column. Here in this script, currently we only compatible to
%   the first situation.
folder_names = dir([folder_path,'*.dcm']);

%% extract raw data from plans
for j = 1:size(folder_names,1)
    % iterate each online adaptive plan
    DICOM_path = [folder_names(j).folder,'\',folder_names(j).name];
    plan_info = dicominfo(DICOM_path); % adaptive plan except the first one
    
    % store field numbers
    Unity_PLN_INFO.(['Unity_',plan_info.RTPlanName]).Field_Nums = size(fieldnames(plan_info.FractionGroupSequence.Item_1.ReferencedBeamSequence),1);
    
    % target prescription dose
    Unity_PLN_INFO.(['Unity_',plan_info.RTPlanName]).TPD = plan_info.DoseReferenceSequence.Item_1.TargetPrescriptionDose;
    fprintf('Target prescription dose(Gy):%2f \n',Unity_PLN_INFO.(['Unity_',plan_info.RTPlanName]).TPD);
    
    % fractions
    Unity_PLN_INFO.(['Unity_',plan_info.RTPlanName]).FX = plan_info.FractionGroupSequence.Item_1.NumberOfFractionsPlanned;
    fprintf('Fractions:%d \n',Unity_PLN_INFO.(['Unity_',plan_info.RTPlanName]).FX);

    
    % calculate total MU and total control points for each plan
    Unity_PLN_INFO.(['Unity_',plan_info.RTPlanName]).Total_MU = 0; 
    Unity_PLN_INFO.(['Unity_',plan_info.RTPlanName]).Total_CPs = 0;
    Unity_PLN_INFO.(['Unity_',plan_info.RTPlanName]).Beam_MU = [];
    Gantry = [];
    for k = 1:size(fieldnames(plan_info.FractionGroupSequence.Item_1.ReferencedBeamSequence),1)
        % iterate beam number
        eval(['Unity_PLN_INFO.([''Unity_'',plan_info.RTPlanName]).Beam_MU = [Unity_PLN_INFO.([''Unity_'',plan_info.RTPlanName]).Beam_MU,',...
            'plan_info.FractionGroupSequence.Item_1.ReferencedBeamSequence.Item_',...
            int2str(k),'.BeamMeterset];']);
        
        eval(['Unity_PLN_INFO.([''Unity_'',plan_info.RTPlanName]).Total_MU = Unity_PLN_INFO.([''Unity_'',plan_info.RTPlanName]).Total_MU',...
            '+ plan_info.FractionGroupSequence.Item_1.ReferencedBeamSequence.Item_',...
            int2str(k),'.BeamMeterset;']); % total MUs
        eval(['Unity_PLN_INFO.([''Unity_'',plan_info.RTPlanName]).Total_CPs = Unity_PLN_INFO.([''Unity_'',plan_info.RTPlanName]).Total_CPs'...
            '+ plan_info.BeamSequence.Item_',int2str(k),'.NumberOfControlPoints;']); % total control points
        
        eval(['beam_CPs = plan_info.BeamSequence.Item_',int2str(k),'.NumberOfControlPoints;']);

        
        eval(['Angle(k) = plan_info.BeamSequence.Item_',...
                int2str(k),'.ControlPointSequence.Item_1.GantryAngle;']);
        if k > 1 && Angle(k) ~= Angle(k-1)
            Gantry = [Gantry,Angle(k)];
        elseif k == 1
            Gantry = [Gantry,Angle(k)];
        end
        
        % calculate gantry angle,cumulative mu, MLC positions, Jaw positions
        for jj = 1:beam_CPs
            disp(jj)
            cumu_cps = Unity_PLN_INFO.(['Unity_',plan_info.RTPlanName]).Total_CPs - beam_CPs;

            eval(['Unity_PLN_INFO.([''Unity_'',plan_info.RTPlanName]).CP_info_raw{jj+cumu_cps,1} = plan_info.BeamSequence.Item_',...
                int2str(k),'.ControlPointSequence.Item_1.GantryAngle;']);
            eval(['Unity_PLN_INFO.([''Unity_'',plan_info.RTPlanName]).CP_info_raw{jj+cumu_cps,2} = plan_info.BeamSequence.Item_',...
                int2str(k),'.ControlPointSequence.Item_',int2str(jj),'.CumulativeMetersetWeight;']);
            eval(['Unity_PLN_INFO.([''Unity_'',plan_info.RTPlanName]).CP_info_raw{jj+cumu_cps,3} = plan_info.BeamSequence.Item_',...
                int2str(k),'.ControlPointSequence.Item_',int2str(jj),'.BeamLimitingDevicePositionSequence.Item_1.LeafJawPositions;']);
            eval(['Unity_PLN_INFO.([''Unity_'',plan_info.RTPlanName]).CP_info_raw{jj+cumu_cps,4} = plan_info.BeamSequence.Item_',...
                int2str(k),'.ControlPointSequence.Item_',int2str(jj),'.BeamLimitingDevicePositionSequence.Item_2.LeafJawPositions ;']);
            eval(['Unity_PLN_INFO.([''Unity_'',plan_info.RTPlanName]).CP_info_raw{jj+cumu_cps,5} = plan_info.BeamSequence.Item_',...
                int2str(k),'.BeamLimitingDeviceSequence.Item_2.LeafPositionBoundaries ;']);
            
        end
        
        Unity_PLN_INFO.(['Unity_',plan_info.RTPlanName]).Gantry_Angle = Gantry;
    end
    
end

%% further cleaning raw data
% determine how many adaptive plans it has
num_adapt = size(fieldnames(Unity_PLN_INFO),1);
nam_adapt = fieldnames(Unity_PLN_INFO);
for jj = 1:num_adapt
    
    %iterate each adaptive plan and modification o
    CP_info_unity = Unity_PLN_INFO.(nam_adapt{jj}).CP_info_raw;
    count = 1;
    for kk = 1:size(CP_info_unity,1)/2
        Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{kk,1} = CP_info_unity{2*kk,1};% gantry angle
        if kk > 1 && Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{kk,1} ~= Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{kk-1,1}
            count = count + 1;
            Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{kk,2} = (CP_info_unity{2*kk,2}-CP_info_unity{2*kk-1,2})*Unity_PLN_INFO.(nam_adapt{jj}).Beam_MU(count);% individual mu
        
        elseif kk > 1 && Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{kk,1} == Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{kk-1,1}
            Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{kk,2} = (CP_info_unity{2*kk,2}-CP_info_unity{2*kk-1,2})*Unity_PLN_INFO.(nam_adapt{jj}).Beam_MU(count);% individual mu
        
        elseif kk == 1 
            Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{kk,2} = (CP_info_unity{2*kk,2})*Unity_PLN_INFO.(nam_adapt{jj}).Beam_MU(count); % individual mu
        end
        
        Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{kk,3} = CP_info_unity{2*kk,3};% jaw position
        Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{kk,4} = CP_info_unity{2*kk,4};% leaf position
        Unity_PLN_INFO.(nam_adapt{jj}).CP_info_unity_{kk,5} = CP_info_unity{2*kk,5};% leaf position boundaries
    end
end



end

