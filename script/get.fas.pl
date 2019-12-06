#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fin1,$table,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"fa1:s"=>\$fin,
	"fa2:s"=>\$fin1,
	"table:s"=>\$table,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open IN,$fin;
my %seq;
$/ = ">";
while(<IN>){
	chomp;
	next if ($_ eq "" || /^$/);
	my ($chr,$seq) = split(/\n/,$_,2);
	$seq =~ s/\n//g;
	$seq{$chr} = $seq;
}
close IN;
$/ = ">";
open In,$fin1;
my %seq1;
while (<In>) {
	chomp;
	next if ($_ eq "" || /^$/);
	my ($chr,$seq) = split(/\n/,$_,2);
	$seq =~ s/\n//g;
	$seq1{$chr} = $seq;
}
close In;
$/ = "\n";
open TA,$table;
open Out,">$fout";
while (<TA>) {
	chomp;
	if ($_ =~ "Seq") {
		print Out "$_\tseq_fa\ttarget_fa\n";
	}else{
		my ($se,$tar,undef,undef,$se_start,$se_end,$tar_start,$tar_end)=split/\t/,$_;
		my $pos1 = $se_start-1;
		if ($pos1 <= 0) {
			$pos1 =0;
		}else{
			$pos1 =$pos1;	
		}
		my $part1 = substr($seq{$se},$pos1,($se_end-$se_start));
		my $pos2 = $tar_start-1;
		if ($pos2 <= 0) {
			$pos2 =0;
		}else{
			$pos2 =$pos2;	
		}
		my $part2 = substr($seq1{$tar},$pos2,($tar_end-$tar_start));
		print Out "$_\t$part1\t$part2\n";

	}

}
close TA;
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

	eg: perl -int filename -out filename 
	
Usage:
  Options:
	"fa1:s"=>\$fin,
	"fa2:s"=>\$fin1,
	"table:s"=>\$table,
	"out:s"=>\$fout,

USAGE
        print $usage;
        exit;
}
