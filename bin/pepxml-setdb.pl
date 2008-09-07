#!/usr/bin/perl -w
use strict;
use warnings;

#my $file_db = "/work2/MassSpec/DB/ECOLI_MG1655.BKRB2.aa";
my $file_db = "/work2/MassSpec/DB/YEAST.ensembl50.aa";

foreach my $file_pepxml (`ls *.pepxml`) {
  chomp($file_pepxml);
  my $file_pepxml_bak = $file_pepxml.'.bak';
  `mv $file_pepxml $file_pepxml_bak`;
  print STDERR "$file_pepxml_bak -> $file_pepxml\n";
  open(BAK,$file_pepxml_bak);
  open(NEW,">$file_pepxml");
  while(<BAK>) {
    if(/search_database local_path="/) {
      print NEW "<search_database local_path=\"$file_db\" type=\"AA\"/>\n";
    } elsif( /parameter name="list path, sequence source #1"/ ) {
      print NEW '<parameter name="list path, sequence source #1" value="',
              $file_db,'"/>',"\n";
    } else {
    #s/\/YEAST.ensembl50.fasta//g;
      print NEW $_;
    }
  }
  close(NEW);
  close(BAK);
  #`rm $file_pepxml_bak`;
}
