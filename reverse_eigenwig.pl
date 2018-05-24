#input eigen wig

while(<>){
    chomp;
    if(/^variableStep/){print $_."\n";next;}
    my @out = split "\t";
    $out[1] = -$out[1]
    print "$out[0]\t$out[1]\n";
}

