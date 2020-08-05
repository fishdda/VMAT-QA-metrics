import pymedphys
from pymedphys import Delivery

# trf file read 
trf_file = 'C:/GitFolder/VMAT-QA-metrics/MU intensity/MonacoHDMLC.trf'
delivery = Delivery.from_logfile(trf_file)
trf_mu_density = delivery.mudensity() # This is the "fluence"
grid = pymedphys.mudensity.grid()

pymedphys.mudensity.display(grid,trf_mu_density) # plot the MU density


# dicom file read
# dicom_rtplan_filepath = 'C:/GitFolder/VMAT-QA-metrics/example/test_case/VMAT1Arc/0028_VMAT202003181arc.dcm'
# fraction_number = 28
# delivery = Delivery.from_dicom_file(dicom_rtplan_filepath, fraction_number)
# dcm_mudensity = delivery.mudensity()  # This is the "fluence"


# plot the comparison
# subplot(1,2,1)
# plt.imshow(trf_mu_density)
# plt.title('TRF file (Elekta Log file)')
# subplot(1,2,2)
# plt.imshow(dcm_mudensity)
# plt.title('DCM file (Monaco Plan file)')
# plt.colorbar()
# plt.show()