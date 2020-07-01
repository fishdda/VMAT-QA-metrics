function P=Varian_VMAT_decode(filename)
% this function read plan data from RP*.dcm file, and put it into a
% structure P. The fields in P:
% 
% arcnum: double. the number of arc
% 
% isocenter: double(arcnum*3). the isocenter for each arc, could be
% different from one arc to another. 
% 
% colliangle: double(arcnum*1). the collimator angle for each arch
% 
% couchangle: double(arcnum*1).
% 
% bannum: double(arcnum*1). number of beam angles for each arc
% 
% beamangle: cell(arcnum*1). each of the elements contains the beam angle
% for each control point. compatible for the number of control points that
% is not 178
% 
% leafjawx: double(arcnum*2). [-X1, X2] in mm
% 
% leafjawy: double(arcnum*2). [-Y1, Y2] in mm
% 
% mlcbound: cell(arcnum*1). boundary of mlc leaves. each element is
% double (1*61) in mm. according to the center
% 
% mlccp: cell(arcnum*1). control points. each element is 178*120 usually.
% according to the center
%
% muaccm: cell(arcnum*1). accumulated MUs. each element is 178*1 usually. 
% 
% 
% update 2018/07/02: only extract infomation for arc whose treatment
% deliver type is treatment. exclude the error due to trying to read control 
% points from set up beam
% 
% 
% 
% 


dcminfo=dicominfo(filename);

P.PatientID=dcminfo.PatientID;
P.PlanLabel=dcminfo.RTPlanLabel;

beamnames=fieldnames(dcminfo.BeamSequence);
P.arcnum=size(beamnames,1);

P.isocenter=zeros(P.arcnum,3);
P.coliangle=zeros(P.arcnum,1);
P.couchangle=zeros(P.arcnum,1);
P.leafjawy=cell(P.arcnum,1);
P.bannum=zeros(P.arcnum,1);
P.beamangle=cell(P.arcnum,1);
P.mlcbound=cell(P.arcnum,1);
P.mlccp=cell(P.arcnum,1);
P.arcmu=zeros(P.arcnum,1);
P.doseaccm=cell(P.arcnum,1);
P.dosefinal=cell(P.arcnum,1); 
P.muaccm=cell(P.arcnum,1);
P.mufinal=zeros(P.arcnum,1);

treatarcnum=zeros(P.arcnum,1);

ifreadarcmu=0;

for iarc=1:P.arcnum
    
    temp=dcminfo.BeamSequence.(['Item_',num2str(iarc)]).TreatmentDeliveryType;
    
    if(strcmp(temp,'TREATMENT'))
        treatarcnum(iarc)=1;
    else
        continue
    end
    
    P.isocenter(iarc,:)=dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
        ControlPointSequence.Item_1.IsocenterPosition;
    
    P.coliangle(iarc)=dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
        ControlPointSequence.Item_1.BeamLimitingDeviceAngle;
    
    P.couchangle(iarc)=dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
        ControlPointSequence.Item_1.PatientSupportAngle;
    
    P.beamangle{iarc}=dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
        ControlPointSequence.Item_1.GantryAngle;
    
    try
        P.arcmu(iarc)=dcminfo.FractionGroupSequence.Item_1.ReferencedBeamSequence. ...
            (['Item_',num2str(iarc)]).BeamMeterset; 
    catch ME
        ifreadarcmu=1;
    end
    
    P.bannum(iarc)=size(fieldnames(dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
        ControlPointSequence),1);
     
    P.mufinal(iarc)=dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
        FinalCumulativeMetersetWeight;
    
    P.beamangle{iarc}=zeros(P.bannum(iarc),1);
        
    P.muaccm{iarc}=zeros(P.bannum(iarc),1);
        
    dosenum=size(fieldnames(dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
        ControlPointSequence.Item_1.ReferencedDoseReferenceSequence),1);
    
    P.doseaccm{iarc}=zeros(dosenum,P.bannum(iarc));
    P.dosefinal{iarc}=zeros(dosenum,P.bannum(iarc));

    P.mlcbound{iarc}=dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
        BeamLimitingDeviceSequence.Item_2.LeafPositionBoundaries;
    
    P.leafjawy{iarc}=zeros(P.bannum(iarc),2);
    P.beamangle{iarc}=zeros(P.bannum(iarc),1);
    P.mlccp{iarc}=zeros(P.bannum(iarc),length(P.mlcbound{iarc})*2-2);
    P.muaccm{iarc}=zeros(P.bannum(iarc),1);
    
    
    for iban=1:P.bannum(iarc)
        
        P.beamangle{iarc}(iban)=dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
            ControlPointSequence.(['Item_',num2str(iban)]).GantryAngle;
        
        P.leafjawy{iarc}(iban,:) = dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
            ControlPointSequence.(['Item_',num2str(iban)]).BeamLimitingDevicePositionSequence. ...
            Item_1.LeafJawPositions;
        
        arcnames=fieldnames(dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
            ControlPointSequence.(['Item_',num2str(iban)]).BeamLimitingDevicePositionSequence);
        for iitem=1:length(arcnames)
            if strcmp(dcminfo.BeamSequence.(['Item_',num2str(iarc)]).ControlPointSequence. ...
                    (['Item_',num2str(iban)]).BeamLimitingDevicePositionSequence.(['Item_',num2str(iitem)]). ...
                    RTBeamLimitingDeviceType,'MLCX')
                P.mlccp{iarc}(iban,:)=dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
                    ControlPointSequence.(['Item_',num2str(iban)]).BeamLimitingDevicePositionSequence. ...
                    (['Item_',num2str(iitem)]).LeafJawPositions;
            end
        end

        try
            for idose=1:dosenum
                P.doseaccm{iarc}(idose,iban)=dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
                    ControlPointSequence.(['Item_',num2str(iban)]).ReferencedDoseReferenceSequence. ...
                    (['Item_',num2str(idose)]).CumulativeDoseReferenceCoefficient;
                
                P.dosefinal{iarc}(idose,iban)=dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
                    ControlPointSequence.(['Item_',num2str(iban)]).ReferencedDoseReferenceSequence. ...
                    Item_1.ReferencedDoseReferenceNumber;
                
            end
        catch ME
            disp(ME.message)
        end
            
        P.muaccm{iarc}(iban)=dcminfo.BeamSequence.(['Item_',num2str(iarc)]). ...
            ControlPointSequence.(['Item_',num2str(iban)]).CumulativeMetersetWeight;
    end
        
    

end

treatarcnum=treatarcnum.*(1:P.arcnum)';
treatarcnum(treatarcnum<1)=[];

if P.arcnum>sum(treatarcnum)
    P.arcnum=size(treatarcnum,1);
    P.isocenter=P.isocenter(treatarcnum,:);
    P.coliangle=P.coliangle(treatarcnum,:);
    P.couchangle=P.couchangle(treatarcnum,:);
    P.leafjawx=P.leafjawx(treatarcnum,:);
    P.leafjawy=P.leafjawy(treatarcnum,:);
    P.bannum=P.bannum(treatarcnum,:);
    P.beamangle=P.beamangle(treatarcnum);
    P.mlcbound=P.mlcbound(treatarcnum);
    P.mlccp=P.mlccp(treatarcnum);
    P.dosefinal=P.dosefinal(treatarcnum);
    P.doseaccm=P.doseaccm(treatarcnum);
    P.muaccm=P.muaccm(treatarcnum);
    P.mufinal=P.mufinal(treatarcnum);
    P.arcmu=P.arcmu(treatarcnum);
end

if ifreadarcmu
    arcnamet=fieldnames(dcminfo.FractionGroupSequence.Item_1.ReferencedBeamSequence);
    P.arcmu=zeros(length(arcnamet),1);
    for iarc=1:length(arcnamet)
        try
            P.arcmu(iarc)=dcminfo.FractionGroupSequence.Item_1.ReferencedBeamSequence. ...
                (['Item_',num2str(iarc)]).BeamMeterset; 
        catch ME
            P.arcmu(iarc)=-1;
        end
    end
    arclog=(P.arcmu>0).*(1:length(arcnamet))';
    P.arcmu=P.arcmu(arclog(arclog>0));
    
end


end




