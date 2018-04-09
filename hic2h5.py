"""
Created on Sun Mar 25 11:10:27 2018

@author: wshen
"""

from hicexplorer import HiCMatrix
import straw
import os 
import sys

hic_file = sys.argv[1]
out_h5_file = sys.argv[2]
res = int(sys.argv[3])


chr_list = ['chr2L','chr2R','chr3L','chr3R','chr4','chrX']

mat_file_list = []

#get contact file of each chromosome
for chrom in chr_list:
    tmpfile = chrom + '.tmp'
    mat_file_list.append(tmpfile)
    
    straw.printme('KR', hic_file, chrom, chrom, 'BP', res, tmpfile)
    

hicmatrix = HiCMatrix.hiCMatrix(matrixFile=mat_file_list,
                             file_format='lieberman',
                             chrnameList=chr_list)

hicmatrix.save_hdf5(out_h5_file)

for tmpfile in mat_file_list:
    os.remove(tmpfile)
