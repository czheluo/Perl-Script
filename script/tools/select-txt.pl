#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fIn,$fOut,$select);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"i:s"=>\$fIn,
	"o:s"=>\$fOut,
	"select:s"=>\$select,
			) or &USAGE;
&USAGE unless ($fIn and $fOut and $select);

my%stat;
open IN,$select;
while(<IN>){
	chomp;
	next if(/^$/|| /^#/);
	#my$info=$_;
	#$info=~s/^\s+|\s+$//g;
	my$info=(split(/\_/,(split(/\t/,$_))[2]))[0];
	$stat{$info}=1;
}
close IN;

open In,$fIn;
if ($fIn =~ /.gz/) {
	close In;
	open In,"zcat $fIn|";
}
open OUT,">$fOut";
while (<In>) {
	chomp;
	next if(/^$/);
	if(/^#/){
		print OUT $_,"\n";
		next;
	}
	#my($id,$seq)=split/\n/,$_;
	#$id=~s/^\s+|\s+$//g;
	my($id,undef)=split/\t/,$_;
	next if(!exists $stat{$id});
	print OUT "$_\n";
}
close In;
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
  -i	<file>	input file name
  -o	<file>	output file name
  -select	<file>	select list filae
  -h         Help

USAGE
        print $usage;
        exit;
}
