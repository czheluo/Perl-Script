#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	#"i:s"=>\$fIn,
	#"i2:s"=>\$fIn,
	"i:s"=>\$fin,
	"o:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
$/ = "group\t";
open IN,$fin;
my %hash;
while (<IN>){	
	chomp;
	next if ($_ eq "" || /^$/);
	my ($gro,$mar)=split(/\n/,$_,2); 
	$hash{$gro}=$mar;
}
close IN;
$/ = "\n";
open OUT,">$fout";

foreach my $tmp(sort {$a <=>$b} keys %hash){
	chomp($tmp);
	print OUT "group\t$tmp\n$hash{$tmp}\n";
}
close OUT;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        minghao.zhang\@majorbio.com;
Script:			$Script
Description:
	fq thanslate to fa format
	eg:
	perl $Script -i -o -k -c

Usage:
  Options:
  -i	<file>	input total.*.map
  -o	<file>	output total.*.map
  -h         Help

USAGE
        print $usage;
        exit;
}
