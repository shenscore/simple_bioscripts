hic_file=$1
name=$(basename $hic_file .hic)
# chromosome list
chr_list=(1 2 3 4 5 6 7 8 9 10)
res=5000
norm='KR'
#err_test=$(straw $norm $hic_file ${chr_list[0]} ${chr_list[0]} BP $res | cut -f3 | uniq | wc -l)
#if [ $err_test -eq 1 ]; then
#  norm='VC'
#fi
for chr in ${chr_list[@]}
do
  straw $norm $hic_file $chr $chr BP $res | awk -v res=$res -f calc_decay_curve.awk >$name.$chr.$res.tmp 
done

awk -v res=$res -f merge_chr_IF.awk $name.*.$res.tmp >$name.$res.decay.out
rm $name.*.$res.tmp
