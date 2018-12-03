# wshen created on 2018/12/3
# use bedtools to get loops that not overlapped with given region (sparse region)

loop=$1
region=$2

tail -n +2 $loop | cut -f 1,2,3  >$loop.anchor_1
tail -n +2 $loop | cut -f 4,5,6  >$loop.anchor_2

bedtools intersect -a $loop.anchor_1 -b $region -c | cut -f4  >$loop.anchor_1.count
bedtools intersect -a $loop.anchor_2 -b $region -c | cut -f4  >$loop.anchor_2.count

head -n 1 $loop >$loop.overlapped
paste $loop.anchor_1.count $loop.anchor_2.count | awk '{print $1 + $2}' >>$loop.overlapped

head -n 1 $loop >$loop.filtered
paste $loop $loop.overlapped | grep '0$' | awk -v OFS='\t' 'NF{NF--};1' >>$loop.filtered

rm $loop.anchor_1 $loop.anchor_2 $loop.anchor_1.count $loop.anchor_2.count $loop.overlapped