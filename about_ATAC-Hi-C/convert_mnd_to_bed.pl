use File::Basename;
use POSIX;
use List::Util qw[min max];


# set mapQ

my $mapq_threshold = 1;



#open FILE, $infile or die $!;
while (<>) {
	
	my @record = split;
	my $num_records = scalar(@record);
  # don't count as Hi-C contact if fails mapq or intra fragment test
	my $countme = 1;
  
   if (($record[1] eq $record[5]) && $record[3] == $record[7]) {
       $intra_fragment++;
       $countme = 0;
   }
	if ($num_records > 8) {
		my $mapq_val = min($record[8],$record[11]);
		if ($mapq_val < $mapq_threshold) {
		
			$countme = 0;
		}
	}


	if ($countme) {
		
		my $frag_1 = &get_paired_pos($record[0], $record[1], $record[2], $record[3], $record[9]);
		my $frag_2 = &get_paired_pos($record[4], $record[5], $record[6], $record[7], $record[12]);
		my ($strand1,$strand2);
		if ( $record[0] == 0 ){ $strand1 = '+'} else{ $strand1 = '-'}
		if ( $record[4] == 0 ){ $strand2 = '+'} else{ $strand2 = '-'}
		print "${$frag_1}[0]\t${$frag_1}[1]\t${$frag_1}[2]\t$record[14]\t$record[8]\t$strand1\n${$frag_2}[0]\t${$frag_2}[1]\t${$frag_2}[2]\t$record[15]\t$record[11]\t$strand2\n";
	}
}




sub get_paired_pos {
	
	my $read_len; #set read length to adjust contact fragment ::: may need consider map cigar 
	my $cigar = $_[4];
	if($cigar =~ /(\d+)M/){
		$read_len = $1;
	}
	
	my $end = $_[2] + $read_len - 1;
	my @out = ($_[1], $_[2], $end);
	my $out = \@out;
	return $out;
}

