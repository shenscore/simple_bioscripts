
#This script will resample input simplify.txt file to calculate unique reads rate
#ref: "https://jpwendler.wordpress.com/2013/12/30/integrating-r-and-perl-to-speed-up-random-sampling-without-replacement-of-a-huge-numeric-range/"
use Statistics::R;
use List::Util 'shuffle';



my $max_number = 100000000;
 
# R way 2
# $start = time;
my $R2 = Statistics::R->new();
$R2->set('x', $max_number);
$R2->run( q'sample_for_perl = sample.int(x, 10)' );
my $Rsample2 = $R2->get('sample_for_perl');
print "\nR sample.int:\t\t", (time - $start),"sec\n";
print "@$Rsample2\n";
$R2->stop();




my @all_reads;
while(<>){
    chomp;
    my @array = split " ";
    push @all_reads, ($array[1]) x $array[0]; #generate repeat array
}

#shuffle
my @reads_


print 
