'''
this will calculate hic contact rate with certain sampled reads
input is simplify.txt file generate by other script
wshen
2018/4/9
'''
from __future__ import division
import matplotlib
matplotlib.use('agg')

import matplotlib.pyplot as plt
import numpy as np
import sys

data=np.loadtxt(sys.argv[1])
plotname = sys.argv[2]
plottmp = sys.argv[3]
simulTimes=100
simulSizes=range(30000000,300000000,30000000)

x_to_plot=[]
y_to_plot=[]

for sampleSize in simulSizes :
    if(len(data) < sampleSize) : break
    x_to_plot.append(sampleSize)
    tmp_list = []
    for i in range(simulTimes) :
        sample = np.random.choice(data, size=sampleSize, replace=False)
        # belowmapqRate = len(sample[sample == '0'])/sampleSize
        uniqueRate = len(np.unique(sample[sample != '0']))/sampleSize
        tmp_list.append(uniqueRate)
    uniqRatemean = np.mean(tmp_list)
    y_to_plot.append(uniqRatemean)

# x_to_plot = np.array(x_to_plot)
# y_to_plot = np.array(y_to_plot)
to_save = np.array([x_to_plot, y_to_plot])
np.save(plottmp, to_save)
figure = plt.figure()
plt.plot(x_to_plot, y_to_plot)
figure.savefig(plotname)





