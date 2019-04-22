#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$min);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open IN,$fin;
open Out,">$fout";
print Out "ID\tpairrate\n";
while (<IN>) {
	chomp;
	next if (/^#/);
	my ($id1,$id2,$pair,undef)=split/\s+/,$_;
	#print Dumper $pair;die;
	next if ($pair<90);
	print Out "$id1\:$id2\t$pair\n";
	#print Out join(":",$id1,$id2,join("\t",$pair)),"\n";
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

	eg: perl -int filename -out filename 
	

Usage:
  Options:
	-int input file name
	-out ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
