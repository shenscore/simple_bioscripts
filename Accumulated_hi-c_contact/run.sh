#need merged_sort.txt file

qsub -o $PWD/log -j oe -N osplit <<- DEDUP
    source $usePath
    $load_cluster
    awk -v dir=$PWD -f split.awk $outputdir/merged_sort.txt
DEDUP

while [ ! -e mysplit_done ]
    do
        sleep 60
done
rm mysplit_done

#submit dups.awk job after split_rmdups.awk
waitstring='-W depend=afterokarray'
array=`ls $PWD/my_split* | sed 's/.*split//g' | sort -n | xargs | awk -vOFS='-' '{print $1,$NF}'`
split_end=`ls $PWD/my_split* | sed 's/.*split//g' | sort -n | xargs | awk  '{print $NF}'`
jobarray_id=`qsub -t $array -o $PWD/check_uniq.log -j oe -N check_uniq <<- SPLITDEDUP
    awk -f check_uniq.awk -v name=\\${PBS_ARRAYID} $PWD/my_split\\${PBS_ARRAYID} > \\${PBS_ARRAYID}.uniq
    rm $PWD/my_split\\${PBS_ARRAYID}
SPLITDEDUP`

wait
#start cats and remove split files
qsub $waitstring -j oe -o $PWD/cat.log -N catsplit <<- CATSPLIT
    for i in \\$(seq 0 $split_end)
    do
        cat $PWD/\\${i}.uniq >>$PWD/simplified.txt
    done
    rm $PWD/*uniq
CATSPLIT