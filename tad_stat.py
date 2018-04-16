'''
use pandas to do statistics of tad file (bedpe format)

wshen
2018/4/9
'''

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sys
import glob
import re

def natural_sort(l): 
    convert = lambda text: int(text) if text.isdigit() else text.lower() 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(l, key = alphanum_key)


#corner_score of each library
figure = plt.figure(figsize=(15,5))
ax1,ax2 = figure.subplots(1,2,sharey=True)
tad_score = []
tad_label = [0]
for file in natural_sort(glob.glob('*bedpe')):
    tad_label.append( file.rsplit('.bedpe')[0])
    tad_corner_score = np.loadtxt(file,usecols=[11],skiprows=1)
    tad_score.append(tad_corner_score)

ax1.violinplot(tad_score)
ax1.set_xticklabels(tad_label)
ax1.set_title("Arrowhead corner score of each library")


#corner_score of domains found in PF0 of each library
#figure = plt.figure()
tad_score = []
tad_label = [0]
for file in natural_sort(glob.glob('*pf0tad')):
    tad_label.append( file.rsplit('.pf0tad')[0])
    tad_corner_score = np.loadtxt(file,usecols=[11],skiprows=1)
    tad_score.append(tad_corner_score)

ax2.violinplot(tad_score)
ax2.set_xticklabels(tad_label)
ax2.set_title("Arrowhead corner score of domains found in PF0")



#correlation with domain score of pf0
figure = plt.figure(figsize=(15,10))
plt.suptitle("Correlation of PF0 domain score between each library ")
axs = figure.subplots(2,3,sharey=True)
axs = axs.reshape(1,6)
pf0_score = np.loadtxt('PF0.pf0tad',usecols=[11],skiprows=1)
tad_score = []
tad_label = []
axs_count = 0
for file in natural_sort(glob.glob('*pf0tad')):
    tad_label=file.rsplit('.pf0tad')[0]
    tad_corner_score = np.loadtxt(file,usecols=[11],skiprows=1)
    pearson_corr = np.corrcoef(tad_corner_score, pf0_score)[0,1]
    pearson_corr = "p=" + pearson_corr.astype(str)
    
    cur_axs = axs[0,axs_count]
    cur_axs.scatter(tad_corner_score,pf0_score,s=1)
    cur_axs.set_xlabel(tad_label)
    cur_axs.set_xticks([0,0.5,1,1.5,2])
    #cur_axs.text(0.5,1.5,pearson_corr)
    axs_count += 1
    
#

