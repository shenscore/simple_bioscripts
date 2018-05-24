# -*- coding: utf-8 -*-
"""
Created on Tue Apr 24 09:11:11 2018

plot tad decay curve

@author: wshen
"""

import numpy as np


import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt
import glob
import re


def natural_sort(l): 
    convert = lambda text: int(text) if text.isdigit() else text.lower() 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(l, key = alphanum_key)


figure = plt.figure()
ax1 = figure.subplots()


for file in natural_sort(glob.glob('*tad_decay.tmp')):
    sample_label = file.rsplit('.1k.tad_decay.tmp')[0]
    data = np.loadtxt(file)
    ax1.semilogy(data[:,0],data[:,1],'--',label = sample_label)

ax1.set_xlim([1000,20000])
ax1.set_ylim([1e-2,15e-2])
ax1.set_xlabel('interaction distance')
ax1.set_ylabel('interaction frequency within TAD')
ax1.legend()
#ax1.set_title("distribution of eigenvector value")
figure.savefig('tad_decay_curve.pdf')



#for mean IF
figure = plt.figure()
ax1 = figure.subplots()


for file in natural_sort(glob.glob('*tad_decay.tmp')):
    sample_label = file.rsplit('.1k.tad_decay.tmp')[0]
    data = np.loadtxt(file)
    ax1.semilogy(data[:,0],data[:,1],'--',label = sample_label)

ax1.set_xlim([5000,100000])
ax1.set_ylim([2e-8,3e-7])
ax1.set_xlabel('interaction distance')
ax1.set_ylabel('mean interaction frequency within TAD')
#ax1.spines['right'].set_visible(False)
#ax1.spines['top'].set_visible(False)
ax1.legend(frameon=False)
#ax1.set_title("distribution of eigenvector value")
figure.savefig('tad_decay_curve.pdf')