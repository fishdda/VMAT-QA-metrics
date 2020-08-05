#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pymedphys, pydicom
from pymedphys import dicom


# In[2]:


from pymedphys import mudensity, fileformats


# In[3]:


import numpy as np
import pandas as pd


# In[4]:


import matplotlib.pyplot as plt


# In[5]:


root = "C:/Users/sjiae08541/Documents/Project_MU_density/data/"
filepath = root + "/19_10_28/19_10_28 15_12_20 Z 1_1.trf"
# filepath = root + "/19_10_28/19_10_28 15_29_27 Z .trf"
### Exception: Decoded table didn't pass shape test 
# Missing beam no. 8

header, table = fileformats.trf2pandas(filepath)
# header.to_csv(header_csv_filepath)
# table.to_csv(table_csv_filepath)

pd.set_option('display.max_columns', None)
table


# In[6]:


# Per Fraction


# In[7]:


def _read_beam_log_data(filepath):
    fileformats.trf2pandas(filepath)
    header, table = fileformats.trf2pandas(filepath)
    
    state = (table['Linac State/Actual Value (None)'] == 'Intersegment')
    table['Segment'] = (state.shift(1).fillna(True) > state).cumsum()
    
    beam_on = table[table['Linac State/Actual Value (None)'] == 'Radiation On']
    return beam_on


# In[8]:


# Per Segment
def calc_mu_density_per_segment_and_display(data, check_mlc=True, display=True, grid_resolution=1, max_leaf_gap=400, 
                                            leaf_pair_widths=[5]*80):
    mu = data.loc[:, 'Step Dose/Actual Value (Mu)'].to_numpy()
    mlc_1 = np.expand_dims(data.loc[:, ['Y1 Leaf ' + str(i+1) + '/Scaled Actual (mm)' 
                                        for i in range(len(leaf_pair_widths))]].to_numpy(), axis=-1)
    mlc_2 = np.expand_dims(data.loc[:, ['Y2 Leaf ' + str(i+1) + '/Scaled Actual (mm)' 
                                        for i in range(len(leaf_pair_widths))]].to_numpy(), axis=-1)
    mlc = np.append(mlc_1, mlc_2, 2)
    jaw = data.loc[:, ['X1 Diaphragm/Scaled Actual (mm)', 'X2 Diaphragm/Scaled Actual (mm)']].to_numpy() 
    jaw = np.clip(jaw, -200, 200)
    
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
    
    if display:
        grid = mudensity.get_grid(max_leaf_gap=max_leaf_gap, grid_resolution=grid_resolution,
                                  leaf_pair_widths=leaf_pair_widths)
        mudensity.display_mu_density(grid, mu_density)
        print('......MU Density of Current Segment')
        plt.show()

    return mu_density


# In[9]:


# Per Beam
def mu_density_per_beam_and_display(filepath, display=True, grid_resolution=1, max_leaf_gap=400, 
                                    leaf_pair_widths=[5]*80):
    data = _read_beam_log_data(filepath)
    
    print('......calculating segment no. 0')
    mu_density = calc_mu_density_per_segment_and_display(data[data['Segment'] == 1], check_mlc=True, 
                                                             display=True, grid_resolution=grid_resolution, 
                                                             max_leaf_gap=max_leaf_gap, 
                                                             leaf_pair_widths=leaf_pair_widths)

    if np.amax(data['Segment']) > 1:
        for i in range(np.amax(data['Segment']) - 1):
            print('......calculating segment no. ' + str(i+1))
            mu_density += calc_mu_density_per_segment_and_display(data[data['Segment'] == (i+2)], check_mlc=False, 
                                                                 display=False, grid_resolution=grid_resolution, 
                                                                 max_leaf_gap=max_leaf_gap, 
                                                                 leaf_pair_widths=leaf_pair_widths)
    
    if display:
        grid = mudensity.get_grid(max_leaf_gap=max_leaf_gap, grid_resolution=grid_resolution,
                                  leaf_pair_widths=leaf_pair_widths)
        mudensity.display_mu_density(grid, mu_density)
        print('...MU Density of Current Beam')
        plt.show()
        print('..............................................')
    
    return mu_density


# In[10]:


# Per Patient
def mu_density_per_patient_and_display(filepaths, display=True, grid_resolution=1, max_leaf_gap=400, 
                                       leaf_pair_widths=[5]*80):
    print('Starting')
    print('...calculating beam no. 0')
    mu_density = mu_density_per_beam_and_display(filepaths[0], display=True, grid_resolution=grid_resolution, 
                                                 max_leaf_gap=max_leaf_gap, leaf_pair_widths=leaf_pair_widths)


    if len(filepaths) > 1:
        for i in range(len(filepaths)-1):
            print('...calculating beam no. ' + str(i+1))
            mu_density += mu_density_per_beam_and_display(filepaths[i+1], display=True,
                                                          grid_resolution=grid_resolution, max_leaf_gap=max_leaf_gap, 
                                                          leaf_pair_widths=leaf_pair_widths)
            
    if display:
        grid = mudensity.get_grid(max_leaf_gap=max_leaf_gap, grid_resolution=grid_resolution, 
                                  leaf_pair_widths=leaf_pair_widths)
        mudensity.display_mu_density(grid, mu_density)
        print('Total MU density of Current Case')
        plt.show()
            
    return mu_density


# In[11]:


root = "C:/Users/sjiae08541/Documents/Project_MU_density/data/"
filepaths = np.char.add(root, ["/19_10_28/19_10_28 15_12_20 Z 1_1.trf", "/19_10_28/19_10_28 15_14_57 Z 2_2.trf", 
                     "/19_10_28/19_10_28 15_17_05 Z 3_3.trf", "/19_10_28/19_10_28 15_19_11 Z 4_4.trf", 
                     "/19_10_28/19_10_28 15_22_06 Z 5_5.trf", "/19_10_28/19_10_28 15_25_14 Z 6_6.trf", 
                     "/19_10_28/19_10_28 15_27_17 Z 7_7.trf", "/19_10_28/19_10_28 15_32_21 Z 9_9.trf"])

mu_density = mu_density_per_patient_and_display(filepaths, display=True)
mu_density.shape


# In[12]:


mu_density_dicom = np.loadtxt('C:/Users/sjiae08541/Documents/Project_MU_density/mu_density_dicom.txt')


# In[13]:


grid_resolution=1
max_leaf_gap=400
leaf_pair_widths=[5]*80
grid = mudensity.get_grid(max_leaf_gap=max_leaf_gap, grid_resolution=grid_resolution, 
                          leaf_pair_widths=leaf_pair_widths)

mudensity.display_mu_density(grid, - mu_density + np.flip(mu_density_dicom))


# In[ ]:





# In[14]:


### Lulu's Implementation with PyMedPhys 
from pymedphys import Delivery


# In[15]:


delivery_data = Delivery.from_logfile(filepaths[0])
mu = delivery_data.monitor_units
mlc = delivery_data.mlc
jaw = delivery_data.jaw


# In[16]:


time_range= slice(26,108,1)
mu_density = mudensity.calc_mu_density(mu[time_range], mlc[time_range],jaw[time_range])

grid_resolution=1
max_leaf_gap=400
leaf_pair_widths=[5]*80
grid = mudensity.get_grid(max_leaf_gap=max_leaf_gap, grid_resolution=grid_resolution, 
                          leaf_pair_widths=leaf_pair_widths)
mudensity.display_mu_density(grid, mu_density)


# In[ ]:




