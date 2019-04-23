#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($in,$out);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"ref:s"=>\$in,
	"out:s"=>\$out,
			) or &USAGE;
&USAGE unless ($in);
open IN,$in;
my $trans_id;
my $lnc_id;
my $flag=0;
open OUT,">$out";
print OUT "lncRNA\tTargetGene\tTargetPos\tlncRNAPos\tScore\tAlignment\n";
while(<IN>){
	chomp;
	next if ($_ eq "" || /^$/);
	if ($flag==0 && $_=~/Cs1g/){
		$_=~s/>//g;
		$trans_id = $_;
		$flag=1;
	}elsif($flag==1 && $_=~/MSTRG/){
		$_=~s/>//g;
		#print $_;die;
		($lnc_id,undef) = split("\t",$_);
		#print OUT "$_\t";
		$flag=2;
	}elsif ($flag==2 && $_=~/\(\.&\.\)/){
		#my @f1 = split /\s+/;
		#print $f1[-1],"\n";
		#$f1[-1] =~ /\((.*)\)/;
		#$energy = $1;
		#print $energy,"\n";
		#print $_;die;
		my ($aln,$pos,undef,$lncpos,$ids,undef)=split/\s+/,$_,6;
		$ids =~ s/\(//g;
		$ids =~ s/\)//g;
		#print $ids;die;
		#print 
		$flag=0;
		print OUT "$lnc_id\t$trans_id\t$pos\t$lncpos\t$ids\t$aln\n";
	}
}
close IN;
close OUT;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {
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
USAGE
        print $usage;
        exit;
}	
