#!/usr/bin/perl -w
use Cwd;
use File::Spec;
use strict;
use warnings;

my $current_dir = getcwd();
my @parent_dirs = File::Spec->splitdir($current_dir);
my $project_name = pop(@parent_dirs);
my $file_output = $project_name.'.inspect.summary';

my %spectra;
=rem
foreach my $file_inspect (`ls inspect/*.out`) {
  chomp($file_inspect);
  print STDERR "Read $file_inspect ... ";
  open(INSP,$file_inspect);
  while(<INSP>) {
    if(/^#/) { next; }
    chomp;
    my ($mzxml, $scan, $peptide, $annotation, $charge, @tmp) = split(/\t/);
    my $sample = 'unknown';
    if( $mzxml =~ /([A-z0-9\_]+)\.mzXML$/ ) { 
      $sample = $1;
    }
    $peptide =~ s/^[A-Z]\.//;
    $peptide =~ s/\.[A-Z]$//;
    $scan .= '.'.$charge;

    $spectra{$sample}->{$scan}->{$peptide} = $tmp[8];

    if( $sample eq 'unknown' ) {
      die "Unknown sample : $mzxml\n";
    }
  }
  close(INSP);
  print STDERR "Done\n";
}
=cut

foreach my $file_inspect (`ls inspect/*.Pvalue`) {
  chomp($file_inspect);
  print STDERR "Read $file_inspect ... ";
  open(INSP,$file_inspect);
  while(<INSP>) {
    if(/^#/) { next; }
    chomp;
    my ($mzxml, $scan, $peptide, $annotation, $charge, @tmp) = split(/\t/);
    my $sample = 'unknown';
    if( $mzxml =~ /([A-z0-9\_]+)\.mzXML$/ ) { 
      $sample = $1;
    }
    $peptide =~ s/^[A-Z]\.//;
    $peptide =~ s/\.[A-Z]$//;
    $scan .= '.'.$charge;
    $spectra{$sample}->{$scan}->{$peptide} = $tmp[8];

    if( $sample eq 'unknown' ) {
      die "Unknown sample : $mzxml\n";
    }
  }
  close(INSP);
  print STDERR "Done\n";
}

open(OUTPUT,">$file_output");
print STDERR "Write $file_output ... \n";
print OUTPUT join("\t",'Sample','Scan/Charge','Peptide','P-value'),"\n";
foreach my $sample (sort keys %spectra) {
  foreach my $scan (sort keys %{$spectra{$sample}}) {
    foreach my $peptide (sort keys %{$spectra{$sample}->{$scan}}) {
      print OUTPUT join("\t",$sample,$scan,$peptide,
                $spectra{$sample}->{$scan}->{$peptide}),"\n";
      #if( $spectra{$sample}->{$scan}->{$peptide} <= 0.05 ) {
      #  print join("\t",$sample,$scan,$peptide),"\n";
      #}
    }
  }
}
close(OUTPUT);
