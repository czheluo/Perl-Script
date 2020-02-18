#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
my ($chr,$out,$fa,$start,$end);        
GetOptions(
	"help|?" =>\&USAGE,
	"chr:s"=>\$chr,
	"start:s"=>\$start,     
	"end:s"=>\$end,   
	"fa:s"=>\$fa,
	"o:s"=>\$out,
			) or &USAGE;
&USAGE unless ($out and $fa);
#######################################################################################
$fa = ABSOLUTE_DIR($fa);

$/ = ">";
my %fasta;
open REF,$fa;
while (<REF>){
	chomp;
	next if (/^\s*$/);
	my ($header,@seq) = split /\n/;
	my $seq = join "",@seq;
	($header,undef) = split /\s+/,$header;
	$fasta{$header} = $seq;
	print "$header get!\n";
}
close REF;
$/ = "\n";
	
if ($start > $end){
	my $temp = $start;
	$start = $end;
	$end = $temp;
}

open OUT,">$out/$chr\.$start\-$end\.fa";
print OUT ">$chr pos:$start-$end\n";
my $seq = substr($fasta{$chr},$start-1,$end-$start+1);
print OUT "$seq\n";
close OUT;
	
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
		warn "Warning! just for existed file and dir \n$in";
		exit;
	}
	chdir $cur_dir;
	return $return;
}

sub USAGE {           #5
        my $usage=<<"USAGE";
Contact:	tong.wang\@majorbio.com
Version:	$version
Script:		$Script
Description:	
		get seq from start to end
Usage:
  Options:
	-chr	<str>
	-start	<str>	
	-end	<str>
	-fa	<file>	ref.fa
	-o	<dir>	output dir 
	-h		Help

USAGE
        print $usage;
        exit;
}
