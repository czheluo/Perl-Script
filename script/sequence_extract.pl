#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($in,$out,$min);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"ref:s"=>\$in,
	"out:s"=>\$out,
	"region:s"=>\$min,
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
open IN,$min;
open OUT,">",$out;
while(<IN>){
	chomp;
	next if ($_ eq "" || /^$/ || /position/ || /begin/);
	s/^\s+//g;
	my ($chr,$start,$end)=split/\s+/;
#	print "$chr\t$start\t$end\n";
#	die if ($start eq "25231");
	$chr =~ s/Scaffold/sca/g;
	$chr =~ s/Chr/chr/g;
	my $pos = $start-1;
	if ($pos <= 0) {
		$pos =0;
	}else{
		$pos =$pos;	
	}
	my $part = substr($seq{$chr},$pos,($end-$start+1));
	print OUT ">$chr:$start-$end\n$part\n";
}
close IN;
close OUT;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        minghao.zhang\@majorbio.com;
Script:			$Script
Description:

	eg:
	perl $Script -ref ../sanger_data/02.reference/ref.fa -out region.fa -region seq.list

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
