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
for i in natural_sort(glob.glob('*gc')):
    sample_label = i.rsplit('.gc')[0]
    data = np.loadtxt(i)
    count_gc, bins = np.histogram(data, bins=100, range=(0.2, 0.8))
    bins = 0.5*(bins[1:]+bins[:-1])
    count_gc = count_gc/sum(count_gc)
    ax1.plot(bins, count_gc, '--', label = sample_label)

ax1.legend()
ax1.set_xlabel('GC content')
ax1.set_ylabel('contact frequency')
fig.savefig('GCcontent_contactFrequency.pdf')
