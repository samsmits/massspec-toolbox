#!/usr/bin/perl -w
use strict;
use warnings;
use MIME::Base64;

my @mz_list;
my @intensity_list;

my $file_base = 'spectra_ORBI';
open(LIST,"$file_base.txt");
while(<LIST>) {
  chomp;
  my ($mz, $intensity) = split(/\s+/);
  push(@mz_list,$mz);
  push(@intensity_list,$intensity);
}
close(LIST);

my $count = $#mz_list + 1;
open(ASCII,">$file_base"."_ascii.encode");
print ASCII $count,"\n";
print ASCII join(" ",@mz_list),"\n";
print ASCII join(" ",@intensity_list),"\n";
close(ASCII);

my $packed_mz = pack("d".$count,@mz_list);
my $packed_intensity = pack("d".$count,@intensity_list);
open(PACK,">$file_base"."_packed.encode");
print PACK $packed_mz;
print PACK $packed_intensity;
close(PACK);

my @unpack_mz = unpack("d".$count, $packed_mz);
my @unpack_intensity = unpack("d".$count, $packed_intensity);
open(UNPACK,">$file_base"."_unpacked.encode");
print UNPACK $count,"\n";
print UNPACK join(" ",@unpack_mz),"\n";
print UNPACK join(" ",@unpack_intensity),"\n";
close(UNPACK);

my $encoded_mz = encode_base64($packed_mz);
my $encoded_intensity = encode_base64($packed_intensity);

open(BASE,">$file_base"."_base64.encode");
print BASE $count,"\n";
print BASE $encoded_mz;
print BASE "__XXXXXX__\n";
print BASE $encoded_intensity;
close(BASE);
