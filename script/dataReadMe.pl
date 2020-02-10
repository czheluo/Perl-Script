#!/usr/bin/env perl
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
	"i:s"=>\$in,
	"o:s"=>\$out,
			) or &USAGE;
&USAGE unless ($out);
$in||="1.fastq.gz";
my @file=glob("*$in");
open Out,">$out";
print Out "SampleID\tRead1 File Name\tRead2 File Name\n";
foreach my $file (@file) {
	my $name;
	if($file=~/\_R1/){
		my @a=split(/\_/,(split(/\_R1/,(split(/\:/,$file))[-1]))[0]);#B0908lane2:YMH0905_1:MJ20180228006_G_526_R2.fastq.gz	
		shift@a;
		$name=join("\_",@a);
		#$name=join("\_",$a[-2],$a[-1]) if(scalar@a eq "3");
		#$name=$a[-1] if(scalar@a ne "3");
	}else{
		$name=(split(/\./,(split(/\:/,$file))[-1]))[0];
		$name=(split(/\-/,$name))[0];
	}
	my $fq2=$file;
	if($in eq "1.fastq.gz"){
		$fq2=~s/1.fastq.gz/2.fastq.gz/g;
	}elsif($in =~/R1/){
		$fq2=~s/R1/R2/g;
	}elsif($in =~/1.1./){
		$fq2=~s/\.1\.1\./\.2\.2\./g;
	}
	print Out "$name\t$file\t$fq2\n";
}
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
Usage:
  Options:
  -i	<format>	input file format(fastq.gz|fastq|vcf)
  -o	<file>	output file name
  -h         Help
USAGE
        print $usage;
        exit;
}
