#!/bin/bash
# pipeline to calculate border strength (KR normalized)
# input : hicfile resolusion
# need exec file straw in your path

hic_file=$1
res=$2
chrList=(Chr01 Chr02 Chr03 Chr04 Chr05 Chr06 Chr07 Chr08 Chr09 Chr10)

name=$(basename $hic_file .hic)


for chr in ${chrList[*]}
do
  echo "fixedStep chrom=$chr start=1 step="${res}" span="${res} > $name.$chr.border_strength.wig
  straw KR $hic_file $chr $chr BP $res | calc_corder_strength.awk -v res=$res >> $name.$chr.border_strength.wig
done

cat $name.*.border_strength.wig >$name.all.border_strength.wig
