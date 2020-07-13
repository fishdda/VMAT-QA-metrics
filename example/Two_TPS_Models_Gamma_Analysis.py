import numpy as np
import matplotlib.pyplot as plt
import pydicom
import pymedphys

# The dose calculated from the original model of HB renmin hospitals
reference_filepath = pymedphys.data_path("original_dose_beam_4.dcm")

# The dose calculated from the updated ABM model of HB renmin hospitals
evaluation_filepath = pymedphys.data_path("logfile_dose_beam_4.dcm")

reference = pydicom.read_file(str(reference_filepath), force=True)
evaluation = pydicom.read_file(str(evaluation_filepath), force=True)

axes_reference, dose_reference = pymedphys.dicom.zyx_and_dose_from_dataset(reference)
axes_evaluation, dose_evaluation = pymedphys.dicom.zyx_and_dose_from_dataset(evaluation)

(z_ref, y_ref, x_ref) = axes_reference
(z_eval, y_eval, x_eval) = axes_evaluation