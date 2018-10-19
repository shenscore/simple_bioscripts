# -*- coding: utf-8 -*-
"""
Created on Fri Oct 19 11:02:30 2018
plot decay curve of pre-computed decay curve data
input1: file seperated by ","
input2: labels seperated by ","
input3: fig_file
@author: wshen
"""
#from __future__ import division
import sys
import numpy as np
import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt
#from matplotlib.backends.backend_pdf import PdfPages


dist_count_list = sys.argv[1].split(',')
labelList = sys.argv[2].split(',')
pdfFile = sys.argv[3]


# set bins to bining data
#bins = np.linspace(1e4,1e6,101)

fig = plt.figure(figsize=(8,5))
for i in range(len(dist_count_list)):
    label           = labelList[i]
    dist_count_file = dist_count_list[i]
    data                 = np.loadtxt(dist_count_file) # read file 
    data                 = data[data[:,0] >= 1e4,:]    # extract region from
    data                 = data[data[:,0] <= 1e6,:]    # 1e4 to 1e6
    
    plt.loglog(data[:,0], data[:,1], label=label, linewidth=0.7) # plot log-log scale 

       
plt.xticks([1e4,1e5,1e6],['10k','100k','1mb'])
plt.xlabel('Distance')
plt.ylabel('Interact Frequency')
#plt.xlim(xmin = 4 ,xmax = 8)
#plt.ylim(ymax=1e-7)
plt.legend()
fig.savefig(pdfFile)
