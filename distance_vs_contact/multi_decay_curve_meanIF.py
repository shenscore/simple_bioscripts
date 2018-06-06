# -*- coding: utf-8 -*-
"""
Created on Wed Mar 21 11:02:30 2018

plot decay curve of multi .hic file use 1000 res, KR normalization


@author: wshen
"""
from __future__ import division
import sys
import straw
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

res = 1000
chrsize = sys.argv[1]
pdfFile = '1k_res_decay_curve.pdf'
# hicList = sys.argv[5].split(',')
# labelList = sys.argv[6].split(',')
chrlist = []
with open(chrsize, 'r') as f:
    for chr in f.readlines():
        chr = chr.split("\t")[0]
        chr = chr.rsplit("chr")[1]
        chrlist.append(chr)


dis_IF = {}
for i in natural_sort(glob.glob('*1k.hic')):
    sample_label = i.rsplit('.1k.hic')[0]
    
    dis_al = []
    IF_al = []
    dis_uni = []
    bin_num_chr = [] #bin number of each chromosome
    for chr in chrlist: #count all intra chromosome interaction
        
        hic_result = straw.straw("KR", i, chr, chr, 'BP', res)
        hic_array = np.array(hic_result)
        hic_array[2,np.isnan(hic_array[2])] = 0
        hic_array = np.core.records.fromarrays(hic_array,names='start,end,contact',formats='int32,int32,float64')
        IF_al = np.append(IF_al, hic_array['contact'])


        dis_al = np.append(dis_al, hic_array['end'] - hic_array['start'])

        bin_num = np.max([hic_array['start'], hic_array['end']])/res + 1

        bin_num_chr = np.append(bin_num_chr, bin_num)

    IF_al = IF_al/sum(IF_al)
    mean_IF = []
    dis_uni = np.unique(dis_al)
    for dis in dis_uni:
        sum_IF = np.sum(IF_al[dis_al == dis])
        dis_bin = dis/res
        bin_count =  np.array([x - dis_bin for x in bin_num_chr])
        dis_entry = np.sum(bin_count[bin_count > 0])

        mean_IF = np.append(mean_IF, sum_IF/dis_entry)

    
    dis_IF[sample_label] = np.transpose([dis_uni, mean_IF])


       
fig, (ax1, ax2) = plt.subplots(2,1)
fig.set_figheight(10)
fig.set_figwidth(15)

for k, v in dis_IF.items():
    within_20k = v[v[:,0]<=20000,:]
    out_10k = v[v[:,0]>=10000,:]
    ax1.semilogy(within_20k[:,0], within_20k[:,1], label=k)
    ax2.loglog(out_10k[:,0], out_10k[:,1], label=k)
    
ax2.set_xlabel('interaction distance')
ax2.legend()
ax1.set_ylabel('mean interaction frequency')
ax2.set_ylabel('mean interaction frequency')
# fig.suptitle('decay curve')
#plt.xlim(xmin=1e4)
#plt.ylim(ymax=1e-7)

fig.savefig(pdfFile)

#save result as tmp
np.save("decay_curve_tmp.npy", dis_IF)
