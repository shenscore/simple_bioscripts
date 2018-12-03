# -*- coding: utf-8 -*-
"""
Created on Mon Dec  3 10:18:12 2018

@author: user
"""


import sys
import py2bit
from deeptools.utilities import getGC_content

verbose = False

two_bit_genome = sys.argv[1]
out_put = open(sys.argv[2],"w")

step = 25000
tbit = py2bit.open(two_bit_genome)
for chrom,chr_len in tbit.chroms().items():
    start = 0
    while start  <= chr_len:
        end = start + step - 1
        if end > chr_len: end = chr_len 
        try:
            gc = getGC_content(tbit,chrom,start,end)
        except Exception as detail:
            if verbose:
                print("{}:{}-{}".format(chrom, start, end))
                print(detail)
            print(chrom, "NaN", file = out_put)
            start += step
            continue
        
        print(chrom, gc, file = out_put)
        start += step
