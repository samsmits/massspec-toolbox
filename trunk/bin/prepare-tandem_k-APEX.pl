#!/usr/bin/perl -w
use strict;
use warnings;

use File::Spec;

my %files_protlst;
foreach my $file_protlst (`ls tandem_k.xinteract/*protlst*`) {
  chomp($file_protlst);

  if( $file_protlst =~ /([A-z0-9]+).tandem_k.xinteract/ ) {
    $files_protlst{$1} = $file_protlst;
    print $1,"\t",$file_protlst,"\n";
  }
}

foreach my $sample (sort keys %files_protlst) {
  my $file_protlst = $files_protlst{$sample};
  my $file_list = File::Spec->catfile('APEX',$sample.'.tandem_k.xinteract.list');
  my $file_log = File::Spec->catfile('APEX',$sample.'.tandem_k.xinteract.log');
  print STDERR "Write $file_list ... ";

  if( $file_protlst =~ /gz$/ ) {
    print STDERR "Uncompress $file_protlst...\n";
    `gunzip $file_protlst`;
    $file_protlst =~ s/\.gz$//;
  }

  my %proteins;
  open(PROTLST,$file_protlst);
  while(<PROTLST>) {
    chomp;
    next if(/^#/);
    my @tmp = split(/\s+/);
    if( $tmp[3] == 1 ) {
      if( not exists $proteins{$tmp[0]}) {
        $proteins{$tmp[0]}->{'peptide_count'} = 0;
        $proteins{$tmp[0]}->{'spectra_count'} = 0;
      }
      $proteins{$tmp[0]}->{'peptide_count'} += 1;
      $proteins{$tmp[0]}->{'spectra_count'} += $tmp[2];
    }
  }
  close(PROTLST);

  my $count = 0;
  open(LIST,">$file_list");
  open(LOG,">$file_log");
  foreach my $p (sort 
      {$proteins{$b}->{'spectra_count'} <=> $proteins{$a}->{'spectra_count'}} 
      keys %proteins) {
    my $tmp = $proteins{$p};
    print LOG join("\t",$p,$tmp->{'spectra_count'},$tmp->{'peptide_count'}),"\n";
    print LIST $p,"\n";
    $count += 1;
    if( $count > 100 ) { last; }
  }
  close(LIST);
  close(LOG);
  print STDERR "Done\n";
}
