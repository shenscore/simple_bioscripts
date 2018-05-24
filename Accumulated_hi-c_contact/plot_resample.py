from __future__ import division
import sys
import numpy as np
import glob

import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt
#from matplotlib.backends.backend_pdf import PdfPages

import re

def natural_sort(l): 
    convert = lambda text: int(text) if text.isdigit() else text.lower() 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(l, key = alphanum_key)

fig, ax1 = plt.subplots()
for i in natural_sort(glob.glob('*resample')):
    sample_label = i.rsplit('.resample')[0]
    data = np.loadtxt(i,skiprows=1)
    ax1.plot(data[:,0], data[:,1], '--', label = sample_label)

ax1.legend()
ax1.set_xlabel('alignabel reads')
ax1.set_ylabel('Hi-C contacts')
fig.savefig('simulated_readsNum_contactsNum.pdf')