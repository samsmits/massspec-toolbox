#!/usr/bin/perl -w
use Cwd;
use File::Spec;
use strict;
use warnings;

my $current_dir = getcwd();
my @parent_dirs = File::Spec->splitdir($current_dir);
my $project_name = pop(@parent_dirs);
my $file_output = $project_name.'.tandem.summary';

my %spectra;
foreach my $file_pepxml (`ls tandem/*.pepxml`) {
  chomp($file_pepxml);
  print STDERR "Read $file_pepxml ... ";
  my $sample = 'unknown';
  if( $file_pepxml =~ /([A-z0-9\_]+)\.tandem\.pepxml$/ ) {
    $sample = $1;
  }
  if( $sample eq 'unknown' ) {
    die "Unknown sample name : $file_pepxml\n";
  }

  my $spectrum_name = 'unknown';
  open(PEPXML,$file_pepxml);
  while(<PEPXML>) {
    if(/spectrum_query spectrum="([A-z0-9\.\_]+)"/) {
      $spectrum_name = $1;
    } elsif(/search_hit hit_rank="1" peptide="([A-Z]+)"/) {
      $spectra{$sample}->{$spectrum_name}->{$1} = 0;
    }
  }
  close(PEPXML);
  print STDERR "Done\n";
}

foreach my $file_xinteract (`ls tandem.xinteract/*.xinteract.xml`) {
  chomp($file_xinteract);

  my $sample = 'unknown';
  if( $file_xinteract=~ /([A-z0-9\_]+)\.tandem\.xinteract\.xml$/ ) {
    $sample = $1;
  }
  if( $sample eq 'unknown' ) {
    die "Unknown sample name : $file_xinteract\n";
  }

  my ($spectrum_name,$peptide) = ('unknown','unknown');
  print STDERR "Read $file_xinteract ... ";
  open(XINTERACT,$file_xinteract);
  while(<XINTERACT>) {
    if(/spectrum_query spectrum="([A-z0-9\.\_]+)"/) {
      $spectrum_name = $1;
    } elsif(/search_hit hit_rank="1" peptide="([A-Z]+)"/) {
      $peptide = $1;
    } elsif(/peptideprophet_result probability="([0-9\.]+)/) {
      $spectra{$sample}->{$spectrum_name}->{$peptide} = $1;
    }
  }
  close(XINTERACT);
  print STDERR "Done\n";
}

open(OUTPUT,">$file_output");
print OUTPUT join("\t",'Sample','Scan/Charge',
                        'Peptide','PeptideProphet Prob.'),"\n";
foreach my $sample (sort keys %spectra) {
  foreach my $spectrum_name (sort keys %{$spectra{$sample}}) {
    foreach my $peptide (sort keys %{$spectra{$sample}->{$spectrum_name}}) {
      my $scan = $spectrum_name;
      $scan =~ s/$sample\.\d+\.//;
      $scan =~ s/^0+//;
      print OUTPUT join("\t",$sample,$scan,$peptide,
                $spectra{$sample}->{$spectrum_name}->{$peptide}),"\n";
    }
  }
}
close(OUTPUT);
