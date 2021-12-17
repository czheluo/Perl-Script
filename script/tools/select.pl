#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fIn,$fOut,$split,$col,$select);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"i:s"=>\$fIn,
	"o:s"=>\$fOut,
	"col:s"=>\$col,
	"split:s"=>\$split,
	"select:s"=>\$select,
			) or &USAGE;
&USAGE unless ($fIn and $fOut and $select);
$split||="\t";
$col||=1;

my $real= $col - 1;

my%stat;
open IN,$select;
while(<IN>){
	chomp;
	next if(/^$/|| /^#/);
	my$info=$_;
	$info=~s/^\s+|\s+$//g;
	$stat{$info}=1;
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
	my @a=split/$split/,$_;
	#print "$a[$real]\n";die;
	next if(!exists $stat{$a[$real]});
	print Out $_,"\n";
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
  -select	<file>	select list filae
  -col	<num>	the change column
  -split	<str>	the split character infile's per column
  -h         Help

USAGE
        print $usage;
        exit;
}
