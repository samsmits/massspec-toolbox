#!/usr/bin/perl -w
use Cwd;
use File::Spec;
use strict;
use warnings;

my $current_dir = getcwd();
my @parent_dirs = File::Spec->splitdir($current_dir);
my $project_name = pop(@parent_dirs);
my $file_output = $project_name.'.omssa.summary';

my %spectra;
foreach my $file_omssa (`ls omssa/*.omssa`) {
  chomp($file_omssa);
  my $sample = 'unknown';
  if( $file_omssa =~ /([A-z0-9\_]+)\.\d+\.mgf\.omssa/ ) {
    $sample = $1;
  }

  if( $sample eq 'unknown' ) {
    die "Unknown sample name : $file_omssa\n";
  }

  print STDERR "Read $file_omssa ... ";
  open(OMSSA,$file_omssa);
  <OMSSA>;
  while(<OMSSA>) {
    chomp;
    my ($spectrum_number, $id, $peptide, $E_value, @tmp) = split(/,/);
    my ($scan, $charge) = (0,0);
    $id =~ s/\.dta$//;
    if( $id =~ /([0-9]+)\.([0-9])$/ ) {
      $scan = $1; $charge = $2;
    }

    if( $scan == 0 ) { 
      die "Unknown scan/charge : $id\n";
    }
    $spectra{$sample}->{"$scan.$charge"}->{$peptide} = $tmp[9]."\t".$E_value;
  }
  close(OMSSA);
  print STDERR "Done\n";
}

open(OUTPUT,">$file_output");
print STDERR "Write $file_output ... ";
print OUTPUT join("\t",'Sample','Scan/Charge','Peptide','P-value','E-value'),"\n";
foreach my $sample (sort keys %spectra) {
  foreach my $scan (sort keys %{$spectra{$sample}}) {
    foreach my $peptide (sort keys %{$spectra{$sample}->{$scan}}) {
      print OUTPUT join("\t",$sample,$scan,$peptide,
                    $spectra{$sample}->{$scan}->{$peptide}),"\n";
    }
  }
}
close(OUTPUT);
print STDERR "Done\n";
