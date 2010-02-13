#!/usr/bin/perl -w

# C.Vogel, UT Austin, TX; April 2008

# input: 
# 	-prot.xml file from ProteinProphet (Trans-Proteomic-Pipeline)
# output:
#	tab-delimited list of observed proteins (at certain FDR) and their observed peptides

# ======================================================================================

use strict;
$|=1;

die "\nnp_parse_ProteinProphet.pl <-prot.xml file> <FDR (0.05 recommended)> <out file name>\n" unless ($#ARGV==2);
my $protein_xml = $ARGV[0]; # .xml file
my $fdrcut = $ARGV[1];
my $out = $ARGV[2];

# ======================================================================================
# variable definitions 
open (XML, $protein_xml) or die "Cant open $protein_xml\n";

`rm -f $out\_$fdrcut.protlst`;
open (SML, ">>$out\_$fdrcut.protlst");
print SML "\#FILE\t$protein_xml\n";

### VARIABLE INITIALIZATIONS ###

my $upper_prob = "";
my $lower_prob = "";
my $upper_fpr = "";
my $lower_fpr = ""; 
my $prob_cut = "";
my $count = 0;
my $protein_name = ""; # main protein -- name for protein group
my $total_pept_count = 0;
my $total_uniq_pept_count = 0;
my $probability =0;

# for protein group tracking 
my %PG_MEMBERS; # hash{member} = group name (main protein)
my %PG_DATA; # hash{main protein} = array[data]
my %PG_GROUP; # hash{main_protein}{member}++
my $current_protein; # store whatever protein is current (whether main protein or degenerate group member)
my %PG_ANNOT; # hash{current_protein} = annotation (for every protein separately)
my %PG_PEPTIDE; # hash{protein_name(main)}{peptide seq} = array(features)

# ======================================================================================
# read in prot.xml file

while ( my $line = <XML> ) {
	next if length(chomp $line) == 0;
	
	# Data for 5% FDR ---------------------------------
	if ( $line =~ /protein_summary_data_filter min_probability=\"(.*)\" sensitivity=\".*\" false_positive_error_rate=\"(.*)\" predicted_num_correct/ )  {
		my ($minprob, $fpr) = ($1, $2);
		
		# estimate probability cutoff corresponding to demanded FDR
		$lower_prob = $minprob if ($fpr >= $fdrcut); # catch first one
		$upper_fpr = $fpr if ($fpr >= $fdrcut);
		$upper_prob = $minprob if ($fpr < $fdrcut and $upper_prob eq "");
		$lower_fpr = $fpr if ($fpr < $fdrcut and $lower_fpr eq ""); # catch first one		
	} # elsif... 

	# Calculate 5% FDR cutoff --------------------------
	elsif ( $line =~ /<\/proteinprophet_details>/ ) {
		print SML "\# UPPER PROB, LOWER PROB, UPPER FPR, LOWER FPR\t$upper_prob\t$lower_prob\t$upper_fpr\t$lower_fpr\n";

		if ( $lower_fpr == $fdrcut ) {
			$prob_cut = $upper_prob;
		} 
		elsif ( $upper_fpr == $fdrcut ) {
			$prob_cut = $lower_prob;
		}
		else {
			my $R = ($fdrcut-$lower_fpr) / ($upper_fpr-$fdrcut);
			$prob_cut = ($upper_prob + $lower_prob * $R) / (1+$R) ; 
		} # 
		print SML "\# PROBABILITY CUT ($fdrcut FDR)\t$prob_cut\n";
	} # elsif ( $line =~ /<\/proteinprophet_details>/ ) {

	# parse for protein content ------------------------
	elsif ( $line =~ /protein protein_name=\"(.*)\" n_indistinguishable_proteins=\"(\d+)\" probability=\"(\d+\.\d+)\" .*unique_stripped_peptides=\"(.*)\" .* total_number_peptides=\"(\d+)\"/ )        {
		my ($name, $indisting, $probb, $uniq_pept, $tot_pept) = ($1, $2, $3, $4, $5);
		$probability = $probb;
		
		$count++;
		
		$protein_name = $name;
		$current_protein = $name;

		$PG_ANNOT{$current_protein} = "nan" unless defined $PG_ANNOT{$current_protein}; # 080310 predefine empty annotation

		$uniq_pept =~ s/\+/ /g;
		my @peptides = split(" ", $uniq_pept);
		
		# print "PROTEIN\t$count\t$protein_name\t$probability\t$tot_pept\t$indisting\t", scalar(@peptides), "\t$uniq_pept\n";
		
		# print "ERROR PROTEIN $protein_name exists\n" if defined $PG_MEMBERS{$protein_name};
		$PG_MEMBERS{$protein_name} = $protein_name; # member -> group
		
		# print "ERROR Protein $protein_name already exists as group\n" if defined $PG_GROUP{$protein_name};
		$PG_GROUP{$protein_name}{$protein_name}++; # group -> members
		
		# print "ERROR protein $protein_name already has annotation\t$PG_DATA{$protein_name}\n" if defined $PG_DATA{$protein_name};
		@{$PG_DATA{$protein_name}} = ($probability, $tot_pept, $indisting);
	
		$total_pept_count += $tot_pept;
		$total_uniq_pept_count += scalar(@peptides);
	} # 
	elsif ( $line =~ /<indistinguishable_protein protein_name=\"(.*)\">/ )  {

		my $prot_degen = $1;

		$current_protein = $prot_degen; # this makes sure annotation is noted for degenerate protein and not the other one
		
		$PG_GROUP{$protein_name}{$current_protein}++;
		$PG_MEMBERS{$current_protein} = $protein_name;
		 
	} # 	elsif ( $line =~ /<indistinguishable_protein protein_name=\"(.*)\">/ )  {
	elsif ( $line =~ /annotation protein_description=\"(.*)\"/ )  {
			
		$PG_ANNOT{$current_protein} = $1;
		
	} # elsif ( $line =~ /annotation protein_description=\"(.*)\"/ )  {
	
	elsif ( $line =~ /<peptide peptide_sequence=\"(.*)\" charge=\"(\d+)\" .* nsp_adjusted_probability=\"(\d+\.\d+)\".* weight=\"(.*)\" is_nondegenerate_evidence=\"(.*)\" n_enzymatic.* n_instances=\"(\d+)\".*is_contributing_evidence=\"(.*)\" .*>/ )  {

		my ($seq, $charge, $nspprob, $weight, $degen, $inst, $contributing) = ($1, $2, $3, $4, $5, $6, $7);		
		@{$PG_PEPTIDE{$protein_name}{$seq."\_".$charge}} = ($degen, $inst, $contributing, $nspprob, $weight) if $contributing eq "Y";
		
	} #  elsif ( $line =~ /<peptide peptide
	else {
		# print "ERROR\tNOTHING in $line\n";
	} # 
	
} # while
close XML;


# ======================================================================================
# print out proteins with probability> cutoff corresponding to x FDR

print SML "\#PROTEIN_ID\tPROTEINPROPHET_PROBABILITY\tTOTAL_SPECTRAL_COUNT\tNUMBER_INDISTINGUISHABLE_PROTEINS\tIDS_INDISTINGUISHABLE_PROTEINS\tPEPTIDE_CHARGE\tNON_DEGENERATE\tINSTANCES\tCONTRIBUTING\tNSP_PROBABILITY\tWEIGHT\tPROTEIN_ANNOTATION\n";

# my $cnt=0;
foreach my $group ( keys(%PG_GROUP) )  {
	next unless $PG_DATA{$group}[0] >= $prob_cut;
	# $cnt++;
	# print SML "PROTEIN\t$cnt\t$group\t", join("\t", @{$PG_DATA{$group}}), "\t", join(",", keys(%{$PG_GROUP{$group}})),"\t$PG_ANNOT{$group}\n"; # only <5% FDR
	foreach my $peptide ( sort {$a cmp $b} keys(%{$PG_PEPTIDE{$group}}) )  {
		print SML "$group\t", join("\t", @{$PG_DATA{$group}}), "\t", join(",", keys(%{$PG_GROUP{$group}})), "\t$peptide\t", join("\t", @{$PG_PEPTIDE{$group}{$peptide}}), "\t$PG_ANNOT{$group}\n";
	} # foreach my $peptide ( sort {$a cmp $b} keys(%{$PG_PEPTIDES{$group}}) )  {
} # foreach my $group ( keys(%PG_GROUPS) )  {


close SML;

# ======================================================================================
# ======================================================================================


