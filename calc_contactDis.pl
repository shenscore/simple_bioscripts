

use File::Basename;
use POSIX;
use List::Util qw[min max];
use Getopt::Std;
use vars qw/ $opt_s /;

# Check arguments
getopts('s:h');

my $ligation_junction = "GATCGATC";
my $mapq_threshold = 1;


if ($opt_s) {
  $site_file = $opt_s;
}


my $dangling_junction = substr $ligation_junction, length($ligation_junction)/2;

# Global variables for calculating statistics
my %chromosomes;


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
	my @record = split;
	my $num_records = scalar(@record);
  # don't count as Hi-C contact if fails mapq or intra fragment test
    $countme = 0;
    #only count intra chromosome
    if($record[0] eq $record[4]){
        $countme = 1;
    }
	if (($record[1] eq $record[5]) && $record[3] == $record[7]) {
		$countme = 0;
	}
	elsif ($num_records > 8) {
		my $mapq_val = min($record[8],$record[11]);
		if ($mapq_val < $mapq_threshold) {
			$countme = 0;
		}
	}


	if ($countme) {
		my $frag_1 = &get_frag_median($record[0], $record[1], $record[2], $record[3]);
		my $frag_2 = &get_frag_median($record[4], $record[5], $record[6], $record[7]);
        my $distance = $frag_2 - $frag_1;
        if($distance < 0){$distance = -$distance}
		print "$distance\n";
	}
}













sub get_frag_median {
    my $index = $_[3];
	if (!defined($chromosomes{$_[1]}[$index])) {next;}
	my $five_prime_border;
	my $three_prime_border;
	if ($index == 0) {
		$five_prime_border = 1;
		$three_prime_border = $chromosomes{$_[1]}[$index];
	}else {
		$five_prime_border = $chromosomes{$_[1]}[$index-1];
		$three_prime_border = $chromosomes{$_[1]}[$index];
	}
	my $median = ($five_prime_border + $three_prime_border)/2;
	return $median;
}