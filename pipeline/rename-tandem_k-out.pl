#!/usr/bin/perl -w
use strict;
use warnings;
require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/pipeline/conf.pl';

my $path_conf = &get_path();
if( not exists $path_conf->{'Tandem2XML'} ) {
  print STDERR "Tandem2XML is not available in path.conf\n";
  exit;
}
my $path_Tandem2XML = $path_conf->{'Tandem2XML'};

foreach my $file_old (`ls tandem_k/*.out`) {
  chomp($file_old );
  my $file_new = $file_old;
  $file_new =~ s/[0-9\_]+\.t\.//;
  if( $file_old ne $file_new ) {
    print STDERR "$file_old --> $file_new\n";
    `mv $file_old $file_new`;
  }
  my $file_pepxml = $file_new;
  $file_pepxml =~ s/out$/pepxml/;
  print STDERR $file_new," --> ",$file_pepxml,"\n";
  `$path_Tandem2XML $file_new > $file_pepxml`;
}
