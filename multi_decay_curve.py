# -*- coding: utf-8 -*-
"""
Created on Wed Mar 21 11:02:30 2018

plot decay curve of multi .hic file


@author: wshen
"""
from __future__ import division
import sys
import straw
import numpy as np


import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt
#from matplotlib.backends.backend_pdf import PdfPages


bp_fr = sys.argv[1]
res = int(sys.argv[2])
chrsize = sys.argv[3]
pdfFile = sys.argv[4]
hicList = sys.argv[5].split(',')
labelList = sys.argv[6].split(',')


chrlist = []
with open(chrsize, 'r') as f:
    for chr in f.readlines():
        chr = chr.split("\t")[0]
        chrlist.append(chr)


dis_IF = {}
for i in range(len(hicList)):
    dis_al = []
    IF_al = []
    label = labelList[i]
    hic = hicList[i]
    dis_uni = []
    for chr in chrlist: #count all intra chromosome interaction
        
        hic_result = straw.straw('NONE', hic, chr, chr, bp_fr, res)
        hic_array = np.array(hic_result)
                
        dis_al = np.append(dis_al, hic_array[1] - hic_array[0])
        
        IF_al = np.append(IF_al, hic_array[2])
        
        
    IF_al = IF_al/sum(IF_al)
    mean_IF = []
    dis_uni = np.unique(dis_al)
    for dis in dis_uni:
        mean_IF=np.append(mean_IF, np.mean(IF_al[dis_al == dis]))
    
    dis_IF[label] = [dis_uni, mean_IF]

       
fig = plt.figure()
#ax = fig.add_subplot(111)
#ax.set_xlim(left=1e4,right=)
for k, v in dis_IF.items():
    plt.loglog(v[0], v[1], label=k, linewidth=0.7)
#for i in range(len(labelList)):
#    ax.plot(disIF[labelList[i]][0], disIF[labelList[i]][1])
    
plt.xlabel('log10(distance)')
plt.ylabel('log10(reads fraction)')
#plt.xlim(xmin=1e4)
#plt.ylim(ymax=1e-7)
plt.legend()
#ax.legend()

fig.savefig(pdfFile)

#save result as tmp
np.save("decay_curve_tmp.npy", dis_IF)
