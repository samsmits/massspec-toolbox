#!/usr/bin/perl -w
use strict;
use warnings;

foreach my $file_pepxml (`ls *.pepxml`) {
  chomp($file_pepxml);
  my $file_pepxml_bak = $file_pepxml.'.bak';
  `mv $file_pepxml $file_pepxml_bak`;
  print STDERR "$file_pepxml_bak -> $file_pepxml\n";
  open(BAK,$file_pepxml_bak);
  open(NEW,">$file_pepxml");
  while(<BAK>) {
    s/\/YEAST.ensembl50.fasta//g;
    print NEW $_;
  }
  close(NEW);
  close(BAK);
}
