#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($in,$out,$min,$vcf);
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
open VCF,$vcf;
my %gcta;
while (<VCF>) {
	chomp;
	next if (/^##/);
	if (/#/) {
		my($chr,$pos,$id,$ref,$alt,$qual,$Filter,$indo,$format,$ma,$fa)=split(/\t/,$_);
	}else{
		my($chr,$pos,$id,$ref,$alt,$qual,$Filter,$indo,$format,$ma,$fa)=split(/\t/,$_);
		my ($na,$nad,undef)=split(/\:/,$ma,3);
		my ($nb,$nbd,undef)=split(/\:/,$fa,3);
		next if($na eq "./." || $nb eq "./.");
		$na=~s/0/$ref/g;
		$na=~s/1/$alt/g;
		$nb=~s/0/$ref/g;
		$nb=~s/1/$alt/g;
		$na=~s/2/$alt/g;
		$nb=~s/2/$alt/g;
		$gcta{$id}{mo}=$na;
		$gcta{$id}{fa}=$nb;
	}
}
#print %gcta;die;
$/ = "\n";
open IN,$min;
open OUT,">",$out;
while(<IN>){
	chomp;
	next if ($_ eq "" || /^$/ || /position/ || /begin/);
	next if(/^Locus/);
	s/^\s+//g;
	my ($id,$chr,$start,undef)=split/\s+/;
	#print $id;
	#print $gcta{$id}{fa};
	#print $gcta{$id}{mo};die;
	my $end=$start+40;
	$chr =~ s/Scaffold/sca/g;
	$chr =~ s/Chr/chr/g;
	my $pos = $start-18;
	if ($pos <= 0) {
		$pos =0;
	}else{
		$pos =$pos;	
	}
	my $part1 = substr($seq{$chr},$pos,19);
	my $part2 = substr($seq{$chr},$start,19);
	#print "$pos\t$end\n$part\n";die;
	#print OUT ">$chr:$pos-$end\n$part\n";
	print OUT "$chr\t$id\t$part1\_$gcta{$id}{fa}\_$part2\t$part1\_$gcta{$id}{mo}\_$part2\n";
}
close IN;
close OUT;
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
  -h         Help

USAGE
        print $usage;
        exit;
}
