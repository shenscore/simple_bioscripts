from __future__ import division
import sys

import numpy as np
import glob

import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(2,1)

for i in glob.glob('*dist'):
    sample_lab = i.rsplit('.dist')[0]
    data = np.loadtxt(i)
    within_20k = data[data<=20000]
    out_10k = data[data>=10000]
    count_in_20k, bins_in_20k = np.histogram(within_20k, bins=200)
    count_in_20k = count_in_20k/len(data)#density
    bins_in_20k = 0.5*(bins_in_20k[1:]+bins_in_20k[:-1])
    ax1.plot(bins_in_20k, count_in_20k, '--', label=sample_lab)
    count_out_10k, bins_out_10k = np.histogram(out_10k, bins=10000)
    count_out_10k = count_out_10k/len(data)
    bins_out_10k = 0.5*(bins_out_10k[1:] + bins_out_10k[:-1])
    ax2.loglog(bins_out_10k, count_out_10k, '--', label=sample_lab)
    

ax1.label()
fig.savefig('test.pdf')





