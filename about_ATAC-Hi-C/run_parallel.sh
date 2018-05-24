#!/bin/bash
mnd=$1
out=$2
script_dir=
qsub -N modify_mnd -joe -l nodes=1:ppn=8 <<EOF
cd \$PBS_O_WORKDIR
cat $mnd | parallel --pipe -k -j 8 ${script_dir}/modify_mnd.awk  >$out
EOF