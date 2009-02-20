#!/usr/bin/perl -w
use strict;
use warnings;

use File::Spec;
require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/bin/conf.pl';

my $path_conf = &get_path();
unless(-d 'sequest.pepxml') {
  die "SEQUEST pepxml files are not prepared properly. Check sequest/pepxml/\n";
}

my %files;
my $is_compressed = 0;
foreach my $file_pepxml (`ls sequest.pepxml/*.pepxml*`) {
  chomp($file_pepxml);
  if( $file_pepxml =~ /gz/ ) { $is_compressed = 1; }
  if( $file_pepxml =~ /[0-9]+\_([A-z0-9]+)\_[0-9]/ ) {
    $files{$1}->{$file_pepxml} = 1;
  }
}

my $file_script = 'run-sequest.xinteract-combined.sh';
open(SCRIPT,">$file_script");
print SCRIPT "#!/bin/bash\n";
foreach my $sample (sort keys %files) {
  print SCRIPT "echo 'Set-up $sample'\n";
  foreach my $file_pepxml (keys %{$files{$sample}}) {
    print SCRIPT "cp $file_pepxml tmp/\n";
  }

  if( $is_compressed ) {
    print SCRIPT "gunzip tmp/*\n";
  }

  my $file_xinteract = File::Spec->catfile('sequest.xinteract',
                                    $sample.'.xinteract.xml');
  my $file_xinteract_prot = File::Spec->catfile('sequest.xinteract',
                                    $sample.'.xinteract.prot.xml');
  my $file_xinteract_summary = File::Spec->catfile('sequest.xinteract',
                                    $sample.'.xinteract.summary');

  print SCRIPT $path_conf->{'xinteract'},' -N',$file_xinteract
              ," -Op tmp/*.pepxml\n";
  print SCRIPT $path_conf->{'apex_pp_parser'}
              ,' ', $file_xinteract_prot,' 0.05 ',$file_xinteract_summary,"\n";

  print SCRIPT "echo 'Clean-up $sample'\n";
  print SCRIPT "rm -f tmp/*\n";
}
close(SCRIPT);



`chmod 744 $file_script`;
=rem
foreach my $file_pepxml (`ls sequest.pepxml/*.pepxml`) {
  chomp($file_pepxml);
  my $file_xinteract = $file_pepxml;
  $file_xinteract =~ s/sequest\.pepxml/sequest\.xinteract/;
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
=cut
