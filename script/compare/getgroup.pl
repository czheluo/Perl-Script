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
my @list1;
while (<In>) {
	chomp;
	push @list1,join("\t",$_);
}
close In;

open IN,$fin2;
my @list2;
while (<IN>) {
	chomp;
	push @list2,join("\t",$_);
}
close IN;

open DA,$table;
my @name;

open Out1,">$fout/CN.xls";
open Out2,">$fout/TCN.xls";
while (<DA>) {
	chomp;
	my($chrom,$pos,$ref,$alt,$details)=split/\s+/,$_,5;
	if ($_ =~ "CHROM") {
		my($chrom,$pos,$ref,$alt,$details)=split/\s+/,$_,5;
		@name=split/\s+/,$details;
	}else{
		my @sali;
		my @water;
		for (my $i1=0;$i1 < scalar @list1;$i1++) {
			my($chrom,$pos,$ref,$alt,$details)=split/\s+/,$_,5;
			my @all1=split/\s+/,$details;
			for (my $j1=0;$j1 < scalar @all1;$j1++) {
				if ($name[$j1] =~ $list1[$i1]) {
					push @sali,join("\t",$all1[$j1]);
				}
			}
		}
		for (my $i2=0;$i2 < scalar @list2;$i2++) {
			my($chrom,$pos,$ref,$alt,$details)=split/\s+/,$_,5;
			my @all2=split/\s+/,$details;
			for (my $j2=0;$j2 < scalar @all2;$j2++) {
				if ($name[$j2] =~ $list2[$i2]) {
					push @water,join("\t",$all2[$j2]);
				}
			}
		}
		print Out1 "$chrom\t$pos\t$ref\t$alt\t",join("\t",@sali),"\n";
		print Out2 "$chrom\t$pos\t$ref\t$alt\t",join("\t",@water),"\n";
	}
}
close DA;
close Out1;
close Out2;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:

	eg: perl $Script -int1 CN.list -int2 TCN.list -out ./ -table snp.xls
	

Usage:
  Options:
	-int input file name
	-out ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
