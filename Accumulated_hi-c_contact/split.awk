
BEGIN{
	tot=0;
	name=0;
	waitstring="";

}
{
	if (tot >= 1000000) {
		if (p1 != $1 || p2 != $2 || p4 != $4 || p5 != $5 || p8 != $8) {
                    name++;
                    tot=0;
		}
	}
	outname = sprintf("%s/my_split%d", dir, name);
	print > outname;
	p1=$1;p2=$2;p4=$4;p5=$5;p6=$6;p8=$8;
	tot++;
}
END {
    sysstring = sprintf("touch %s/mysplit_done", dir);
    system(sysstring);
}
