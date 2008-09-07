#!/usr/bin/perl -w
use strict;
use warnings;

foreach my $file_old (`ls tandem_k/*.out`) {
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
  print STDERR "Make pepxml : $file_new --> $file_pepxml\n";
  `/usr/local/tpp/bin/Tandem2XML $file_new > $file_pepxml`;
}
