'''
use pandas to do statistics of tad file (bedpe format)

wshen
2018/4/9
'''

import numpy as np
import matplotlib.pyplot as plt
import sys
import glob
import re
import pandas as pd
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
data = pd.read_table('',header=None)
ax1 = data.sort_values(1,ascending=False).plot(kind='bar',x=0,legend=False,title="TAD number of each library")
ax1.set_xlabel('')
fig = ax1.get_figure()
fig.savefig('tadNum.pdf')

#tad size distribution

figure = plt.figure(figsize=(15,5))
ax1,ax2 = figure.subplots(1,2)
tad_size = []

tad_label = []
for file in natural_sort(glob.glob('*tadsize')):
    tad_label.append( file.rsplit('.tadsize')[0])
    tad_one_size = np.loadtxt(file)
    tad_size.append(tad_one_size)
    #counts, bins = np.histogram(tad_one_size)
    #bins = 0.5*(bins[1:]+bins[:-1])
    #print(bins)
    #ax1.plot(bins, counts, label = file.rsplit('.tadsize')[0])
    x_val, count_val = np.unique(tad_one_size, return_counts=True)
    cum_val = np.cumsum(count_val/len(tad_one_size))
    ax1.plot(x_val, cum_val, label = file.rsplit('.tadsize')[0])



#ax1.hist(tad_size,label=tad_label,bins=[0,2e4,5e4,1e5,2e5,8e5])
ax1.legend(['Non-amplified','4 cycles','8 cycles','12 cycles','16 cycles','20 cycles'],frameon=False)
#ax1.set_xlim(xmax=600000)
ax1.set_ylabel('cumulative TAD ratio')
ax1.set_xlabel('TAD size')
#ax1.set_xticklabels()
ax1.set_title("TAD size distribution")


df = pd.DataFrame(data=[[0.63332,0.582938,0.572222,0.560966,0.419956,0.140345]],columns=['Non-amplified','4 cycles','8 cycles','12 cycles','16 cycles','20 cycles'])
df = df.T
df.plot.bar(legend=False,ax=ax2)
ax2.set_xlabel('')
ax2.spines['right'].set_visible(False)
ax2.spines['top'].set_visible(False)

ax2.set_yticks([0,0.2,0.4,0.6])
ax2.set_yticklabels(['0','20','40','60'])


ax2.set_ylabel("Genome Covered by Identified TADs(%)")
for tick in ax2.get_xticklabels():
        tick.set_rotation(45)
        tick.set_ha('right')

#for p in ax2.patches:
#    ax2.annotate(str(round(p.get_height(),2)), (p.get_x() * 1.005, p.get_height() * 1.005))
#ax2.set_title("ratio of TAD to whole genome")
figure.savefig('TAD_size.pdf')



'''
score corelation of TADs overlapped with PF0
'''
figure = plt.figure(figsize=(15,5))
plt.suptitle("Correlation of PF0 domain score between each library ")
axs = figure.subplots(1,5,sharey=True)
axs = axs.reshape(1,5)
tad_score = []
tad_label = []
axs_count = 0
for file in natural_sort(glob.glob('PF0*overlap')):
    tad_label=file.rsplit('.overlap')[0].rsplit('_')[1]
    tad_corner_score = np.loadtxt(file,usecols=[3,7])
    pearson_corr = np.corrcoef(tad_corner_score[:,0], tad_corner_score[:,1])[0,1]
    pearson_corr = "r=" + pearson_corr.astype(str)
    
    cur_axs = axs[0,axs_count]
    cur_axs.scatter(tad_corner_score[:,1],tad_corner_score[:,0],s=1)
    cur_axs.set_xlabel(tad_label)
    #cur_axs.set_xticks([0,0.5,1,1.5,2])
    #cur_axs.text(0.5,1.5,pearson_corr)
    axs_count += 1

figure.savefig('tad_score_correlation.pdf')


















