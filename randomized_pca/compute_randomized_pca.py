# -*- coding: utf-8 -*-
"""
Created on Sat Dec  1 23:48:39 2018

@author: user
"""

juice_box = "java -jar /home/shenwei/00.soft/juicer_tools.1.7.6_jcuda.0.8.jar" #predefined
get_oe_dump = juice_box + " dump oe "


import sys
import os
import numpy as np
import pandas as pd
from scipy import sparse
from scipy.stats import pearsonr
from sklearn.decomposition import PCA

if len(sys.argv) < 7:
    exit("please give the correct argument.")

hic_file = sys.argv[1]
chrom = sys.argv[2]
res = int(sys.argv[3])
norm = sys.argv[4]
gc_vector = sys.argv[5]
out_f = sys.argv[6]

output_file = chrom + "_" + str(res) + "_" + norm + ".oe"
dump_string = get_oe_dump + norm + " " + hic_file + " " + chrom + " " + chrom + " BP " + str(res) + " " + output_file
os.system(dump_string)

oe_mat = np.loadtxt(output_file)
oe_mat = np.nan_to_num(oe_mat)

oe_mat = sparse.csc_matrix((oe_mat[:,2],((oe_mat[:,0]/res).astype(int),(oe_mat[:,1]/res).astype(int))))
diag = sparse.csc_matrix((oe_mat.diagonal(),(range(oe_mat.shape[0]),range(oe_mat.shape[0]))))
oe_mat = oe_mat.transpose() + oe_mat - diag

pca = PCA(n_components = 3, svd_solver = 'randomized')
pca.fit(oe_mat.todense())

#
V = pca.components_ 
#

data = pd.read_csv(gc_vector, sep=" ", header=None, names=['chrom','gc'])
chrom_gc = data.gc[data.chrom == chrom]

corr1 = abs(pearsonr(V[0],chrom_gc)[0])
corr2 = abs(pearsonr(V[1],chrom_gc)[0])
corr3 = abs(pearsonr(V[2],chrom_gc)[0])
max_cor = max(corr1,corr2,corr3)

if max_cor == corr1:
    component = V[0]
elif max_cor == corr2:
    component = V[1]
else:
    component = V[2]

np.savetxt(out_f,component)
