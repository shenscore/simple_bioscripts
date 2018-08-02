hic_file=$1
res=$2
chr=$3
norm='KR'

straw KR $hic_file $chr $chr BP $res | awk -v chr=$chr -v res=$res 'BEGIN{max=0}{if($3 == "nan"){$3=0}i=$1/res;j=$2/res;a[i,j]=$3;a[j,i]=$3;if(max < j){max=j}}END{for(i=1;i<=max+1;i++){printf "\t%s-bin%s",chr,i }print;for(i=0;i<=max;i++){printf "%s-bin%s",chr,i+1;for(j=0;j<=max;j++){if((i,j) in a){printf "\t%s", a[i,j]}else{printf "\t0"}}print}}'
