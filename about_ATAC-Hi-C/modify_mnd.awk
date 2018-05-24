#!/usr/bin/awk -f

#this script will simply change each line of mnd.file
#replace frag1 and frag2 by 0 and 1
#further: may need consider to judge the intra-chromosome interact distance

{
    $4=0;
    $8=1;
    print $0;
}
