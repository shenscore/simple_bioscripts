#!/usr/bin/perl

# TODO: need add gap row

my $cprops_file = $ARGV[0];
my $asm_file = $ARGV[1];

open FH, $cprops_file;
my %contig_len;
my %contig_name;
while(<FH>){
    chomp;
    my @cprops = split " ";
    $contig_len{$cprops[1]} = $cprops[2];
    $contig_name{$cprops[1]} = $cprops[0];
}
close FH;

# now read in asm file and output agp file

open FH, $asm_file;
my $scaf_num = 1; #initialize hic scaffold number
my $component_type = 'W';
while(<FH>){
    chomp;
    my @asm = split " ";
    my $part_number = 1;
    
    my $start = 0;
    my $end = 0;
    foreach my $i (@asm){

        if($i<0){$strand = '-';$contig = -$i}
        else{$strand = '+';$contig = $i}
        #print "$i contig is $contig, strand is $strand\n"; #debug

        $scaffold = "HiC_scaffold_".$scaf_num;
        $start = $end + 1;
        $end = $start + $contig_len{$contig} - 1;
        my $component_id = $contig_name{$contig};
        my $component_beg = 1;
        my $component_end = $contig_len{$contig};
        print "$scaffold\t$start\t$end\t$part_number\t$component_type\t$component_id\t$component_beg\t$component_end\t$strand\n";
        $part_number++;
    }

    $scaf_num++;
}
close FH
