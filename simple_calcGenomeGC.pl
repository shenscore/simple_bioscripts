#input genome
my $fastaF = @ARGV[0];

#READING FASTA
use Bio::Seq;
use Bio::SeqIO;

my $seqio = Bio::SeqIO->new(-file => $fastaF, '-format' => 'Fasta');
my %fasta;
while($seq = $seqio->next_seq){
	my $id = $seq->display_name;
	$fasta{$id} = $seq;
}


#chromlist, chromsize
my @chromlist = keys %fasta;
my @chromsize;
foreach my $chr (@chromlist){
    push @chromsize, $fasta{$chr}->length;
}
# print @chromsize;

#set window step
my $window=600;
my $step=200;

#calculate GC
foreach my $chr (keys %fasta){
    my $chr_len = $fasta{$chr}->length;
    for(my ($start,$end) = (1,$window); $end < $chr_len; ($start,$end) = ($start+$step, $end+$step)){
        my $seq = $fasta{$chr}->subseq($start,$end);
        my $gc_ratio = &computeGC($seq);
        print $gc_ratio . "\n";
    }
}




sub computeGC {
	my $string = $_[0];
	my $number = () = $string =~ /[g,c,G,C]/g;
	my $ratio = $number/length($string);
	return $ratio;
}