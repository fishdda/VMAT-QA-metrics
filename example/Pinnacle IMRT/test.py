from extract_DATA import DATA_CLEAN
dicom_path = 'C:/GitFolder/VMAT-QA-metrics/example/Pinnacle IMRT/Pinnacle_PatientData.dcm'
rtp_path = 'C:/GitFolder/VMAT-QA-metrics/example/Pinnacle IMRT/Pinnacle_PatientData.RTP'
X = DATA_CLEAN(dicom_path,rtp_path)
PLAN = X.extract_DICOM()
RTP = X.extract_RTP()




