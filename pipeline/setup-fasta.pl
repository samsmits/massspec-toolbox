#!/usr/bin/perl -w
use File::Spec;
use strict;

require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/pipeline/conf.pl';

my $path = &get_path();

my $usage_mesg = "Usage: /pipeline/setup-fasta.pl <DB name> <FASTA file>";
if( $#ARGV != 1 ) {
  print STDERR $usage_mesg,"\n";
  exit(1);
}

my $DB_name = $ARGV[0];
my $filename_fasta = $ARGV[1];
if( not -e $filename_fasta ) {
  print STDERR "$filename_fasta is not available.\n";
  print STDERR $usage_mesg,"\n";
  exit(1);
}

$filename_fasta = File::Spec->rel2abs($filename_fasta);
print STDERR "Setting MS/MS DB for $filename_fasta\n";
open(DBINFO,">DBINFO");
print DBINFO $DB_name,"\t",$filename_fasta,"\n";
close(DBINFO);

my $path_crux = $path->{'crux'};
print STDERR "Setting DB for CRUX by $path_crux ... \n";
my $dirname_crux_index = $DB_name.'.crux-index';
`$path_crux create-index $filename_fasta $dirname_crux_index --overwrite T`;

print STDERR "Setting DB for InsPecT ... \n";
my $filename_inspect_trie = $DB_name.'.trie';
my $filename_inspect_index = $DB_name.'.index';
my $filename_inspect_shuffle = $DB_name.'RS.trie';
my $path_inspect_PrepDB = $path->{'inspect_PrepDB'};
my $path_inspect_ShuffleDB = $path->{'inspect_ShuffleDB'};
`python $path_inspect_PrepDB FASTA $filename_fasta $filename_inspect_trie $filename_inspect_index`;
`python $path_inspect_ShuffleDB -r $filename_inspect_trie -w $filename_inspect_shuffle -p`;

my $path_formatdb = $path->{'formatdb'};
print STDERR "Setting DB for OMSSA by $path_formatdb ... \n";
`$path_formatdb -p T -n $DB_name -i $filename_fasta`;

my $path_fasta_pro = $path->{'fasta_pro.exe'};
print STDERR "Setting DB for X!Tandem ... \n";
`$path_fasta_pro $filename_fasta`;
