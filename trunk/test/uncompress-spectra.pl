#!/usr/bin/perl -w
use strict;
use warnings;
use MIME::Base64;

my @mz_list;
my @intensity_list;

my $file_base = 'spectra_ORBI';
my $sep = "__XXXXXX__";
my $tmp = '';
my $encoded_mz = '';
my $encoded_intensity = '';
open(LIST,"$file_base"."_base64.encode");
my $count = <LIST>;
chomp($count);
while(my $line = <LIST>) {
  #chomp($line);
  if( $line =~ /$sep/ ) {
    $encoded_mz = $tmp;
    $tmp = '';
    next;
  } 
  $tmp .= $line;
}
close(LIST);
$encoded_intensity = $tmp;
chomp($encoded_mz);
chomp($encoded_intensity);

#print $encoded_mz," ENDMZ\n",$encoded_intensity," ENDINT\n";

my $decoded_mz = decode_base64($encoded_mz);
my $decoded_intensity = decode_base64($encoded_intensity);

open(PACK,">$file_base"."_packed.decode");
print PACK $decoded_mz;
print PACK $decoded_intensity;
close(PACK);

my @unpack_mz = unpack("d".$count, $decoded_mz);
my @unpack_intensity = unpack("d".$count, $decoded_intensity);

open(UNPACK,">$file_base"."_ascii.decode");
print UNPACK $count,"\n";
print UNPACK join(" ",@unpack_mz),"\n";
print UNPACK join(" ",@unpack_intensity),"\n";
close(UNPACK);

