#!/usr/bin/awk -f
# this is a modified script of dup.awk(juicer)

function abs(v) {
	return v<0?-v:v;
}
# Examines loc1 and loc2 to see if they are within wobble1
# Examines loc3 and loc4 to see if they are within wobble2
# If both are within wobble limit, they are "tooclose" and are dups
function tooclose(loc1,loc2,loc3,loc4) {
	if (abs(loc1-loc2)<=wobble1 && abs(loc3-loc4)<=wobble2) {
		return 1;
	}
	else if (abs(loc3-loc4)<=wobble1 && abs(loc1-loc2)<=wobble2) {
		return 1;
	}
	else return 0;
}

function optcheck(tile1,tile2,x1,x2,y1,y2) {
	if (tile1==tile2 && abs(x1-x2)<50 && abs(y1-y2)<50){
		return 1;
	}
	else return 0;
}

# Executed once, before beginning the file read
BEGIN {
	i=0;
	wobble1=4;
	wobble2=4;
    uniq=0;
}
# strand, chromosome, fragment match previous; first position (sorted) within wobble1

$1 == p1 && $2 == p2 && abs($3-p3)<=wobble1 && $4 == p4 && $5 == p5 && $6 == p6 && $8 == p8  {
	# add to array of potential duplicates
	pos1[i]=$3;
	pos2[i]=$7;
    mapq1[i]=$9;
    mapq2[i]=$12;
	i++;
}
# not a duplicate, one of the fields doesn't match
$1 != p1 || $2 != p2 || $4 != p4 || $5 != p5 || $6 != p6 || $8 != p8 || abs($3-p3)>wobble1 {
	
    
    for (j=0; j<i; j++) {
        # only consider reads that aren't already marked duplicate
        # (no daisy-chaining)
        
        if (!(j in dups) || !(j in belowmapq)) {
            #record count of 1 and 2
            if ( mapq1[j]<1 || mapq2[j]<1 ){
                print 0; #below mapQ, marked as 0
                next;
            }
            uniq++;
            print name"-"uniq;
            for (k=j+1; k<i; k++) {
                if ( mapq1[k]<1 || mapq2[k]<1 ){
                        print 0; #below mapQ, marked as 0
                        belowmapq[k]++;
                        next;
                }
            # check each item in array against all the rest 
                if (tooclose(pos1[j],pos1[k],pos2[j],pos2[k])) {
                    dups[k]++;
                    print name"-"uniq;
                }
            }    
        }
    }
		
	#for (j=0; j<dup_type; j++) {print dup_count[j];}
	
	delete line;
	delete dups;
    delete belowmapq;
	delete pos1;
	delete pos2;
	delete x;
	delete y;
    delete mapq1;
    delete mapq2;
    
	i = 1;
	pos1[0]=$3;
	pos2[0]=$7;
    mapq1[i]=$9;
    mapq2[i]=$12;
}

# always reset the fields we're checking against on each read 
{ p1=$1;p2=$2;p3=$3;p4=$4;p5=$5;p6=$6;p7=$7;p8=$8;}
END {
	if (i > 1) {
		# same code as above, just process final potential duplicate array

		for (j=0; j<i; j++) {
            # only consider reads that aren't already marked duplicate
			# (no daisy-chaining)
			if (!(j in dups) || !(j in belowmapq)) {
                if ( mapq1[j]<1 || mapq2[j]<1 ){
                    print 0; #below mapQ, marked as 0
                    next;
                }
                uniq++;
                print name"-"uniq;
                #record count of 1 and 2
				for (k=j+1; k<i; k++) {
                    if ( mapq1[k]<1 || mapq2[k]<1 ){
                        print 0; #below mapQ, marked as 0
                        belowmapq[k]++;
                        next;
                    }
					# check each item in array against all the rest 
					if (tooclose(pos1[j],pos1[k],pos2[j],pos2[k])) {
						dups[k]++;
                        print name"-"uniq;
					}
				}
			}
		}
	}
	else if (i == 1) {
        if ( mapq1[i]<1 || mapq2[i]<1 ){
            print 0; #below mapQ, marked as 0
        }
		else{uniq++; print name"-"uniq;}
	}
}