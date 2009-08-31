#!/usr/bin/perl -w
use strict;

my $file_list1 = $ARGV[0];
my $file_list2 = $ARGV[1];

my ($total1, $positive1, $negative1) = &read_list($file_list1);
my ($total2, $positive2, $negative2) = &read_list($file_list2);

my ($total_common, $total_only1, $total_only2) = &venn_diagram($total1,$total2);
print "[Total]\n";
print "Common : ",$total_common,"\n";
print "Only $file_list1 : ",$total_only1,"\n";
print "Only $file_list2 : ",$total_only2,"\n";

my ($positive_common, $positive_only1, $positive_only2) = &venn_diagram($positive1,$positive2);
print "[Up-regulated (FtsH/33)]\n";
print "Common : ",$positive_common,"\n";
print "Only $file_list1 : ",$positive_only1,"\n";
print "Only $file_list2 : ",$positive_only2,"\n";

my ($negative_common, $negative_only1, $negative_only2) = &venn_diagram($negative1,$negative2);
print "[Down-regulated (FtsH/33)]\n";
print "Common : ",$negative_common,"\n";
print "Only $file_list1 : ",$negative_only1,"\n";
print "Only $file_list2 : ",$negative_only2,"\n";

sub read_list {
  my $filename = shift;
  my (%total,%positive,%negative);

  open(LIST,$filename);
  while(<LIST>) {
    chomp;
    next if(/^#/);
    my @tmp = split(/\t/);
    if( $tmp[6] > 0 ) {
      $positive{$tmp[0]} = $tmp[6];
    } elsif( $tmp[6] < 0 ) {
      $negative{$tmp[0]} = $tmp[6];
    }

    $total{$tmp[0]} = $tmp[6];
  }
  close(LIST);

  return \%total, \%positive, \%negative;
}

sub venn_diagram {
  my ($list1, $list2) = @_;

  my ($common, $only1, $only2) = (0,0,0);
  foreach my $tmp1 (keys %{$list1}) {
    if( exists $list2->{$tmp1} ) {
      $common += 1;
    } else {
      $only1 += 1;
    }
  }
  foreach my $tmp2 (keys %{$list2}) {
    if( not exists $list1->{$tmp2} ) {
      $only2 += 1;
    }
  }

  return ($common, $only1, $only2);
}
