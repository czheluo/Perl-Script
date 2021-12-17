#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fIn,$fOut,$split,$type);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Statistics::Distributions;
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"i:s"=>\$fIn,
	"o:s"=>\$fOut,
	"split:s"=>\$split,
	"type:s"=>\$type,
			) or &USAGE;
&USAGE unless ($fIn);
sub USAGE {#
         my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:         $Script
Description:
	raw fq split and qc
	eg:
	perl $Script -i <file> -o <dir> -split 1 -type 1

Usage:
   Options:
	-i	<file>	sample.list
	-o	<file>	output file
	-split	<num>	defult 1
	-type	<num>	defult 1
	-h         Help
##########################################################################################################
split 1: BXY0424_5 (infile lib "_" && data lib "_")
split 2: BXY0424-5 (infile lib "_" && data lib "-")
##########################################################################################################
type 1: /mnt/ilustre/data-split/hiseq/hiseq4000/20190401sXten/D0401lane3/D0401lane3_L1HDC210088_MZ18/MZ18_S87_L003_R1_001.fastq.gz
type 2: /mnt/ilustre/upload/hiseq/hiseq4000/2019/Fastq/20190425nNG/D0425S2-L2EDD120117-JP4-1_BKDL190807312-1a-11/D0425S2-L2EDD120117-JP4-1_BKDL190807312-1a-11_1.fq.gz
type 3: /mnt/ilustre/upload/hiseq/hiseq4000/2019/Fastq/20190429sNG/BXY0424-6_S6_L004_R1_001.fastq.gz
type 4: 
##########################################################################################################

USAGE
        print $usage;
        exit;
}

$fOut||="fq.lib.list";
$split||=1;
$type||=1;
open In,$fIn;
open Out,">$fOut";
my$line=0;
my($lineid,$libid,$samid,$pwdid, $lane,$lib,$fq1,$fq2);
while(<In>){
	chomp;
	next if($_ eq ""|| /^$/);
	if($line eq "0"){
		my@info=split(/\t/,$_);
		for(my$i=0;$i<scalar@info;$i++){
			$lineid=$i if($info[$i] =~ /lane/);
			$libid=$i if($info[$i] =~ /文库编号/);
			$samid=$i if($info[$i] =~ /样品名称/);
			$pwdid=$i if($info[$i] =~ /比对编号/|| $info[$i]=~ /数据名/);
			$pwdid=$i if($info[$i] =~ /单位/);
		}
		$line++;
#		print join("\n","lane $lineid","文库编号 $libid","比对编号 $pwd"),"\n";
		next;
	}
	my@stats=split(/\t/,$_);
	$lane=$stats[$lineid];
	$lib=$stats[$libid];
	my $sample=$stats[$samid];
	my $pwd=$stats[$pwdid];
	if($split eq "2"){
		$lib=~ s/\_/-/g;
	}
	if($type eq "1"){#/mnt/ilustre/data-split/hiseq/hiseq4000/20190401sXten/D0401lane3/D0401lane3_L1HDC210088_MZ18/MZ18_S87_L003_R1_001.fastq.gz
		#my$file=`ls $pwd\/$lane\/*$lane\_*\/*$sample\_S*\_R1_001.fastq.gz`;
		my$file=`ls $pwd\/$lane\/$lane*$lib*\/*$sample\_S*\_R1_001.fastq.gz`;
		$fq1=(split(/\s+/,$file))[0];
		$fq2=$fq1;
		$fq2=~s/\_R1\_001/\_R2_001/g;
	}elsif($type eq "2"){#/mnt/ilustre/upload/hiseq/hiseq4000/2019/Fastq/20190425nNG/D0425S2-L2EDD120117-JP4-1_BKDL190807312-1a-11/D0425S2-L2EDD120117-JP4-1_BKDL190807312-1a-11_1.fq.gz
		my$file=`ls $pwd\/$lane*$lib*$sample*/*_1.fq.gz`;
		$fq1=(split(/\s+/,$file))[0];
		if(!defined "$pwd\/$lane*$lib*$sample*/*_1.fq.gz"){
			print "!exists $pwd\/$lane*$lib*$sample*/*_1.fq.gz file \n";
			die;
		}
		$fq2=$fq1;
		$fq2=~s/\_1.fq.gz/\_2.fq.gz/g;
	}elsif($type eq "3"){#/mnt/ilustre/upload/hiseq/hiseq4000/2019/Fastq/20190429sNG/BXY0424-6_S6_L004_R1_001.fastq.gz
#		my $file=`ls $pwd\/*$lib*R1_001.fastq.gz`;
		my $file=`ls $pwd\/*$lib*_R1*fastq.gz`;
		$fq1=(split(/\s+/,$file))[0];
		if(!defined "$pwd\/*$lib*_R1*fastq.gz"){
			print "!exists $pwd\/*$lib*R1*fastq.gz file \n";
			die;
		}
		$fq2=$fq1;
		$fq2=~s/\_R1/\_R2/g;
	}
	print Out "$lane\t$stats[$libid]\t$fq1\t$fq2\n";
}
close In;
close Out;
#######################################################################################
#print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
