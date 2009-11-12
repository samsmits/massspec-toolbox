#!/usr/bin/perl -w
use Cwd;
use File::Spec;
use strict;
use warnings;

require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/pipeline/conf.pl';
my $path_conf = &get_path();

my $dir_current = File::Spec->rel2abs('.');
my $db_name = $path_conf->{'DB_name'};
$db_name =~ s/\.aa$//;
$db_name =~ s/\.fasta$//;
$db_name = $db_name.'.crux-index';

my $file_script = "run-crux.sh";

my $current_dir = getcwd();
open(SCRIPT,">$file_script");
print SCRIPT "#!/bin/bash\n";
foreach my $file_ms2 (`ls ./ms2/*.ms2`) {
  chomp($file_ms2);
  my $file_crux_in = $file_ms2;
  $file_crux_in =~ s/ms2/crux/;
  $file_crux_in =~ s/ms2$/crux.in/;
  $file_crux_in = File::Spec->catfile($dir_current, $file_crux_in);

  my $file_crux_target = $file_ms2;
  $file_crux_target =~ s/\.\/ms2\///;
  #$file_crux_target =~ s/ms2$/crux.target_sqt/;
  #$file_crux_target = File::Spec->catfile($dir_current, $file_crux_target);

  my $file_crux_decoy = $file_crux_target;
  $file_crux_decoy =~ s/target_sqt$/decoy_sqt/;
  
  open(CRUX,">$file_crux_in");
  #print CRUX "output-dir=crux\n";
  #print CRUX "output-mode=all\n";
  #print CRUX "sqt-output-file=$file_crux_target\n";
  #print CRUX "decoy-sqt-output-file=$file_crux_decoy\n";
  #print CRUX "max-sqt-result=5\n";
  print CRUX "C=57.000000\n";
  close(CRUX);

  print SCRIPT $path_conf->{'crux'},' search-for-matches ',
                ' --output-dir crux --decoy-location separate-decoy-files ',
                ' --fileroot ',$file_crux_target,' --overwrite T ',
                ' --parameter-file ',$file_crux_in,
                ' ',$file_ms2,' DB/',$db_name,"\n";
}
close(SCRIPT);

`chmod 744 $file_script`;
