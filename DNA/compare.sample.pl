#!/usr/bin/env perl 
use strict;
use warnings;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Data::Dumper;
my $BEGIN_TIME=time();
my $version="1.0.0";
#######################################################################################

# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($fIn,$fOut,$vcf);
GetOptions(
				"help|?" =>\&USAGE,
				"int:s"=>\$fIn,
				"vcf:s"=>\$vcf,
				"out:s"=>\$fOut,
				) or &USAGE;
&USAGE unless ($fIn and $fOut);

open In,$fIn;
open Out,">$fOut";
open VCF,">$vcf";
my $ii;
my @sample;
while (<In>) {
	chomp;
	if(/^##/){
		print VCF "$_\n";
	}
	next if ($_ eq ""||/^$/ ||/^##/);
	if (/^#/) {
		my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@info)=split(/\t/,$_);
		push @sample,join("\t","Z160097");
		for (my $i=0;$i< scalar @info ;$i++) {
			if ($info[$i] eq "Z160097") {
				$ii=$i;
			}else{
				push @sample,join("\t",$info[$i]);
			}
		}
		print Out "$chrom\t$pos\t$id\t$ref\t$alt\t",join("\t",@sample),"\n";
		print VCF "$_\n";
	}else{
		my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@info)=split(/\t/,$_);
		my @gts;
		my $n=0;
		my ($gt1,undef)=split/\:/,$info[$ii],2;
		push @gts,join("\t",$gt1);
		for (my $i=0;$i< scalar @info ;$i++) {
			my ($gt,undef)=split/\:/,$info[$i],2;
			if (($i ne $ii) && ($gt ne $gt1)) {
				$n++;
				push @gts,join("\t",$gt);
			}
		}
		print "$n\n";
		if ($n eq 32 ) {
				print Out "$chrom\t$pos\t$id\t$ref\t$alt\t",join("\t",@gts),"\n";
				print VCF "$_\n";
			}
	}
}
close In;
close Out;
close VCF;
#print Dumper %stat;

#######################################################################################
print "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub readvcf{
	my ($line,$sample,$Sample,$anninfo,$baseinfo,$allenum)=@_;
	my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@info)=split(/\s+/,$line);
	$$baseinfo=join("\t",$chrom,$pos,$ref,$alt);
	my @alles=split(",",join(",",$ref,$alt));
	$$allenum=scalar @alles;
	if($info=~/ANN=([^\;]*)/g){
		my @ann=split(/\,/,$1);
		for (my $i=0;$i<@ann;$i++) {
			my @str=split(/\|/,$ann[$i]);
			$str[0]||="--";
			$str[1]||="--";
			$str[2]||="--";
			$str[3]||="--";
			$str[4]||="--";
			my $ann=join("|",$str[0],$str[1],$str[2],$str[3],$str[4]);
			push @{$anninfo},$ann;
		}
	}
	my %len;
	for (my $i=0;$i<@alles;$i++) {
		$len{length($alles[$i])}=1;
	}
	my $type="SNP";
	if (scalar keys %len > 1) {
		$type="INDEL";
	}
	my @format=split(/\:/,$format);
	for (my $i=0;$i<@info;$i++) {
		my @infos=split(/\:/,$info[$i]);
		for (my $j=0;$j<@infos;$j++) {
			if ($format[$j] eq "GT") {
				if ($infos[$j] =~ /\./) {
					$$sample{$$Sample[$i]}{$format[$j]}="NN";
					$$sample{$$Sample[$i]}{DP}=0;
					$$sample{$$Sample[$i]}{AD}=0;
				}else{
					my @gt=split(/\//,$infos[$j]);
					$$sample{$$Sample[$i]}{$format[$j]}=join("/",sort($alles[$gt[0]],$alles[$gt[1]]));
				}
			}
			if ($format[$j] eq "AD") {
				$$sample{$$Sample[$i]}{$format[$j]}=$infos[$j];
			}
			if ($format[$j] eq "DP") {
				$$sample{$$Sample[$i]}{$format[$j]}=$infos[$j];
			}
		}
	}
	return $type;
}

sub USAGE {#
	my $usage=<<"USAGE";
Description: 
Version:  $Script
Contact: meng.luo

Usage:
  Options:
	-vcf	<file>	input file name
	-out	<file>	output file name 
USAGE
	print $usage;
	exit;
}
