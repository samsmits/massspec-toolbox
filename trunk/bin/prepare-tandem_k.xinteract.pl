#!/usr/bin/perl -w
use strict;
use warnings;

require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/bin/conf.pl';

my $path_conf = &get_path();
unless(-d 'tandem_k') {
  die "TANDEM files are not prepared properly. Check tandem_k/\n";
}

my $file_script = 'run-tandem_k.xinteract.sh';
open(SCRIPT,">$file_script");
print SCRIPT "#!/bin/bash\n";
foreach my $file_pepxml (`ls tandem_k/*.pepxml`) {
  chomp($file_pepxml);
  my $file_xinteract = $file_pepxml;
  $file_xinteract =~ s/tandem_k/tandem_k.xinteract/;
  $file_xinteract =~ s/pepxml$/xinteract\.xml/;
  my $file_xinteract_prot = $file_xinteract;
  my $file_xinteract_summary = $file_xinteract;
  $file_xinteract_prot =~ s/xml$/prot\.xml/;
  $file_xinteract_summary =~ s/xml$/summary/;
  print SCRIPT $path_conf->{'xinteract'},' -N',$file_xinteract,' -Op ',$file_pepxml,"\n";
  print SCRIPT $path_conf->{'apex_pp_parser'},' ',
              $file_xinteract_prot,' 0.05 ',$file_xinteract_summary,"\n";
}
close(SCRIPT);
`chmod 744 $file_script`;
