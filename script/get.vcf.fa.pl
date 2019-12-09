#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($in,$out,$min,$vcf,$list);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"ref:s"=>\$in,
	"out:s"=>\$out,
	"region:s"=>\$min,
	"vcf:s"=>\$vcf,
	"list:s"=>\$list,
			) or &USAGE;
&USAGE unless ($out);
open IN,$in;
my %seq;
$/ = ">";
while(<IN>){
	chomp;
	next if ($_ eq "" || /^$/);
	my ($chr,$seq) = split(/\n/,$_,2);
	$seq =~ s/\n//g;
	$seq{$chr} = $seq;
}
#print Dumper %seq;die;
close IN;

$/ = "\n";
open LT,$list;
my %list;
while (<LT>) {
	chomp;
	$list{$_}=1;
}
close LT;

open VCF,$vcf;
if($vcf=~/gz$/){
	close VCF;
	open VCF,"gunzip -c $vcf|";
}
open Out,">$out";
my %gcta;
while (<VCF>) {
	chomp;
	next if (/^##/);
	if (/#/) {
		my($chr,$start,$id,$ref,$alt,$qual,$Filter,$indo,$format,$all)=split/\t/,$_,10;
		#my @alls=split/\t/,$all;
		#my $ma=$alls[-1];
		#my $fa=$alls[-2];
		print Out "chr\tmarker\tfa_seq\tmo_seq\n";
	}else{
		my($chr,$start,$id,$ref,$alt,$qual,$Filter,$indo,$format,$all)=split/\t/,$_,10;
		my @alls=split/\t/,$all;
		if (exists $list{$id}) {
			my $ma=$alls[-1];
			my $fa=$alls[-2];
			my ($na,$nad,undef)=split(/\:/,$ma,3);
			my ($nb,$nbd,undef)=split(/\:/,$fa,3);
			#next if($na eq "./." || $nb eq "./.");
			$na=~s/0/$ref/g;
			$na=~s/1/$alt/g;
			$nb=~s/0/$ref/g;
			$nb=~s/1/$alt/g;
			$na=~s/2/$alt/g;
			$nb=~s/2/$alt/g;
			$gcta{$id}{mo}=join("-",$ref,$na);
			$gcta{$id}{fa}=join("-",$ref,$nb);
			$chr =~ s/Scaffold/sca/g;
			$chr =~ s/Chr/chr/g;
			my $pos = $start-150;
			if ($pos <= 0) {
				$pos =0;
			}else{
				$pos =$pos;	
			}
			my $part1 = substr($seq{$chr},$pos,149);
			my $part2 = substr($seq{$chr},$start,150);
			print Out "$chr\t$id\t$part1\_$gcta{$id}{fa}\_$part2\t$part1\_$gcta{$id}{mo}\_$part2\n";
		}else{
			next;
		}
		
	}
}
close VCF;
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
	perl $Script -ref ref.fa -region marker.list -out marker.fa -vcf pop.name.recode.vcf

Usage:
  Options:
	"ref:s"=>\$in,   ref.fa
	"out:s"=>\$out,   region.fa
	"region:s"=>\$min,  region.bed
	"list:s"=>\$list,
	-h         Help

USAGE
        print $usage;
        exit;
}
