#!/usr/bin/env perl
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fIn,$fOut,$report,$fmtrix);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"vcf:s"=>\$fIn,
	"stat:s"=>\$fOut,
			) or &USAGE;
&USAGE unless ($fIn and $fOut);
my %TsTv=(
	"AG"=>"Ts",
	"TC"=>"Ts",
	"CT"=>"Ts",
	"GA"=>"Ts",
	"AT"=>"Tv",
	"AC"=>"Tv",
	"GT"=>"Tv",
	"CG"=>"Tv",
	"AC"=>"Tv",
	"GC"=>"Tv",
	"TA"=>"Tv",
	"TG"=>"Tv",
);
open In,$fIn;
if ($fIn=~/.gz$/) {
	close In;
	open In,"gunzip -c $fIn|";
}
#my @indi;
my %diff;
while (<In>) {
	chomp;
	next if ($_ eq "" || /^$/ || /^##/);
	my($chr,$pos,$id,$ref,$alt,$qual,$Filter,$indo,$format,@geno)=split(/\t/,$_);
	#next if ($Filter ne "PASS" && $Filter ne "SNP" && $Filter ne "INDEL" && $Filter ne "FILTER" && $Filter ne ".");
	next if (length($ref) >1 || length($alt) > 1);
	my $all=join("",$ref,$alt);
	#print $all;die;
	if (exists $TsTv{$all}){
		$diff{$all}{$TsTv{$all}}++;
	}
}
close In;
open Out,">$fOut";
#print Out "#sampleID\tSNPnumber\tTransition\tTransvertion \n";#\tTs/Tv\tHeterozygosity Number\tHomozygosity Number\tAverage Depth\tMiss Number\tRef Number\n";
foreach my $type (sort keys %diff) {
	foreach my $TT (sort keys %{$diff{$type}}){
		print Out join("\t",$type,$TT,$diff{$type}{$TT}),"\n";
	}
}
close Out;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:
	eg:
	perl $Script -vcf PF_1.vcf.filter -stat PF_1.stat

Usage:
  Options:
  -vcf	<file>	input file name
  -out	<file>	output file name
  -h         Help

USAGE
        print $usage;
        exit;
}
