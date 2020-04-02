#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($list,$table,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"l|list:s"=>\$list,
	"t|table:s"=>\$table,
	"o|out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$list;
my %lm;
while (<In>) {
	chomp;
	next if(/^geneid/);
	#my ($id,undef)=split/\s+/,$_;
	$lm{$_}=1;
}
close In;

open In,$table;
open Out,">$fout";
while (<In>) {
	chomp;
	if ($_ =~ "geneid"){
		next;
		#print Out "$_\n";
	}else{
		my ($id,$all)=split/\s+/,$_,2;
		my @alls=split/\s+/,$all;
		my @result;
		for (my $i=0;$i < scalar @alls;$i=$i+3) {
			my $n1=$i+1;
			my $n2=$i+2;
			my $total= $alls[$i]+$alls[$n1]+$alls[$n2];
			my $mean=$total/3;
			#print "$mean\n";
			#print "$i\t$n1\t$n2\n";
			#print "$alls[$i]\t$alls[$n1]\t$alls[$n2]\n";
			push @result,join("\t",$mean);
		}
		#print Dumper @result;die;
		print Out join("\t",$id,@result),"\n";
	}
}
close In;
close Out;

#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:

	eg: perl $Script -list res.list -table res.result.xls -out res.result.mean.xls 
	

Usage:
  Options:
	-list input file name
	-table ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
