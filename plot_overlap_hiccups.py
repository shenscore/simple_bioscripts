# -*- coding: utf-8 -*-
"""
Created on Wed Apr 25 17:14:19 2018

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


figure = plt.figure(figsize=(28,5))
plt.suptitle("Correlation of P2LL ratio of peaks overlaped with PF0")
axs = figure.subplots(1,5,sharey=True)
axs = axs.reshape(1,5)
axs_count = 0
pearson_value = []
up_down = []
for file in natural_sort(glob.glob('*overlaped.bedpe')):
    score_label=file.rsplit('.overlaped.bedpe')[0].rsplit('_')[1]
    score = np.loadtxt(file,usecols=[6,7])
    pearson_corr = round(np.corrcoef(score[:,0], score[:,1])[0,1],2)
    pearson_value.append(pearson_corr)
    pearson_corr = "r = " + pearson_corr.astype(str)
    
    cur_axs = axs[0,axs_count]
    up_diag = score[:,1] < score[:,0]
    up_diag_num = len(score[:,1][up_diag])
    
    down_diag = score[:,1] > score[:,0]
    down_diag_num = len(score[:,1][down_diag])
    
    up_down_ratio = round(up_diag_num/down_diag_num,2)
    up_down.append(up_down_ratio)
    up_down_ratio = 'up/down = ' + str(up_down_ratio)
    
    cur_axs.scatter(score[:,1][score[:,1] < score[:,0]],score[:,0][score[:,1] < score[:,0]],s=2,c='#C0504D')
    cur_axs.scatter(score[:,1][score[:,1] > score[:,0]],score[:,0][score[:,1] > score[:,0]],s=2,c='#1F497D')
    cur_axs.scatter(score[:,1][score[:,1] == score[:,0]],score[:,0][score[:,1] == score[:,0]],s=2)
    cur_axs.set_xlabel(score_label)
    cur_axs.set_xlim([0,20])
    cur_axs.set_ylim([0,20])
    cur_axs.set_yticks([0,5,10,15,20])
    cur_axs.set_xticks([0,5,10,15,20])
    cur_axs.plot(cur_axs.get_xlim(), cur_axs.get_ylim(), ls="--", c=".3",linewidth=0.5)
    
    #cur_axs.set_xticks([0,0.5,1,1.5,2])
    #cur_axs.text(2.5,17.5,up_down_ratio)
    #cur_axs.text(2.5,16.5,pearson_corr)
    axs_count += 1

figure.savefig('P2LL_correlation_of_overlaped_peaks.png',dpi=300)
np.savetxt('overlapped_measures.txt',np.array([pearson_value,up_down]),header = 'row1: pearson; row2: up/down')

'''
plot p2bl score of PF0 peaks that NOT overlapped with each library
'''

figure = plt.figure(figsize=(28,5))
plt.suptitle("Correlation of P2LL ratio of peaks in PF0 that not overlaped with each library")
axs = figure.subplots(1,5,sharey=True)
axs = axs.reshape(1,5)
tad_score = []
tad_label = []
pearson_value = []
up_down = []
axs_count = 0
for file in natural_sort(glob.glob('PF0*score')):
    score_label=file.rsplit('.not_overlapped.p2bl.score')[0].rsplit('_')[1]
    score = np.loadtxt(file,skiprows=1)
    pearson_corr = round(np.corrcoef(score[:,0], score[:,1])[0,1],2)
    pearson_value.append(pearson_corr)
    pearson_corr = "r=" + pearson_corr.astype(str)
    
    up_diag = score[:,1] < score[:,0]
    up_diag_num = len(score[:,1][up_diag])
    
    down_diag = score[:,1] > score[:,0]
    down_diag_num = len(score[:,1][down_diag])
    
    up_down_ratio = round(up_diag_num/down_diag_num,2)
    up_down.append(up_down_ratio)
    up_down_ratio = 'up/down = ' + str(up_down_ratio)
    
    cur_axs = axs[0,axs_count]
    
    cur_axs.scatter(score[:,1][score[:,1] < score[:,0]],score[:,0][score[:,1] < score[:,0]],s=2,c='#C0504D')
    cur_axs.scatter(score[:,1][score[:,1] > score[:,0]],score[:,0][score[:,1] > score[:,0]],s=2,c='#1F497D')
    cur_axs.scatter(score[:,1][score[:,1] == score[:,0]],score[:,0][score[:,1] == score[:,0]],s=2)
    
    cur_axs.set_xlabel(score_label)
    cur_axs.set_xlim([0,20])
    cur_axs.set_ylim([0,20])
    cur_axs.set_yticks([0,5,10,15,20])
    cur_axs.set_xticks([0,5,10,15,20])
    cur_axs.plot(cur_axs.get_xlim(), cur_axs.get_ylim(), ls="--", c=".3",linewidth=0.5)
    #cur_axs.set_xticks([0,0.5,1,1.5,2])
    #cur_axs.text(8,1,up_down_ratio)
    axs_count += 1

figure.savefig('P2LL_correlation_of_NOToverlaped_peaks.png',dpi=300)
np.savetxt('Not_overlapped_measures.txt',np.array([pearson_value,up_down]),header = 'row1: pearson; row2: up/down')