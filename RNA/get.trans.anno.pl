#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($in,$fin,$out,$min);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"ref:s"=>\$in,
	"out:s"=>\$out,
	"region:s"=>\$min,
			) or &USAGE;
&USAGE unless ($out);
open FN,$fin;
open Out,">$out";
#my $seq;
#my $chr;
my %sa;
while (<FN>) {
	chomp;
	my($id,$fa,$gtf)=split/\s+/,$_;
	open In,$fa;
	my %seq;
	$/ = ">";
	while (<In>) {
		chomp;
		next if ($_ eq "" || /^$/);
		my ($chr,$seq) = split(/\n/,$_,2);
		$seq =~ s/\n//g;
		$sa{$chr}=$seq;
		#print $seq;die;
		my @all=split/\s+/,$chr;
		my $gene=$all[1];
		$gene=~s/gene=//g;
		#if ($all[0] eq "MSTRG.5715.2") {
		#	print "$chr\t$seq";die;
		#}
		next if($gene ne "CsaV3_3G015190");
		if ($gene eq "CsaV3_3G015190") {# && (undef $all[2])
			#print "$gene\n";
			open IN,$gtf;
			$/ = "\n";
			while (<IN>) {
				chomp;
				my ($chrs,undef,$type,$start,$end,undef,undef,undef,$all)=split/\s+/,$_,9;
				next if($type eq "exon");
				my ($gen,$tran,undef)=split/\;/,$all,3;
				#print $gen;die; 
				my (undef,$gens)=split/\s+/,$gen;
				$gens=~s/\"//g;
				my (undef,$trans)=split/\s+/,$tran;
				$trans=~s/\"//g;
				if ($gens eq "CsaV3_3G015190") {
					print Out "$id\t$chr\t$chrs\t$start\t$end\t$sa{$chr}\n";
				}
			}
			close IN;
		}

	}
	close In;
}
close FN;
close Out;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:
	fq thanslate to fa format
	eg:
	perl $Script -int files.list -out files.xls

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
