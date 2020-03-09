#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$index);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"index:s"=>\$index,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);

open In,$fin;
open Out,">$fout";
#print Out "chr    pos1    pos2    index1  index2  delta   threhold        total   peak    pvalue  fdr\n";
my %chrs;
while (<In>) {
	chomp;
	if ($_ =~ "#"){
		print Out "$_\n";
	}else{
		my ($chr,$pos1,$pos2,$index1,$index2,$deta,$thre,$total,$peak,$pvlaue,$fdr)=split/\s+/,$_;
		#print Out "$chr\_$pos\t$chr\t$pos\t$INDEX1\t$INDEX2\t$deta\tdetanew\n";
		push @{$chrs{$chr}},join("\t",join("\t","$chr\_$pos1",$_));
	}
}
close In;
open IN,$index;
while(<IN>){
	chomp;
	foreach my $chr (sort keys %chrs){
		next if ($chr ne $_);
		foreach my $chrss (@{$chrs{$chr}}){
			print Out "$chrss\n";	
		}
		
	}
}
close IN;
close Out;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub ABSOLUTE_DIR #$pavfile=&ABSOLUTE_DIR($pavfile);
{
	my $cur_dir=`pwd`;chomp($cur_dir);
	my ($in)=@_;
	my $return="";
	if(-f $in){
		my $dir=dirname($in);
		my $file=basename($in);
		chdir $dir;$dir=`pwd`;chomp $dir;
		$return="$dir/$file";
	}elsif(-d $in){
		chdir $in;$return=`pwd`;chomp $return;
	}else{
		warn "Warning just for file and dir \n$in";
		exit;
	}
	chdir $cur_dir;
	return $return;
}
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:

	eg: perl $Script -int sliding-win.result.xls -index chr -out cmplot.xls
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-index bsa result table
	-h         Help

USAGE
        print $usage;
        exit;
}
