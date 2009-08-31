#!/usr/bin/perl -w
use strict;
use warnings;
require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/bin/conf.pl';

my $path_conf = &get_path();
if( not exists $path_conf->{'tandem2xml'} ) {
  print STDERR "tandem2xml is not available in path.conf\n";
  exit;
}
my $path_tandem2xml = $path_conf->{'tandem2xml'};

foreach my $file_old (`ls tandem/*.out`) {
  chomp($file_old );
  my $file_new = $file_old;
  $file_new =~ s/[0-9\_]+\.t\.//;
  if( $file_old eq $file_new ) {
    print STDERR "Skip $file_old \n";
  } else {
    print STDERR "$file_old --> $file_new\n";
    `mv $file_old $file_new`;
  }
  my $file_pepxml = $file_new;
  $file_pepxml =~ s/out$/pepxml/;
  `$path_tandem2xml $file_new > $file_pepxml`;
}
