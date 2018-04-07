# scarlar

# pos_dist

# dangling

# right

# intra && pos_dist

# right left inner outer

#consider all inter/intra chromosomal contact
#1 remove intra_fragment
#2 remove low mapq 
#3 count each contact 

use File::Basename;
use POSIX;
use List::Util qw[min max];
use Getopt::Std;
use vars qw/ $opt_s $opt_l $opt_d $opt_o $opt_q $opt_h /;

# Check arguments
getopts('s:l:o:q:h');

my $site_file = "/broad/aidenlab/restriction_sites/hg19_DpnII.txt";
my $ligation_junction = "GATCGATC";
my $stats_file = "stats.txt";
my $mapq_threshold = 1;

if ($opt_h) {
    print "Usage: statistics.pl -s[site file] -l[ligation] -o[stats file] -q[mapq threshold] <infile>\n";
    print " <infile>: file in intermediate format to calculate statistics on, can be stream\n";
    print " [site file]: list of HindIII restriction sites, one line per chromosome (default $site_file)\n";
    print " [ligation]: ligation junction (default $ligation_junction)\n";
    print " [stats file]: output file containing total reads, for library complexity (default $stats_file)\n";
    print " [mapq threshold]: mapping quality threshold, do not consider reads < threshold (default $mapq_threshold)\n";
    exit;
}
if ($opt_s) {
  $site_file = $opt_s;
}
if ($opt_l) {
  $ligation_junction = $opt_l;
}
if ($opt_o) {
  $stats_file = $opt_o;
}
if ($opt_q) {
  $mapq_threshold = $opt_q;
}
if (scalar(@ARGV)==0) {
  print STDOUT "No input file specified, reading from input stream\n";
}

my $dangling_junction = substr $ligation_junction, length($ligation_junction)/2;

# Global variables for calculating statistics
my %chromosomes;
my %hindIII;
my %mapQ;
my %mapQ_inter;
my %mapQ_intra;
my %innerM;
my %outerM;
my %rightM;
my %leftM;
my $three_prime_end=0;
my $five_prime_end=0;
my $total = 0;
my $dangling = 0;
my $ligation = 0;
my $inner = 0;
my $outer = 0;
my $left = 0;
my $right = 0;
my $inter = 0;
my $intra = 0;
my $small = 0;
my $large = 0;
my $very_small = 0;
my $very_small_dangling = 0;
my $small_dangling = 0;
my $large_dangling = 0;
my $inter_dangling = 0;
my $true_dangling_intra_small = 0;
my $true_dangling_intra_large = 0;
my $true_dangling_inter = 0;
my $total_current = 0;
my $under_mapq = 0;
my $intra_fragment = 0;
my $unique = 0;

if (index($site_file, "none") != -1) {
   #no restriction enzyme, no need for RE distance
}
else {
  # read in restriction site file and store as multidimensional array
  open FILE, $site_file or die $!;
  while (<FILE>) {
    my @locs = split;
    my $key = shift(@locs);
    my $ref = \@locs;
    $chromosomes{$key} = $ref;
  }
  close(FILE);
}
# read in infile and calculate statistics
#open FILE, $infile or die $!;
while (<>) {
	$unique++;
	my @record = split;
	my $num_records = scalar(@record);
  # don't count as Hi-C contact if fails mapq or intra fragment test
	my $countme = 1;

	if (($record[1] eq $record[5]) && $record[3] == $record[7]) {
		$intra_fragment++;
		$countme = 0;
	}
	elsif ($num_records > 8) {
		my $mapq_val = min($record[8],$record[11]);
		if ($mapq_val < $mapq_threshold) {
			$under_mapq++;
			$countme = 0;
		}
	}


	if ($countme) {
		$total_current++;
		my $frag_1 = &get_paired_fragment($record[0], $record[1], $record[2], $record[3], $record[9]);
		my $frag_2 = &get_paired_fragment($record[4], $record[5], $record[6], $record[7], $record[12]);
		print "${$frag_1}[0]\t${$frag_1}[1]\t${$frag_1}[2]\t${$frag_2}[0]\t${$frag_2}[1]\t${$frag_2}[2]\n";
	}
}













sub get_paired_fragment {
	if (!defined($chromosomes{$_[1]}[$index])) {next;}
	my $read_len; #set read length to adjust contact fragment ::: may need consider map cigar 
	my $cigar = $_[4];
	if($cigar =~ /(\d+)M/){
		$read_len = $1;
	}
	my $index = $_[3];
	my $five_prime_border;
	my $three_prime_border;
	if ($index == 0) {
		$five_prime_border = 1;
		$three_prime_border = $chromosomes{$_[1]}[$index];
	}else {
		$five_prime_border = $chromosomes{$_[1]}[$index-1];
		$three_prime_border = $chromosomes{$_[1]}[$index];
	}
	
	my @out;
	if ($_[0] == 0){
		#avoid out boundary
		my $end = $_[2] + $read_len - 1 < $chromosomes{$_[1]}[-1] ?  $_[2] + $read_len - 1 : $chromosomes{$_[1]}[-1];
		@out = ($_[1], $five_prime_border, $end); #chromosome start end
	}else{
		@out = ($_[1], $_[2], $three_prime_border);
	}
	my $out = \@out;
	return $out;
}

