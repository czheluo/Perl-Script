#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($in,$out,$mr,$lnc);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"ref:s"=>\$in,
	"out:s"=>\$out,
	"mr:s"=>\$mr,
	"lnc:s"=>\$lnc,
			) or &USAGE;
&USAGE unless ($in);
my %rrd;
open In,$lnc;
while (<In>) {
	chomp;
	my ($fid,$rid)=split/\s+/,$_,2;
	$rrd{$fid}=$rid;
}
close In;
my %mrd;
open In,$mr;
while (<In>) {
	chomp;
	my ($mids,$mrid)=split/\s+/;
	$mrd{$mids}=$mrid;
	#print $mids;die;
}
close In;
open IN,$in;
my %seq;
$/ = ">";
open OUT,">$out";
while(<IN>){
		chomp;
		next if ($_ eq "" || /^$/);
		my ($id,$resu) = split(/\n/,$_,2);
		#print "$id\t$resu";die;
		if (exists $mrd{$id} && $resu eq ""){
			print OUT ">$mrd{$id}\n";
		}elsif (exists $rrd{$id} && $resu ne "") {
			print OUT ">$rrd{$id}\n$resu\n";
		}else {
			print OUT ">$id\n$resu\n";
		}	
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
	fq thanslate to fa format
	eg:
	perl $Script -i -o -k -c

Usage:
  Options:
	"help|?" =>\&USAGE,
	"ref:s"=>\$in,
	"out:s"=>\$out,
	"mr:s"=>\$mr,
	"lnc:s"=>\$lnc,

USAGE
        print $usage;
        exit;
}