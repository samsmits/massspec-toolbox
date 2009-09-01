#!/usr/bin/perl -w
use strict;
use warnings;
use File::Spec;

require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/pipeline/conf.pl';

my $usage_mesg = 'Usage: mzXML-to-mgf.pl (run this script under your data directory)';
my $path = &get_path();

my $dirname_mzXML = './mzXML/';
my $dirname_mgf = './mgf/';

if( not -d $dirname_mzXML ) {
  print STDERR $dirname_mzXML," is not available.\n";
  print STDERR $usage_mesg,"\n";
  exit(1);
}

if( not -d $dirname_mgf ) {
  print STDERR $dirname_mgf," is not available.\n";
  print STDERR $usage_mesg,"\n";
  exit(1);
}

my $path_mzXML2Search = $path->{'MzXML2Search'};
foreach my $filename_mzXML (`ls $dirname_mzXML/`) {
  chomp($filename_mzXML);
  if( $filename_mzXML !~ /.mzXML$/ ) { next; }
  $filename_mzXML = File::Spec->catfile($dirname_mzXML,$filename_mzXML);
  my $filename_mgf = $filename_mzXML;
  $filename_mgf =~ s/mzXML/mgf/g;
  print STDERR $filename_mzXML," --> ",$filename_mgf,"\n";
  `$path_mzXML2Search -mgf $filename_mzXML`;
  `mv $filename_mzXML $filename_mgf`;
}
