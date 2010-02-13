#!/usr/bin/perl -w
use File::Spec;
use strict;
use warnings;

require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/pipeline/conf.pl';
require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/pipeline/tandem.pl';

my $path_conf = &get_path();
if( not exists $path_conf->{'tandem.exe'} ) {
  print STDERR "tandem.exe is not available in path.conf\n";
  exit;
}
if( not exists $path_conf->{'tandem-input_k'} ) {
  print STDERR "tandem-input is not available in path.conf\n";
  exit;
}
my $path_tandem = $path_conf->{'tandem.exe'};
my $filename_input = $path_conf->{'tandem-input_k'};
my $DB_name = $path_conf->{'DB_name'};
my $filename_fasta_pro = $path_conf->{'FASTA_file'}.'.pro';

my $current_dir = File::Spec->rel2abs('.');
my $dirname_tandem = 'tandem_k';
my $filename_shell = 'run-tandem_k.sh';
my $filename_taxonomy = File::Spec->catfile($dirname_tandem,'taxonomy.xml');
$filename_taxonomy = File::Spec->rel2abs($filename_taxonomy);

unless( -d $dirname_tandem ) {
  print STDERR "Make $dirname_tandem\n";
  `mkdir $dirname_tandem`;
}

open(TAX,">$filename_taxonomy");
print TAX &tandem_taxonomy_xml('-DB_name'=>$DB_name, '-fasta_pro'=>$filename_fasta_pro);
close(TAX);

open(SHELL, ">$filename_shell");
print SHELL "#!/bin/bash\n";
foreach my $filename_mzxml (`ls mzXML/*mzXML`) {
  chomp($filename_mzxml);
  $filename_mzxml = File::Spec->rel2abs($filename_mzxml);
  my $filename_base = 'unknown';
  if( $filename_mzxml =~ /mzXML\/([A-z0-9_\-\.]+)\.mzXML/ ) {
    $filename_base = $1;
  }
  if( $filename_base eq 'unknown' ) {
    die "Unknown file_base : $filename_mzxml\n";
  }
  $filename_base = $filename_base.'.'.$DB_name;

  #print STDERR $file_base,"\n";
  my $filename_config = $filename_base.'.tandem_k.xml';
  $filename_config = File::Spec->catfile($current_dir,$dirname_tandem,$filename_config);
  my $filename_output = $filename_base.'.tandem_k.out';
  $filename_output = File::Spec->catfile($current_dir,$dirname_tandem,$filename_output);
  my $filename_seq = $filename_base.'.tandem_k.seq';
  $filename_seq = File::Spec->catfile($current_dir,$dirname_tandem,$filename_seq);
  my $filename_log = $filename_base.'.tandem_k.log';
  $filename_log = File::Spec->catfile($current_dir,$dirname_tandem,$filename_log);
  my $filename_pepxml = $filename_base.'.tandem_k.pepxml';
  $filename_pepxml = File::Spec->catfile($current_dir,$dirname_tandem,$filename_pepxml);

  print STDERR "Write $filename_config ... ";
  open(CONF,">$filename_config");
  print CONF &tandem_config_xml( 
                        '-input_xml' => $filename_input,
                        '-mzXML' => $filename_mzxml, 
                        '-output' => $filename_output,
                        '-seq' => $filename_seq, 
                        '-log' => $filename_log,
                        '-taxonomy' => $filename_taxonomy, 
                        '-db_name' => $DB_name),"\n";
  close(CONF);
  print STDERR "Done\n";
  print SHELL $path_tandem,' ',$filename_config,"\n";
}
close(SHELL);
`chmod 744 $filename_shell`;
