

mnd=$1
fa=$2
o=$(basename $mnd -mnd.txt)
qsub -l nodes=1:ppn=8 -joe -N $o <<EOF
cd \$PBS_O_WORKDIR
cat $mnd | pp -j 8 perl contact_fragment_get.pl >$o.cf
cat $o.cf | pp -j 8 perl calcContactFragGC.pl >$o.gc
EOF