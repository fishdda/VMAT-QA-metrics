#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pymedphys, pydicom
from pymedphys import dicom


# In[2]:


from pymedphys import mudensity


# In[3]:


import numpy as np
import pandas as pd


# In[4]:


import matplotlib.pyplot as plt


# In[5]:


root = "C:/Users/sjiae08541/Documents/Project_MU_density/data/"
filepath = root + "/19_10_28_plan/0028_CIIE132167443284631164.dcm"


# In[6]:


file = pydicom.read_file(filepath, force=True)
print(file)


# In[7]:


# Per Fraction
# TO BE DONE...
N_FRACTION_GROUP = len(file.FractionGroupSequence)
N_FRACTION_GROUP


# In[8]:


fraction_group = file.FractionGroupSequence[0]


# In[9]:


# Per Beam
# N_BEAM = fraction_group.NumberOfBeams


# In[16]:


# Per Segment
def calc_mu_density_per_segment_and_display(cp, current_weight, total_mu, check_mlc=True, display=True, 
                                            grid_resolution=1, max_leaf_gap=400, leaf_pair_widths=[5]*80):
    # Ref: correlate the DICOM MLC leaf positions with Monaco display
    # multipling by [-1, 1]
    raw_mlc = np.array([cp.BeamLimitingDevicePositionSequence[1].LeafJawPositions])
    mlc = np.swapaxes(raw_mlc.reshape(1,2,len(leaf_pair_widths)),1,2) * np.array([-1,1])
    mlc = np.append(mlc, mlc, 0)
    jaw = np.array([cp.BeamLimitingDevicePositionSequence[0].LeafJawPositions]) * np.array([-1,1])
    jaw = np.append(jaw, jaw, 0)
    mu = [current_weight * total_mu, cp.CumulativeMetersetWeight * total_mu]
    
    if check_mlc:
        print('.........showing the setup MLC-jaw positions of current segment')
        # Check MLC and jaw coordinates
        plt.plot(mlc[0]*np.array([-1,1]), np.arange(-200,200,5))
        plt.axhline(-jaw[0,0],xmin=-200, xmax=200, color='red')
        plt.axhline(jaw[0,1],xmin=-200, xmax=200,color='green')
        plt.xlim(-200,200)
        plt.ylim(200, -200)
        plt.show()
        
    mu_density = mudensity.calc_mu_density(mu, mlc, jaw, grid_resolution=grid_resolution, 
                                           max_leaf_gap=max_leaf_gap, leaf_pair_widths=leaf_pair_widths)
    current_weight = cp.CumulativeMetersetWeight
    
    if display:
        grid = mudensity.get_grid(max_leaf_gap=max_leaf_gap, grid_resolution=grid_resolution,
                                  leaf_pair_widths=leaf_pair_widths)
        mudensity.display_mu_density(grid, mu_density)
        print('......MU Density of Current Segment')
        plt.show()

    return mu_density


# In[11]:


# Per Beam    
def mu_density_per_beam_and_display(beam, total_mu, display=True, grid_resolution=1, max_leaf_gap=400, 
                                    leaf_pair_widths=[5]*80):
    N_CP = beam.NumberOfControlPoints
    
    print('......calculating segment no. 0')    
    mu_density = calc_mu_density_per_segment_and_display(beam.ControlPointSequence[0], 0, total_mu=total_mu, 
                                                         check_mlc=True, display=True, grid_resolution=grid_resolution,
                                                         max_leaf_gap=max_leaf_gap, leaf_pair_widths=leaf_pair_widths)
    
    if N_CP > 1:
        current_weight = beam.ControlPointSequence[0].CumulativeMetersetWeight
        for i in range(N_CP-1):
            print('......calculating segment no. ' + str(i+1))
            mu_density += calc_mu_density_per_segment_and_display(beam.ControlPointSequence[i+1], 
                                                                  current_weight, total_mu=total_mu, check_mlc=False, 
                                                                  display=False, grid_resolution=grid_resolution, 
                                                                  max_leaf_gap=max_leaf_gap, 
                                                                  leaf_pair_widths=leaf_pair_widths)
            current_weight = beam.ControlPointSequence[i+1].CumulativeMetersetWeight
    if display:
        grid = mudensity.get_grid(max_leaf_gap=max_leaf_gap, grid_resolution=grid_resolution,
                                  leaf_pair_widths=leaf_pair_widths)
        mudensity.display_mu_density(grid, mu_density)
        print('...MU Density of Current Beam')
        plt.show()
        print('..............................................')
   
    return mu_density


# In[12]:


# Per patient
def mu_density_per_patient_and_display(file, fraction_group, display=True, grid_resolution=1, 
                                       max_leaf_gap=400, leaf_pair_widths=[5]*80):
    print('Starting')
    print('...calculating beam no. 0')

    total_mu = fraction_group.ReferencedBeamSequence[0].BeamMeterset
    mu_density = mu_density_per_beam_and_display(file.BeamSequence[0], total_mu, display=True, 
                                                 grid_resolution=grid_resolution, max_leaf_gap=max_leaf_gap, 
                                                 leaf_pair_widths=leaf_pair_widths)

    if fraction_group.NumberOfBeams > 1:
        for i in range(fraction_group.NumberOfBeams-1):
            print('...calculating beam no. ' + str(i+1))
            total_mu = fraction_group.ReferencedBeamSequence[i+1].BeamMeterset
            mu_density += mu_density_per_beam_and_display(file.BeamSequence[i+1], total_mu, display=True,
                                                          grid_resolution=grid_resolution, max_leaf_gap=max_leaf_gap, 
                                                          leaf_pair_widths=leaf_pair_widths)
    
    if display:
        grid = mudensity.get_grid(max_leaf_gap=max_leaf_gap, grid_resolution=grid_resolution, 
                                  leaf_pair_widths=leaf_pair_widths)
        mudensity.display_mu_density(grid, mu_density)
        print('Total MU density of Current Case')
        plt.show()

    return mu_density


# In[17]:


mu_density = mu_density_per_patient_and_display(file, fraction_group, display=True)
mu_density.shape


# In[27]:


np.savetxt(root + '/mu_density_dicom.txt', mu_density)


# In[ ]:




