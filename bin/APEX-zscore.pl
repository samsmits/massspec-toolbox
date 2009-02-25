#!/usr/bin/perl -w
## Copyright (C) 2008 Christine Vogel, University of Texas at Austin
## Initial version : Apr. 2008
## 
## Modified by Taejoon Kwon
## Modified date : Feb. 2009

# input: 
#	two .apex files (from different conditions) - format:
# 	# 0 ID	1 OI_VALUE	2 PROTEINPROPHET_PROBABILITY	3 TOTAL_SPECTRAL_COUNTS	4 APEX_PROTEIN_ABUNDANCE
# 	5 NUMBER_OF_DEGENERATE_PROTEINS	6 IDS_DEGENERATE_PROTEINS	7 ANNOTATION
# output:
#	.zscore file
# 	format:
#  PROTEIN_ID\tPP_PROBABILITY_1\tPP_PROBROBABILITY_2\tSPECTRAL_COUNT_1\tSPECTRAL_COUNT_2
#  f_1\tf_2\tf_0\tZ_SCORE\tDEGENERATE_IDS\tAPEX_VALUE_1\tAPEX_VALUE_2\tLOG10_APEX1_div_APEX2\n

# NOTES:
#	Tricky part here is that for degenerate proteins, different main IDs may be used for a group of degenerates in the two different files. 
# 	Left the debugging printouts in (hashed-out) to provide option to follow the data reading step-by-step. 
# 	For historical reasons, this script is rather wordy and convoluted, although hopefully still easy to follow.  

# ======================================================================================
use strict;
use warnings;

my $usage = "APEX-Zscore.pl <file1.apex> <file2.apex> <output_filename>";

if( $#ARGV != 2 ) {
  print $usage,"\n";
  exit(1);
}

my $apex1 = &read_apex($ARGV[0]);
my $apex2 = &read_apex($ARGV[1]);
my $filename_output = $ARGV[2].'.apexZ';

sub read_apex {
  my $filename_apex = shift;
  my @rv;

  unless( -e $filename_apex ) {
    print STDERR $filename_apex," does not exist.\n";
    exit;
  }

  my @headers = [];
  open(APEX,$filename_apex);
  while(<APEX>) {
    next if(/^#/);
    chomp;
    
    if(/^[0-9]+/) {
      ## Record
      my @tmp = split(/\t/);
      my %tmp_hash;
      for(my $i=0;$i<=$#tmp;$i++) {
        $tmp_hash{ $headers[$i] } = $tmp[$i];
      }
      push(@rv, \%tmp_hash);
    } else {
      ## Header
      @headers = split(/\t/);
    }
  }
  close(APEX);

  return @rv;
}










#########################################
`rm -f $out.zscore`;
open (OUT, ">>$out.zscore");

# ======================================================================================
### gathering data 

# prepare for degenerate proteins -- 
my %BIG_CONVERT; # hash{protein} = hash{degenerate names}

print "\n";
### FILE 1 #### 
my ($hr_FILE1, $hr_FILE1_prob, $hr_FILE1_apex, $hr_FILE1_oi, $totalpepts1) = &peptide_counts($file1); # now use BIGPARSE file
print "\# FILE1\t$file1\tproteins\t", scalar(keys(%{$hr_FILE1})), "\ttotal_spectra\t$totalpepts1\n";
print OUT "\# FILE1\t$file1\tproteins\t", scalar(keys(%{$hr_FILE1})), "\ttotal_spectra\t$totalpepts1\n";

### FILE 2 #### 
my ($hr_FILE2, $hr_FILE2_prob, $hr_FILE2_apex,$hr_FILE2_oi, $totalpepts2) = &peptide_counts($file2);
print "\# FILE2\t$file2\tproteins\t", scalar(keys(%{$hr_FILE2})), "\ttotal_spectra\t$totalpepts2\n";
print OUT "\# FILE2\t$file2\tproteins\t", scalar(keys(%{$hr_FILE2})), "\ttotal_spectra\t$totalpepts2\n";

# print overview: 
print "\# UNION of all proteins\t", scalar(keys(%BIG_CONVERT)), "\t(note that some proteins are degenerate/redundant)\n";
print OUT "\# UNION of all proteins\t", scalar(keys(%BIG_CONVERT)), "\t(note that some proteins are degenerate/redundant)\n";

# ======================================================================================
### z-score analysis 

my %FLAG; # hash{protein} = flag (if counted already, to avoid double-counting of degenerate proteins)
my $apex_sum1 = 0; #total protein
my $apex_sum2 = 0;
my @ALL_LOGRATIOS; # store logratios for Z-score calculation
my @ALL_APEX1; # store APEX values for avg, stdev, median
my @ALL_APEX2; # 

# other info (from data collection above):
# my ($hr_FILE1 (peptide counts), $hr_FILE1_prob, $hr_FILE1_apex, $totalpepts1) = &peptide_counts($file1); 

print "\# PARSING and PRINTING to $out.zscore...\n";
print "\# PROTEIN_ID\tOI_VALUE\tPP_PROBABILITY_1\tPP_PROBROBABILITY_2\tSPECTRAL_COUNT_1\tSPECTRAL_COUNT_2\tf_1\tf_2\tf_0\tZ_SCORE\tDEGENERATE_IDS\tAPEX_VALUE_1\tAPEX_VALUE_2\tLOG10_APEX1_div_APEX2\n";
print OUT "\# PROTEIN_ID\tOI_VALUE\tPP_PROBABILITY_1\tPP_PROBROBABILITY_2\tSPECTRAL_COUNT_1\tSPECTRAL_COUNT_2\tf_1\tf_2\tf_0\tZ_SCORE\tDEGENERATE_IDS\tAPEX_VALUE_1\tAPEX_VALUE_2\tLOG10_APEX1_div_APEX2\n"; 

foreach my $protein ( keys( %BIG_CONVERT ) )  {

	my $Oi = 0;
	my $pept1 = 0;
	my $pept2 = 0;
	my $apex1 = 0;
	my $apex2 = 0;
	my $prob1 = 0;
	my $prob2 = 0;

	print "\n\### ATTENTION\t$protein exists several times in file (probably degenerate) -- but degeneracy is taken care of.\n\n" if defined $FLAG{$protein};
	next if defined $FLAG{$protein};
	$FLAG{$protein}++;

	## print "\n\nLOOKING at $protein\n";

	#### LOOK AT FILE 1 entries ----------------------
	## print "\t--- file 1---\n";
	if ( defined $$hr_FILE1{$protein} )  {
		## print "\tHURRAY\tin FILE1 with $$hr_FILE1{$protein}\n";
		$pept1 = $$hr_FILE1{$protein};
		$apex1 = $$hr_FILE1_apex{$protein};
		$prob1 = $$hr_FILE1_prob{$protein};
		$Oi = $$hr_FILE1_oi{$protein};
	} # 
	else {
		## print "\tNOT in FILE1\n";
		my @degen = keys( %{$BIG_CONVERT{$protein}} );
		## print "\tscreening degens: @degen\t", scalar(@degen),"\n";
		foreach my $deg_gene ( @degen )  {		
			## print "\t\tSCREENING degen $deg_gene\n";
			if ( defined $$hr_FILE1{$deg_gene} )  {
				## print "\t\tHURRAY $deg_gene exists in FILE1 with $$hr_FILE1{$deg_gene} peptides\n";
				$pept1 = $$hr_FILE1{$deg_gene};
				$apex1 = $$hr_FILE1_apex{$deg_gene};
				$prob1 = $$hr_FILE1_prob{$deg_gene};
				$Oi = $$hr_FILE1_oi{$deg_gene};

				$FLAG{$deg_gene}++;
			} # if ( defined $FILE1{$deg_gene} )  {
			else {
				## print "\t\tMARKING $protein as seen\n";
				$FLAG{$deg_gene}++;
			} # if ( defined $FILE1{$deg_gene} )  {			
		} # foreach my $deg_gene ( @degen )  {
	} # else -- if ( defined $FILE1{$protein} )  {

	#### LOOK AT FILE 2 entries ----------------------
	## print "\t--- file 2---\n";
	if ( defined $$hr_FILE2{$protein} )  {
		## print "\tHURRAY\tin FILE2 with $$hr_FILE2{$protein}\n";
		$pept2 = $$hr_FILE2{$protein};
		$apex2 = $$hr_FILE2_apex{$protein};
		$prob2 = $$hr_FILE2_prob{$protein};
		$Oi = $$hr_FILE2_oi{$protein};
	} # 
	else {
		## print "\tNOT in FILE2\n";
		my @degen = keys( %{$BIG_CONVERT{$protein}} );
		## print "\tscreening degens: @degen\t", scalar(@degen),"\n";
		foreach my $deg_gene ( @degen )  {			
			## print "\t\tSCREENING degen $deg_gene\n";
			if ( defined $$hr_FILE2{$deg_gene} )  {			
				## print "\t\tHURRAY $deg_gene exists in FILE2 with $$hr_FILE2{$deg_gene} peptides\n";
				$pept2 = $$hr_FILE2{$deg_gene};
				$apex2 = $$hr_FILE2_apex{$deg_gene};
				$prob2 = $$hr_FILE2_prob{$deg_gene};
				$Oi = $$hr_FILE2_oi{$deg_gene};
				$FLAG{$deg_gene}++;
			} # if ( defined $FILE1{$deg_gene} )  {
			else {			
				## print "\t\tMARKING $protein as seen\n";
				$FLAG{$deg_gene}++;
			} # if ( defined $FILE1{$deg_gene} )  {			
		} # foreach my $deg_gene ( @degen )  {
	} # else -- if ( defined $FILE1{$protein} )  {

	## print "MADE IT $protein $$hr_FILE1_prob{$protein} and $$hr_FILE2_prob{$protein}\n"; 

	###### z-score calculation -----------------------
	my $fraction1 = $pept1 / $totalpepts1;
	my $fraction2 = $pept2 / $totalpepts2;
	my $f0 = ($pept1 + $pept2) / ( $totalpepts1 + $totalpepts2 );

	my $Z = &d4( ($fraction1 - $fraction2) / sqrt( ( $f0*(1-$f0)/$totalpepts1 ) + ( $f0*(1-$f0)/$totalpepts2 ) ) );

	$apex_sum1 += $apex1;
	$apex_sum2 += $apex2;

	my $logratio = 99999;
	$logratio = &d6(&log10($apex1/$apex2)) if ($apex1 > 0 and $apex2 > 0);

	# print "$protein\t$prob1\t$prob2\t$pept1\t$pept2\t", &d6($fraction1), "\t", &d6($fraction2), "\t", &d6($f0), "\t$Z\t",join(",", keys(%{$BIG_CONVERT{$protein}})),"\t$apex1\t$apex2\t$logratio\n";	

	print OUT "$protein\t$Oi\t$prob1\t$prob2\t$pept1\t$pept2\t", &d6($fraction1), "\t", &d6($fraction2), "\t", &d6($f0), "\t$Z\t",join(",", keys(%{$BIG_CONVERT{$protein}})),"\t$apex1\t$apex2\t$logratio\n";	

} # foreach my $name ( keys( %BIG_COUNT ) )  { 

print "\# DONE.\n\n";

# ======================================================================================
# ======================================================================================
# SUBROUTINES
# ======================================================================================
sub peptide_counts {

	my ($file1) = @_;

	my %FILE1; # hash{protein} = peptidecount
	my %FILE1_prob; # hash{protein} = probability
	my %FILE1_apex; # hash{protein} = apex
	my %FILE1_oi; # hash{protein} = Oi
	my $totalpepts1 = 0; # total peptide count in file
	my $count_proteins_5FDR = 0;

	open (IN1, $file1) or die "Cant open $file1\n";
	#	.apex file - format:
	# 	0 ID	1 OI_VALUE	2 PROTEINPROPHET_PROBABILITY	3 TOTAL_SPECTRAL_COUNTS	4 APEX_PROTEIN_ABUNDANCE
	# 	5 NUMBER_OF_DEGENERATE_PROTEINS	6 IDS_DEGENERATE_PROTEINS	7 ANNOTATION
	while ( my $line = <IN1> )  {
		next if length(chomp $line) == 0;
		next if $line =~ /^\#/;

		my @a = split("\t", $line);
		die "ERROR in file $file1 wrong line $line\n" unless scalar(@a) >= 7;
		my $protein = $a[0];
		my $oi = $a[1];
		my $prob = $a[2];
		my $peptidecount = $a[3];
		my $apex = $a[4];
		my $degen = $a[6];

		$count_proteins_5FDR++;

		$FILE1{$protein} = $peptidecount;
		$FILE1_prob{$protein} = $prob;
		$FILE1_apex{$protein} = $apex;
		$FILE1_oi{$protein} = $oi;
		$totalpepts1 += $peptidecount;

		foreach my $deg ( split(",", $degen) )  {
			$BIG_CONVERT{$protein}{$deg}++;
		} # foreach my $deg ( split(",", $degen) )  {

	} # while ( my $line = <IN1> )  {
	close IN1;
	# print "FILE $file1 with $count_proteins_5FDR\n";
	# print OUT "\# FILE $file1 with $count_proteins_5FDR\n";
	
	return(\%FILE1, \%FILE1_prob, \%FILE1_apex, \%FILE1_oi, $totalpepts1);
} # sub peptide_counts

# ======================================================================================
# ======================================================================================
sub log10  {
    my $val = shift;
    die "ERROR in sub log10 in General.pm with value $val\n" unless $val > 0;
    return log($val) / log(10);
  } # sub avg
# ======================================================================================
# ======================================================================================
sub d6  {

  my ($number) = @_;
  my $new_number = (int($number*1000000))/1000000;
  return $new_number;

} # sub dec4\6
# ======================================================================================
# ======================================================================================
sub d4  {

  my ($number) = @_;
  my $new_number = (int($number*10000))/10000;
  return $new_number;

} # sub dec4
# ======================================================================================
# ======================================================================================
