#!/usr/bin/perl -w
use Cwd;
use File::Spec;
use strict;
use warnings;

my $dir_current = File::Spec->rel2abs('.');
#my $db_name = 'ECOLI_MG1655.BKRB2.trie';
my $db_name = 'YEAST.ensembl50.trie';

my $file_script = "run-inspect.sh";
my $file_Pvalue_script = "run-inspect-PValue.sh";

my $current_dir = getcwd();
open(SCRIPT,">$file_script");
print SCRIPT "#!/bin/bash\n";
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

  open(INSPECT,">$file_inspect_in");
  print INSPECT 'spectra,',File::Spec->catfile($dir_current, $file_mzxml),"\n";
  print INSPECT "instrument,ESI-ION-TRAP\n";
  print INSPECT "protease,Trypsin\n";
  print INSPECT "DB,$db_name\n";
  print INSPECT "mod,57,C,fix\n";
  close(INSPECT);
  print SCRIPT "/usr/local/inspect/inspect -r /usr/local/inspect -i $file_inspect_in -o $file_inspect_out\n";
}
close(SCRIPT);

open(PVALUE,">$file_Pvalue_script");
print PVALUE "#!/bin/bash\n";
print PVALUE "# Run this script from /usr/local/inspect/\n";
print PVALUE "python PValue.py -r $current_dir/inspect -w $current_dir/inspect.PValue\n";
close(PVALUE);

`chmod 744 $file_script`;
`chmod 744 $file_Pvalue_script`;
