#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fIn,$fOut,$changefile,$split,$col);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"i:s"=>\$fIn,
	"o:s"=>\$fOut,
	"g:s"=>\$changefile,
	"col:s"=>\$col,
	"split:s"=>\$split,
			) or &USAGE;
&USAGE unless ($fIn and $fOut and $changefile);
$split||="\t";
$col||=1;

my $real= $col - 1;
my %stat;
open IN,$changefile;
while(<IN>){
	chomp;
	next if ($_ eq "" || /^$/);
	my($sample,$newid)=split/\s+/,$_;
	$stat{$sample}=$newid;
}
close IN;

open In,$fIn;
if ($fIn =~ /.gz/) {
	close In;
	open In,"zcat $fIn|";
}
my @info;
open Out,">$fOut";
while (<In>) {
	chomp;
	next if(/^$/);
	my $info=$_;
	my @a=split/$split/,$info;
	#print "$a[$real]\n";die;
	$a[$real] = $stat{$a[$real]} if(exists $stat{$a[$real]});
	print Out join("\t",@a),"\n";
}
close In;
close Out;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:

Usage:
  Options:
  -i	<file>	input file name
  -o	<file>	output file name
  -g	<file>	sample change file
  -col	<num>	the change column
  -split	<str>	the split character infile's per column
  -h         Help

USAGE
        print $usage;
        exit;
}
