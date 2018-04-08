#arguement1 fasta
#arguement2 contact fragment file


my ($fastaF,$contactFrag) = @ARGV;

#READING FASTA
use Bio::Seq;
use Bio::SeqIO;

my $seqio = Bio::SeqIO->new(-file => $fastaF, '-format' => 'Fasta');
my %fasta;
while($seq = $seqio->next_seq){
	my $id = $seq->display_name;
	$fasta{$id} = $seq;
}


#calculate GC
# my @gc_rate;
open FF, $contactFrag or die $!;
# open FF, contactFrag;
while(<FF>){
    chomp;
    my ($chr1, $sta1, $end1, $chr2, $sta2, $end2) = split "\t";
    if (!$end1 || !$end2) {next;}
    my $seq1 = $fasta{$chr1}->subseq($sta1,$end1);
    my $seq2 = $fasta{$chr2}->subseq($sta2,$end2);
    my $totalSeq = $seq1 . $seq2;
    my $gc_ratio = &computeGC($totalSeq);
    # push @gc_rate, $gc_ratio;
#    print $totalSeq . "\n";
    print $gc_ratio . "\n";
}
close FF;
#function computeGC


sub computeGC {
	my $string = $_[0];
	my $number = () = $string =~ /[g,c,G,C]/g;
	my $ratio = $number/length($string);
	return $ratio;
}
