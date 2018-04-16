#!/bin/bash

#calculate contact distance in fragment resolution
#plot as scatter plot or line plot

#need mnd file
script_dir=/home/shenwei/distance_vs_contact

mnd=$1

name=`basename $mnd -mnd.txt`
site_file=/home/shenwei/wshen/dm_hic/SRP009838/genome/dm3_DpnII.txt

qsub -N $name -joe <<EOF
cd \$PBS_O_WORKDIR
perl ${script_dir}/calc_contactDis.pl -s $site_file $mnd | sort -n| uniq -c| sed 's/^\s*//g' >$name.uniqdist
EOF