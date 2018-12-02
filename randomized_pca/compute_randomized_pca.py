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
from scipy import sparse
from sklearn.decomposition import PCA

hic_file = sys.argv[1]
chrom = sys.argv[2]
res = sys.argv[3]
norm = sys.argv[4]

output_file = chrom + "_" + res + "_" + norm + ".oe"
dump_string = get_oe_dump + norm + " " + hic_file + " " + chrom + " " + chrom + " BP " + res + " " + output_file
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
os.system()

