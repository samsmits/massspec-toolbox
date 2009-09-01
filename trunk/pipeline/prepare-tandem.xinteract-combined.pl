#!/usr/bin/perl -w
use strict;
use warnings;

use File::Spec;
require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/pipeline/conf.pl';

my $path_conf = &get_path();
unless(-d 'tandem') {
  die "tandemfiles are not prepared properly. Check tandem/\n";
}

my %files;
my $is_compressed = 0;
foreach my $file_pepxml (`ls tandem/*.pepxml*`) {
  chomp($file_pepxml);
  if( $file_pepxml =~ /gz/ ) { $is_compressed = 1; }
  if( $file_pepxml =~ /[A-z0-9]+\_([A-z0-9]+)\_[0-9]/ ) {
    $files{$1}->{$file_pepxml} = 1;
  }
}

my $file_script = 'run-tandem.xinteract-combined.sh';
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

  my $file_xinteract = File::Spec->catfile('tandem.xinteract',
                                    $sample.'.tandem.xinteract.xml');
  my $file_xinteract_prot = File::Spec->catfile('tandem.xinteract',
                                    $sample.'.tandem.xinteract.prot.xml');
  my $file_xinteract_summary = File::Spec->catfile('tandem.xinteract',
                                    $sample.'.tandem.xinteract.summary');

  print SCRIPT $path_conf->{'xinteract'},' -N',$file_xinteract
              ," -Op tmp/*.pepxml\n";
  print SCRIPT $path_conf->{'apex_pp_parser'}
              ,' ', $file_xinteract_prot,' 0.05 ',$file_xinteract_summary,"\n";

  print SCRIPT "echo 'Clean-up $sample'\n";
  print SCRIPT "rm -f tmp/*\n";
}
close(SCRIPT);

`chmod 744 $file_script`;
