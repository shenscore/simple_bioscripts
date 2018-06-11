#!/usr/bin/awk -f
#find overlapped loops and calc observed/expected_bottom_left ratio
BEGIN {
    i=0;
    j=0;
    OFS="\t";
}

FILENAME == ARGV[1] && FNR > 1 {
    ratio_1[i]=$8/$9
    loop1[i]=$1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6;
    i++;

}

FILENAME == ARGV[2] && FNR > 1 {
    ratio_2[j]=$8/$9
    loop2[j]=$1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6;
    j++;
}

END{
    for (z=0; z<i; z++){
        for (m=0; m<j; m++){
            if (loop1[z] == loop2[m]){
                print loop1[z],ratio_1[z],ratio_2[m];
            }
        }
    }
}
