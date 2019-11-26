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
open Out,">$fout";
while (<In>) {
	chomp;
	my($chrom,$pos,$ref,$alt,$details)=split/\s+/,$_,5;
	my @all=split/\s+/,$details;
	my $nn=0;
	for (my $i=0;$i < scalar @all ;$i=$i+4) {
		if ($all[$i] =~ $alt ){
			$nn++;
		}
	}
	next if($nn <1);
	print Out "$_\n";
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

	eg: perl $Script -int1 TCN.xls -out TCN.filter.xls 
	

Usage:
  Options:
	-int input file name
	-out ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
