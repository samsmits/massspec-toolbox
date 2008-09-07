#!/usr/bin/perl -w
use strict;
use warnings;

unless(-d 'tandem_k.xinteract') {
  print STDERR "Make tandem_k.xinteract directory ... ";
  `mkdir tandem_k.xinteract`;
  print STDERR "Done\n";
} else {
  print STDERR "Check xinteract directory ... Done\n";
}
  
unless(-d 'tandem_k') {
  die "TANDEM files are not prepared properly. Check tandem_k/\n";
}

my $file_script = 'run-tandem_k.xinteract.sh';
open(SCRIPT,">$file_script");
foreach my $file_pepxml (`ls tandem_k/*.pepxml`) {
  chomp($file_pepxml);
  my $file_xinteract = $file_pepxml;
  $file_xinteract =~ s/tandem_k/tandem_k.xinteract/;
  $file_xinteract =~ s/pepxml$/xinteract\.xml/;
  my $file_xinteract_prot = $file_xinteract;
  my $file_xinteract_summary = $file_xinteract;
  $file_xinteract_prot =~ s/xml$/prot\.xml/;
  $file_xinteract_summary =~ s/xml$/summary/;
  print SCRIPT '/usr/local/tpp/bin/xinteract -N',$file_xinteract,' -Op ',$file_pepxml,"\n";
  print SCRIPT '/work/linusben/libperl.cvogel/ms_prophetout_to_proteinlist.pl ',
              $file_xinteract_prot,' ',$file_xinteract_summary," 0.05\n";
}
close(SCRIPT);
