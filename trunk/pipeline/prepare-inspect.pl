#!/usr/bin/perl -w
use Cwd;
use File::Spec;
use strict;
use warnings;

require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/bin/conf.pl';
my $path_conf = &get_path();

my $dir_current = File::Spec->rel2abs('.');
my $db_name = $path_conf->{'DB'};
$db_name =~ s/\.aa$//;
$db_name =~ s/\.fasta$//;
$db_name = $db_name.'RS.trie';

my $file_script = "run-inspect.sh";
my $file_Pvalue_script = "run-inspect-PValue.sh";

my $current_dir = getcwd();
open(SCRIPT,">$file_script");
print SCRIPT "#!/bin/bash\n";
open(PVALUE,">$file_Pvalue_script");
print PVALUE "#!/bin/bash\n";
print PVALUE "cd ",$path_conf->{'inspect_home'},"\n";
foreach my $file_mzxml (`ls ./mzXML/*.mzXML`) {
  chomp($file_mzxml);
  my $file_inspect_in = $file_mzxml;
  $file_inspect_in =~ s/mzXML/inspect/;
  $file_inspect_in =~ s/mzXML$/inspect.in/;
  $file_inspect_in = File::Spec->catfile($dir_current, $file_inspect_in);

  my $file_inspect_out = $file_mzxml;
  $file_inspect_out =~ s/mzXML/inspect/;
  $file_inspect_out =~ s/mzXML$/inspect.out/;
  $file_inspect_out = File::Spec->catfile($dir_current, $file_inspect_out);
  
  my $file_inspect_Pvalue = $file_inspect_out;
  $file_inspect_Pvalue =~ s/inspect\.out$/inspect\.Pvalue/;

  open(INSPECT,">$file_inspect_in");
  print INSPECT 'spectra,',File::Spec->catfile($dir_current, $file_mzxml),"\n";
  print INSPECT "instrument,ESI-ION-TRAP\n";
  print INSPECT "protease,Trypsin\n";
  print INSPECT "DB,$db_name\n";
  print INSPECT "TagCount,50\n";
  print INSPECT "PMTolerance,2.5\n";
  print INSPECT "mod,57,C,fix\n";
  close(INSPECT);

  print SCRIPT $path_conf->{'inspect'},' -r ',$path_conf->{'inspect_home'},
                " -i $file_inspect_in -o $file_inspect_out\n";
  print PVALUE "python PValue.py -r $file_inspect_out -w $file_inspect_Pvalue -S 0.5\n";
}
close(SCRIPT);
print PVALUE "cd ",$current_dir."\n";
close(PVALUE);

`chmod 744 $file_script`;
`chmod 744 $file_Pvalue_script`;
