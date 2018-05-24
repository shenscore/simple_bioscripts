# -*- coding: utf-8 -*-
"""
Created on Thu Apr 19 16:32:25 2018
eigen value plot
@author: user
"""

import numpy as np


import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt
import glob
import re
from scipy.stats import iqr

def natural_sort(l): 
    convert = lambda text: int(text) if text.isdigit() else text.lower() 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(l, key = alphanum_key)

def outliers(data, m=1.5):
    return([np.mean(data) + m * iqr(data),np.mean(data) - m * iqr(data)])

figure = plt.figure(figsize=(4,6))
ax1 = figure.subplots()


eigen_score = []
eigen_label = []
q95 = []
q05 = []
up_out = []
below_out = []
for file in natural_sort(glob.glob('*value')):
    eigen_label.append( file.rsplit('.adjusted.value')[0])
    eigen = np.loadtxt(file,skiprows=1)
    eigen[np.isnan(eigen)] = 0
    eigen_score.append(eigen)
    
    up_outlier, below_outlier = outliers(eigen)
    up_out.append(up_outlier)
    below_out.append(below_outlier)
    #q95.append(np.percentile(eigen,95))
    #q05.append(np.percentile(eigen,5))

violin_bodies = ax1.violinplot(eigen_score,showextrema=False)

for pc in violin_bodies['bodies']:
    pc.set_facecolor('#1F497D')
    #pc.set_edgecolor('black')
    pc.set_alpha(1)

up_all = []
#caps_all = ax1.boxplot(eigen_score,showfliers=False)['caps']
#up_all = [caps_all[x] for x in range(1,len(caps_all),2)]
#below_all = [caps_all[x] for x in range(0,len(caps_all),2)]
#up_all = [x.get_ydata()[0] for x in up_all]
#below_all = [x.get_ydata()[0] for x in below_all]

#x_of_caps = [np.mean(caps_all[x].get_xdata()) for x in range(1,len(caps_all),2)]


#ax1.plot(x_of_caps,up_all,'--',color = 'pink')
#ax1.plot(x_of_caps,below_all,'--',color = 'pink')
ax1.plot([1,2,3,4,5,6],up_out,lw=1,color='#C0504D')
ax1.plot([1,2,3,4,5,6],below_out,lw=1,color='#C0504D')
ax1.set_xticks([1,2,3,4,5,6])
ax1.set_xticklabels([])
ax1.axhline(ls='--',color='grey',lw=1)
ax1.set_title("distribution of eigenvector value")
ax1.set_ylim([-0.08,0.08])
figure.savefig('eigen_violin.png',dpi=300)


#################

figure = plt.figure(figsize=(15,10))
plt.suptitle("eigenvector correlation with PF0")
axs = figure.subplots(2,3,sharey=True)
axs = axs.reshape(1,6)
eigen_pf0 = np.loadtxt('PF0.adjusted.value',skiprows=1)
eigen_pf0[np.isnan(eigen_pf0)] = 0


axs_count = 0
for file in natural_sort(glob.glob('*value')):
    eigen_label = file.rsplit('.adjusted.value')[0]
    eigen = np.loadtxt(file,skiprows=1)
    eigen[np.isnan(eigen)] = 0
    pearson_corr = np.corrcoef(eigen, eigen_pf0)[0,1]
    pearson_corr = round(pearson_corr,2)
    pearson_corr = "r = " + pearson_corr.astype(str)
    
    direct_pf0 = eigen_pf0 > 0
    direct_eigen = eigen > 0
    direct_changed = len(eigen[direct_eigen != direct_pf0])
    changed_ratio = round(direct_changed/len(eigen),2)
    changed_ratio = "changed ratio : " + str(changed_ratio)
    
    cur_axs = axs[0,axs_count]
    cur_axs.scatter(eigen,eigen_pf0,s=1)
    cur_axs.set_xlabel(eigen_label)
    cur_axs.text(-0.1,0.1,pearson_corr)
    cur_axs.axhline(color='black',linestyle='--',linewidth=0.5)
    cur_axs.axvline(color='black',linestyle='--',linewidth=0.5)
    cur_axs.text(0.01,-0.1,changed_ratio)
    #cur_axs.set_xticks([0,0.5,1,1.5,2])
    #cur_axs.text(0.5,1.5,pearson_corr)
    axs_count += 1

figure.savefig('eigen.pdf')




#eigen vector correlation between replicates


figure = plt.figure(figsize=(15,10))
plt.suptitle("eigenvector correlation with PF0")
axs = figure.subplots(2,3,sharey=True)
axs = axs.reshape(1,6)



axs_count = 0
for file in natural_sort(glob.glob('*rep1.adjusted.value')):
    eigen_label = file.rsplit('.rep1.adjusted.value')[0]
    eigen_rep1 = np.loadtxt(file, skiprows=1)
    
    file_2 = eigen_label + ".rep2.adjusted.value"
    
    eigen_rep2 = np.loadtxt(file_2, skiprows=1)
    
    eigen_rep1[np.isnan(eigen_rep1)] = 0
    eigen_rep2[np.isnan(eigen_rep2)] = 0
    
    pearson_corr = np.corrcoef(eigen_rep1, eigen_rep2)[0,1]
    pearson_corr = round(pearson_corr,2)
    pearson_corr = "r = " + pearson_corr.astype(str)
    
    direct_rep1 = eigen_rep1 > 0
    direct_rep2 = eigen_rep2 > 0
    direct_changed = len(eigen[direct_rep1 != direct_rep2])
    changed_ratio = round(direct_changed/len(eigen_rep1),2)
    changed_ratio = "changed ratio : " + str(changed_ratio)
    
    cur_axs = axs[0,axs_count]
    cur_axs.scatter(eigen_rep1,eigen_rep2,s=1)
    cur_axs.set_xlabel(eigen_label)
    cur_axs.text(-0.1,0.1,pearson_corr)
    cur_axs.axhline(color='black',linestyle='--',linewidth=0.5)
    cur_axs.axvline(color='black',linestyle='--',linewidth=0.5)
    cur_axs.text(0.01,-0.1,changed_ratio)
    #cur_axs.set_xticks([0,0.5,1,1.5,2])
    #cur_axs.text(0.5,1.5,pearson_corr)
    axs_count += 1

figure.savefig('eigen_rep.pdf')




#ks test


import scipy

eigen_label=[]
eigen_score=[]
for file in natural_sort(glob.glob('*value')):
    eigen_label.append( file.rsplit('.adjusted.value')[0])
    eigen = np.loadtxt(file,skiprows=1)
    eigen[np.isnan(eigen)] = 0
    eigen_score.append(eigen)


scipy.stats.wilcoxon(eigen_score[0],eigen_score[1])[1]
















