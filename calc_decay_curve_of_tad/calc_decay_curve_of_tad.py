'''
This script will calculate aggregate decay curve of each tad list.
input: .hic file, .bed file (tad)
'''
from __future__ import division
import straw

import numpy as np
import sys
from os.path import basename

hic_file = sys.argv[1]
out_file = basename(hic_file).split('.hic')[0] + '.tad_decay.tmp'
tad_file = sys.argv[2]
#get contact within each tad
dis_al = []
tad_contact_al = []
dis_uni = []
tad = np.loadtxt(tad_file, dtype={'names':('chr','start','end'), 'formats':('S6','int32','int32')})
chr_list = np.unique(tad['chr'])
all_contact = 0
for chr in chr_list:
    hic_result = straw.straw("KR", hic_file, chr, chr, 'BP', 1000)
    hic_array = np.array(hic_result)
    hic_array[2,np.isnan(hic_array[2])] = 0
    hic_array = np.core.records.fromarrays(hic_array,names='start,end,contact',formats='int32,int32,float64')
    all_contact += np.sum(hic_array['contact'])

    tad_sub = tad[ tad['chr'] == chr ]
    for tad_start, tad_end in tad_sub[['start','end']]:
        condition_1 = hic_array['start'] >= tad_start
        condition_2 = hic_array['end'] >= tad_start
        condition_3 = hic_array['start'] <= tad_end
        condition_4 = hic_array['end'] <= tad_end

        contact_index = np.logical_and(np.logical_and(condition_1, condition_2),np.logical_and(condition_3, condition_4))

        tad_contact = hic_array[contact_index]
        dis_al = np.append(dis_al, np.abs(tad_contact['end'] - tad_contact['start']))
        tad_contact_al = np.append(tad_contact_al, tad_contact['contact'])

IF_al = tad_contact_al/np.sum(all_contact)
mean_IF = []
dis_uni = np.unique(dis_al)
for dis in dis_uni:
    mean_IF=np.append(mean_IF, np.mean(IF_al[dis_al == dis]))
    
out_stat = np.transpose([dis_uni, mean_IF])
np.savetxt(out_file, out_stat)