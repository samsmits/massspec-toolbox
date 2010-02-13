#!/usr/bin/perl -w
use strict;
use warnings;

require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/pipeline/conf.pl';

my $path_conf = &get_path();
#my $file_db = $path_conf->{'FASTA_file'};
#my $file_db = "/project/marcotte/ms/taejoon/PSEAE_ref/DB/PSEAE_PAO1.PCAP20091123.prot.fasta";
my $file_db = "/project/marcotte/ms/taejoon/PSEAE_ref/DB/PSEAE_PA14.PCAP20091014.prot.fasta";
print STDERR $file_db,"\n";

foreach my $file_pepxml (`ls sequest.pepxml/*.pepxml`) {
  chomp($file_pepxml);
  print STDERR $file_pepxml,"\n";

  my $file_pepxml_bak = $file_pepxml.'.bak';
  `mv $file_pepxml $file_pepxml_bak`;
  print STDERR "$file_pepxml_bak -> $file_pepxml\n";
  open(BAK,$file_pepxml_bak);
  open(NEW,">$file_pepxml");
  while(<BAK>) {
    if(/search_database local_path="/) {
      print NEW "<search_database local_path=\"$file_db\" type=\"AA\"/>\n";
      print STDERR "<search_database local_path=\"$file_db\" type=\"AA\"/>\n";
    } elsif( /parameter name="list path, sequence source #1"/ ) {
      print NEW '<parameter name="list path, sequence source #1" value="',
              $file_db,'"/>',"\n";
    } else {
      print NEW $_;
    }
  }
  close(NEW);
  close(BAK);
  `rm $file_pepxml_bak`;
}
#DB/PSEAE_PA14.PCAP20091014.prot.fasta
#DB/PSEAE_PAO1.PCAP20091123.prot.fasta
