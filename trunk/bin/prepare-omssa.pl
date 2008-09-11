#!/usr/bin/perl -w
use Cwd;
use File::Spec;

use strict;
use warnings;

require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/bin/conf.pl';

my $path_conf = &get_path();
my $path_omssacl = $path_conf->{'omssacl'};
my $path_mods_xml = $path_conf->{'omssa-mods'};

my $path_db = $path_conf->{'DB'};

my $file_shell = 'run-omssa.sh';
my $current_dir = cwd();

unless(-d 'omssa') {
  print STDERR "Create omssa/ directory ... \n";
  `mkdir omssa`;
}

open(SHELL, ">$file_shell");
print SHELL "#!/bin/bash\n";
foreach my $file_mgf (`ls mgf/*mgf`) {
  chomp($file_mgf );
  my $file_base = 'unknown';
  if( $file_mgf =~ /mgf\/([A-z0-9_\-\.]+)\.mgf/ ) {
    $file_base = $1;
  }
  if( $file_base eq 'unknown' ) {
    die "Unknown file_base : $file_mgf\n";
  }
  
  my $count_ion = 0;
  my $file_idx = 0;
  my $filename_mgf_part = join('.', $file_base, $file_idx, 'mgf');
  my $file_mgf_part = File::Spec->catfile(getcwd(),'omssa',$filename_mgf_part);
  print SHELL $path_omssacl,' -d ',$path_db,' -fm ',$file_mgf_part,
          ' -mx ',$path_mods_xml, ' -oc ',$file_mgf_part,".omssa\n";
  print SHELL 'rm ',$file_mgf_part,"\n";
  print STDERR "Write $file_mgf_part\n";
  open(MGFPART,">$file_mgf_part");
  open(MGF,$file_mgf);
  while(my $line = <MGF>) {
    chomp($line);
    if( $line =~ /END IONS/ ) { $count_ion += 1; }
    if( $count_ion >= 1500 ) {
      print MGFPART $line,"\n";
      close(MGFPART);
      <MGF>;
      $file_idx += 1;
      $filename_mgf_part = join('.', $file_base, $file_idx, 'mgf');
      $file_mgf_part = File::Spec->catfile(getcwd(),'omssa',$filename_mgf_part);
      print STDERR "Write $file_mgf_part\n";
      print SHELL $path_omssacl,' -d ',$path_db,' -fm ',$file_mgf_part,
          ' -mx ',$path_mods_xml, ' -oc ',$file_mgf_part,".omssa\n";
      print SHELL 'rm ',$file_mgf_part,"\n";
      $count_ion = 0;
      open(MGFPART,">$file_mgf_part");
    } else {
      print MGFPART $line,"\n";
    }
  }
  close(MGF);
  close(MGFPART);
  #print STDERR "Done\n";
}
close(SHELL);
`chmod 744 $file_shell`;
