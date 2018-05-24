# -*- coding: utf-8 -*-
"""
Created on Thu May  3 11:11:48 2018
for apa plot 
need directory contains apa matrix and measures file
@author: user
"""

import numpy as np

import matplotlib.pyplot as plt

import glob
import re


def natural_sort(l): 
    convert = lambda text: int(text) if text.isdigit() else text.lower() 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(l, key = alphanum_key)


for file in natural_sort(glob.glob('*apa')):
    figure = plt.figure()
    ax1 = figure.subplots()
    
    sample_label = file.rsplit('.apa')[0]
    measures_file = sample_label + '.measures'
    p2ll, zscoreLL = np.loadtxt(measures_file,usecols=1)[[3,5]]
    add_text = 'P2LL: ' + str(round(p2ll,2)) + '    ZscoreLL: ' + str(round(zscoreLL,2))
    data = np.loadtxt(file)
    
    q99=np.percentile(data,99)
    q05=np.percentile(data,5)
    im = ax1.matshow(data, cmap = 'Reds',vmin=q05,vmax=q99)
    figure.colorbar(im)
    #ax1=plt.gca()
    ax1.yaxis.set_visible(False)
    ax1.xaxis.tick_bottom()
    ax1.set_xticks([0,10,20])
    ax1.set_xticklabels(['-50kb','centre','50kb'])
    
    figure.suptitle(add_text)
    figure.savefig(sample_label + '.html')






