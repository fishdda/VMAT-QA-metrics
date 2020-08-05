class DATA_CLEAN:

    def __init__(self, DICOM_name, RTP_name):
        self.DICOM_name = DICOM_name
        self.RTP_name = RTP_name

    def extract_DICOM(self):

        import pydicom 
        import os
        dcm = pydicom.read_file(self.DICOM_name)
        mu_density = {'Gantry':[],'MLC':[],'JAW':[],'MU':[]}
        absolute_MU = []
        for i in range(len(dcm.BeamSequence)):
            
            absolute_MU.append(float(dcm.FractionGroupSequence[0].ReferencedBeamSequence[i].BeamMeterset))
            
            for j in range(len(dcm.BeamSequence[i].ControlPointSequence)):
                
                mu_density['Gantry'].append(int(dcm.BeamSequence[i].ControlPointSequence[0].GantryAngle))
                MU = float(dcm.BeamSequence[i].ControlPointSequence[j].CumulativeMetersetWeight)*absolute_MU[i]/100
                mu_density['MU'].append(MU)
                if len(dcm.BeamSequence[i].ControlPointSequence[j].BeamLimitingDevicePositionSequence) == 3:
                    mu_density['MLC'].append(dcm.BeamSequence[i].ControlPointSequence[j].BeamLimitingDevicePositionSequence[2].LeafJawPositions)
                    mu_density['JAW'].append(dcm.BeamSequence[i].ControlPointSequence[j].BeamLimitingDevicePositionSequence[1].LeafJawPositions)
                else:
                    mu_density['MLC'].append(dcm.BeamSequence[i].ControlPointSequence[j].BeamLimitingDevicePositionSequence[0].LeafJawPositions)
                    mu_density['JAW'].append([None,None])
                    print('it has no jaw positions')
                    print('This is {}th beam {}th control point'.format(i+1,j+1))     

        self.PLAN = mu_density
        return self.PLAN   

    def extract_RTP(self):

        line,pointer = [],[]
        absolute_MU = []
        RTP = {'Gantry':[],'MLC':[],'JAW':[],'MU':[],'MU_absolute':[]}
        with open(self.RTP_name, "r+", encoding = "ISO-8859-1") as f:
            line1 = f.readline()    
            line.append(line1)
            while line1:        
                pointer.append(f.tell())  #record the pointer loaction to help write        
                line1 = f.readline()        
                line.append(line1)
        for i,item in enumerate(line[3:-9]):
            TempLine = item.split('"')  
            if TempLine[1] == 'CONTROL_PT_DEF': # to ensure the head
                RTP['Gantry'].append(float(TempLine[27].split(' ')[-1]))
                PP_ = []
                for item1 in TempLine:
                    if ' ' in item1:
                        PP_.append(item1.split(' ')[-1])
                    else:
                        PP_.append(item1)

        #         print('This is {}th control point'.format(i))
                MLC_A = [float(item) for item in PP_[65:65+160] if item != ',']
                MLC_B = [float(item) for item in PP_[65+161+39:65+161+39+160] if item != ',']
                RTP['MLC'].append(MLC_A+MLC_B)
                RTP['MU'].append(float(PP_[15]))
            elif TempLine[1] == "FIELD_DEF":
                absolute_MU.append(float(TempLine[13].split(' ')[-1]))

        count = 0
        RTP['MU_absolute'] = []
        for i,item in enumerate(RTP['MU']):
            RTP['MU_absolute'].append(absolute_MU[count]*RTP['MU'][i])
            if RTP['MU'][i] == 0 and i>0: 
                count += 1

        self.RTP = RTP
        return self.RTP
        


