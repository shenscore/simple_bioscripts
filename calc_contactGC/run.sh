#!/bin/bash
script_dir=/home/shenwei/script/hic_gc
site_file=/home/shenwei/wshen/dm_hic/SRP009838/genome/dm3_DpnII.txt

mnd=$1
o=$(basename $mnd -mnd.txt)

qsub -l nodes=1:ppn=8 -joe -N $o <<EOF
cd \$PBS_O_WORKDIR
cat $mnd | parallel --pipe -k -j 8 perl ${script_dir}/contact_fragment_get.pl -s $site_file >$o.cf
cat $o.cf | parallel --pipe -k -j 8 perl ${script_dir}/calcContactFragGC.pl >$o.gc
EOF