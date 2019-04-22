#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$min);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
$/=">";
open IN,$fin;
open OUT,">$fout";
while (<IN>) {
	chomp;
	next if ($_ eq ""||/^$/);
	my ($pri,$seq)=split/\n/;
	my ($seq_F,$seq_R,$len_F,$len_R,$qual_F,$qual_R);
	($seq_F,$seq_R)=split(/XXXXXXXXXX/,$seq);
	$len_F=length($seq_F);
	$len_R=length($seq_R);
	$qual_F = "K" x $len_F;
	$qual_R = "K" x $len_R;
	print OUT "\@$pri-F\n$seq_F\n+\n$qual_F\n\@$pri-R\n$seq_R\n+\n$qual_R\n"
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

Usage:
  Options:
	-int intput file name
	-out output file name
	-h         Help

USAGE
        print $usage;
        exit;
}
