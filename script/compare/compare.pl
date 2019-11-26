#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin1,$fout,$table,$fin2);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int1:s"=>\$fin1,
	"int2:s"=>\$fin2,
	"table:s"=>\$table,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin1;
my %list;
while (<In>) {
	chomp;
	my($chrom,$pos,$ref,$alt,$details)=split/\s+/,$_,5;
	my $id=join("_",$chrom,$pos);
	#print $id;die;
	$list{$id}=1;
}
close In;

open IN,$fin2;
open Out,">$fout";
while (<IN>) {
	chomp;
	my($chrom,$pos,$ref,$alt,$details)=split/\s+/,$_,5;
	my $id=join("_",$chrom,$pos);
	next if (exists $list{$id});
	print Out "$_\n";
}
close IN;
close Out;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:

	eg: perl $Script -int1 CN.filter.xls -int2 TCN.filter.xls -out TCN.uniq.xls
	

Usage:
  Options:
	-int input file name
	-out ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
