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
my ($fIn,$fOut,$vcf,$list);
GetOptions(
		"help|?" =>\&USAGE,
		"int:s"=>\$fIn,
		"vcf:s"=>\$vcf,
		"out:s"=>\$fOut,
		"list:s"=>\$list
				) or &USAGE;
&USAGE unless ($fIn);
open LS,$list;
my %lists;
while (<LS>) {
	chomp;
	$lists{$_}=1;
}
close LS;

open In,$fIn;
#open Out,">$fOut";
open VCF,">$vcf";
my $ii;
my @sample;
my %nums;
while (<In>) {
	chomp;
	if(/^##/){
		print VCF "$_\n";
	}
	next if ($_ eq ""||/^$/ ||/^##/);
	if (/^#/) {
		my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@info)=split(/\t/,$_);
		#push @sample,join("\t","Z160097");
		for (my $i=0;$i< scalar @info ;$i++) {
			if (exists $lists{$info[$i]}) {
				$nums{$i}=$info[$i];
			}
			#if ($info[$i] eq "Z160097") {
			#	$ii=$i;
			#}else{
			#	push @sample,join("\t",$info[$i]);
			#}
		}
		#print Out "$chrom\t$pos\t$id\t$ref\t$alt\t",join("\t",@info),"\n";
		print VCF "$_\n";
	}else{
		my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@info)=split(/\t/,$_);
		open LST,$list;
		my $nn=0;
		while (<LST>) {
			chomp;
			my $gt;
			my @gts;
			my $dn=0;
			my $samp=$_;
			for (my $ii=0;$ii< scalar @info ;$ii++) {
				if ($samp eq $nums{$ii}) {
					#print "$ii\n";
					#print "$samp\n";
					
					($gt,undef)=split/\:/,$info[$ii],2;
					#print "$gt\n";
					#print Dumper %nums;die;
					#push @gts,join("\t",$gt1);
				}else{
					next if(exists $lists{$nums{$ii}});
					my ($gt1,undef)=split/\:/,$info[$ii],2;	
					push @gts,join("\t",$gt1);
				}
			}
			for (my $j=0;$j < scalar @gts;$j++) {
				#next if ($gts[$j] eq "./.");
				if ($gt ne $gts[$j]) {
					$dn++;
				}
			}
			if($dn > 10){
				$nn++
			}
		}
		close LST;
		if ($nn >6) {
			#print VCF "$_\n";
			print VCF "$chrom\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t$info\t$format,",join("\t",@info),"\n";
		}
		
	}
}
close In;
close Out;
close VCF;
#print Dumper %stat;
open In,
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
