#need merged_sort.txt file
script_dir=/home/shenwei/script/hic_resample
qsub -j oe -N check_uniq_for_one -l mem=8g <<- DEDUP
    awk  -f ${script_dir}/check_uniq.for_one.awk $PWD/merged_sort.txt |sort -n |uniq -c |sed 's/^\s*//g' >$simplify.txt
DEDUP
