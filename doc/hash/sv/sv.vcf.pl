#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fin1,$fout,$min,$fout1);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"int1:s"=>\$fin1,
	"out:s"=>\$fout,
	"out1:s"=>\$fout1,
			) or &USAGE;
&USAGE unless ($fin);

open IN,$fin;
my @start;
my @end;
my @id;
my @chr;
my %region;
#open Out,">$fout";
while (<IN>) {
	chomp;
	next if (/^Transposon_Name/);
	my ($id1,$ft,$start1,$end1,undef)=split/\s+/,$_;
	#print Dumper $id1;
	my ($id2,undef)=split/[E]/,$id1;
	#print Dumper @id2;die;
	$id2=~ s/AT/chr/g;
	$id2=~s/T//g;
	#print Dumper $id2;die;
	push @id,join("\t",$id1),"\n";
	push @chr,join("\t",$id2),"\n";
	push @start,join("\t",$start1),"\n";
	push @end,join("\t",$end1),"\n";
	#print Dumper $start;
	#print Dumper $end;die;
	my $chr=$id2;
	$region{$chr}{join("\t",$start1,$end1)}=$id1;
}
close IN;
#do not use the array to do complicate things
#print Out "@id\@chr";#\n@chr\t@start\t@end\n";

open IN,$fin1;
open Out,">$fout1";
my %stat;
while (<IN>) {
	chomp;
	next if ($_ eq "" || /^##/ || /^#/);
	my ($chr,$pos,$ID,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,$g1,$S1_Abn,$S1_Nor,$S3_Abn,$S3_Nor) =split(/\s+/,$_);
	next if($FILTER eq "LowQual");
	#print Dumper $FILTER;die;
	my ($gt1,undef)=split(/\:/,$g1);
	my ($gt2,undef)=split(/\:/,$S1_Abn);
	my ($gt3,undef)=split(/\:/,$S1_Nor);
	my ($gt4,undef)=split(/\:/,$S3_Abn);
	my ($gt5,undef)=split(/\:/,$S3_Nor);
	foreach my $region (sort keys %{$region{$chr}}) {
		my ($pos3,$pos4)=split(/\t/,$region);
		if ($pos >= $pos3 && $pos <= $pos4){
		if ($gt2 ne $gt1 ){
			$stat{$chr}{$region}{gt1}++;
		}
		if ($gt3 ne $gt1 ){
			$stat{$chr}{$region}{gt2}++;
		}
		if ($gt4 ne $gt1 ){
			$stat{$chr}{$region}{gt3}++;
		}
		if ($gt5 ne $gt1 ){
			$stat{$chr}{$region}{gt4}++;
		}
		if ($gt2 ne $gt1 && $gt3 ne $gt1 ){
			$stat{$chr}{$region}{gt5}++;
		}
		if ($gt2 ne $gt1 && $gt4 ne $gt1  ){
			$stat{$chr}{$region}{gt6}++;
		}
		if ($gt2 ne $gt1 && $gt5 ne $gt1  ){
			$stat{$chr}{$region}{gt7}++;
		}
		if ($gt3 ne $gt1 && $gt4 ne $gt1  ){
			$stat{$chr}{$region}{gt8}++;
		}
		if ($gt3 ne $gt1 && $gt5 ne $gt1  ){
			$stat{$chr}{$region}{gt9}++;
		}
		if ($gt4 ne $gt1 && $gt5 ne $gt1  ){
			$stat{$chr}{$region}{gt10}++;
		}
		if ($gt2 ne $gt1 && $gt3 ne $gt1 && $gt4 ne $gt1  ){
			$stat{$chr}{$region}{gt11}++;
		}
		if ($gt2 ne $gt1 && $gt3 ne $gt1 && $gt5 ne $gt1  ){
			$stat{$chr}{$region}{gt12}++;
		}
		if ($gt3 ne $gt1 && $gt4 ne $gt1 && $gt5 ne $gt1  ){
			$stat{$chr}{$region}{gt13}++;
		}
		if ($gt2 ne $gt1 && $gt3 ne $gt1 && $gt4 ne $gt1 && $gt5 ne $gt1  ){
			$stat{$chr}{$region}{gt14}++;
		}
		}
	}
		print Out "$chr\t$pos\t$ID\t$REF\t$ALT\t$gt1\t$gt2\t$gt3\t$gt4\t$gt5\t\n";
}
close IN;
close Out;
#print Dumper \%stat;die;
##from the first great to the more ....
open Out1,">$fout";
foreach my $chr (sort keys %region) {
	foreach my $region (sort keys %{$region{$chr}}) {
		$stat{$chr}{$region}{gt1}||=0;
		$stat{$chr}{$region}{gt2}||=0;
		$stat{$chr}{$region}{gt3}||=0;
		$stat{$chr}{$region}{gt4}||=0;
		$stat{$chr}{$region}{gt5}||=0;
		$stat{$chr}{$region}{gt6}||=0;
		$stat{$chr}{$region}{gt7}||=0;
		$stat{$chr}{$region}{gt8}||=0;
		$stat{$chr}{$region}{gt9}||=0;
		$stat{$chr}{$region}{gt10}||=0;
        $stat{$chr}{$region}{gt11}||=0;
		$stat{$chr}{$region}{gt12}||=0;
		$stat{$chr}{$region}{gt13}||=0;
		$stat{$chr}{$region}{gt14}||=0;
		print Out1 join("\t",$region{$chr}{$region},$chr,$region,$stat{$chr}{$region}{gt1},$stat{$chr}{$region}{gt2},$stat{$chr}{$region}{gt3},$stat{$chr}{$region}{gt4},$stat{$chr}{$region}{gt5},$stat{$chr}{$region}{gt6},$stat{$chr}{$region}{gt7},$stat{$chr}{$region}{gt8},$stat{$chr}{$region}{gt9},$stat{$chr}{$region}{gt10},$stat{$chr}{$region}{gt11},$stat{$chr}{$region}{gt12},$stat{$chr}{$region}{gt13},$stat{$chr}{$region}{gt14}),"\n";
	}
}
close Out1;

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
	-int input Transposon_Name file name
	-int1 input cnv or sv vcf result file name
	-out1 final result file name
	-out ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
