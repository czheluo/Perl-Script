#!/usr/bin/env perl 
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($ref,$fqlist,$dOut,$dShell,$proc);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"ref:s"=>\$ref,
	"fqlist:s"=>\$fqlist,
	"out:s"=>\$dOut,
	"dsh:s"=>\$dShell,
	"proc:s"=>\$proc,
			) or &USAGE;
&USAGE unless ($ref and $fqlist and $dOut and $dShell);
###########################################################
mkdir $dOut if (!-d $dOut);
$proc||=20;
$ref=ABSOLUTE_DIR($ref);
$dOut=ABSOLUTE_DIR($dOut);
$fqlist=ABSOLUTE_DIR($fqlist);
mkdir $dShell if (!-d $dShell);
$dShell=ABSOLUTE_DIR($dShell);

open SH,">$dShell/bwa-mapping.sh";
open In,$fqlist;
open Out,">$dOut/bam.list";
my %bam;
my %bamfile;
my %sample;
my %type;
while (<In>) {
	chomp;
	next if ($_ eq "" || /^$/);
	my ($sampleID,$fq1,$fq2,$type)=split(/\s+/,$_);
	$type{$sampleID}=$type;
	$fq1=ABSOLUTE_DIR($fq1);
	$fq2=ABSOLUTE_DIR($fq2);
	if (!-f $fq1 || !-f $fq2) {
		die "check $fq1\ncheck $fq2";
	}
	$sample{$sampleID}=1;
	my $nsample=scalar keys %sample;
	$bam{$sampleID}++;
	print SH "bwa mem  -M -a -t 8 -R \"\@RG\\tID:$nsample\\tLG:$sampleID\\tLB:$bam{$sampleID}\\tPL:illumina\\tSM:$sampleID\\tPU:run_barcode\\tCN:MajorBio\tDS:reseq\" $ref $fq1 $fq2| samtools view -bS - > $dOut/$sampleID.b$bam{$sampleID}.bam\n";
	push @{$bamfile{$sampleID}},"$dOut/$sampleID.b$bam{$sampleID}.bam";
}
close In;
close SH;
foreach my $sampleID (keys %bamfile) {
	print Out $sampleID,"\t",$type{$sampleID},"\t",join("\t",@{$bamfile{$sampleID}}),"\n";
}
close Out;
#my $job="qsub-slurm.pl  --Resource mem=5G --CPU 8 --maxjob $proc $dShell/03.bwa-mapping.sh";
#`$job`;
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
	fq thanslate to fa format
	eg:
	perl $Script -ref -fqlist -out -dsh

Usage:
  Options:
  -ref	<file>	input genome fa file
  -fqlist	<file>	input fqlist file
  -out	<dir>	output dir
  -dsh	<dir>	output work_sh dir
  -proc	<num>	number of process for qsub,default 20
  -h         Help

USAGE
        print $usage;
        exit;
}
