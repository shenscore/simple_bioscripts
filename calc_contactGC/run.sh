#!/bin/bash
script_dir=/home/shenwei/script/hic_gc
mnd=$1
o=$(basename $mnd -mnd.txt)
qsub -l nodes=1:ppn=8 -joe -N $o <<EOF
cd \$PBS_O_WORKDIR
cat $mnd | parallel --pipe -k -j 8 perl ${script_dir}/contact_fragment_get.pl >$o.cf
cat $o.cf | parallel --pipe -k -j 8 perl ${script_dir}/calcContactFragGC.pl >$o.gc
EOF