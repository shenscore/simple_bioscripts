'''
plot dups depth vs dups percentage
'''


from __future__ import division
import sys

import numpy as np
import glob

import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt
import re

def natural_sort(l): 
    convert = lambda text: int(text) if text.isdigit() else text.lower() 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(l, key = alphanum_key)


fig = plt.figure()
ax1 = fig.subplots()
for i in natural_sort(glob.glob('*dupscount')):
    sample_lab = i.rsplit('.dupscount')[0]
    data = np.loadtxt(i)
    data[:,0] = data[:,0]/sum(data[:,0])
    less_20 = data[data[:,1]<20,:]
    more_20 = [sum(data[data[:,1]>=20,0]), 20]
    ready_plot = np.append(less_20, [more_20], axis=0)
    ax1.plot(ready_plot[:,1], ready_plot[:,0],'--',label=sample_lab)

ax1.set_xlim(1,20)
ax1.set_xticks([1,5,10,15,20])
ax1.set_xticklabels(['1','5','10','15','lager than 20'])
ax1.set_xlabel('duplicate depth')
ax1.set_ylabel('percentage of matched duplicates')
ax1.legend()
fig.savefig('dups_plot.pdf')