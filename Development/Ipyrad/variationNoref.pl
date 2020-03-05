#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
my ($fqlist,$method,$cutseq,$out,$step,$stop,$send);        #1
GetOptions(
	"help|?" =>\&USAGE,
	"fqlist:s"=>\$fqlist,     #2
	"method:s"=>\$method,
	"cutseq:s"=>\$cutseq,
	"outdir:s"=>\$out,   #3
	"send!"=>\$send,
	"step:s"=>\$step,
	"stop:s"=>\$stop,
			) or &USAGE;
&USAGE unless ($fqlist and $out and $cutseq); #4
#######################################################################################
$fqlist = ABSOLUTE_DIR($fqlist);
mkdir $out if (!-d $out);
$out = ABSOLUTE_DIR($out);
mkdir "$out/work_sh" if (!-d "$out/work_sh");
$step||=1;
$stop||=-1;
open LOG,">$out/work_sh/var.$BEGIN_TIME.log";
if ($step == 1) {
	print LOG "########################################\n";
	print LOG "fastq-qc\n"; 
	my $time = time();
	print LOG "########################################\n";
	my $job = "perl $Bin/bin/step01.fastqc.pl -fqlist $fqlist -outdir $out/01.fastqc -dsh $out/work_sh -proc 20";
	print LOG "$job\n";
	`$job`;
	print LOG "$job\tdone!\n";
	print LOG "########################################\n";
	print LOG "Done and elapsed time : ",time()-$time,"s\n";
	print LOG "########################################\n";
	$step++ if ($step ne $stop);
}
if ($step == 2) {
	print LOG "########################################\n";
	print LOG "standardization for fastq file\n"; 
	my $time = time();
	print LOG "########################################\n";
	my $job = "perl $Bin/bin/step02.uniform.pl -fqlist $fqlist -outdir $out/02.uniform -method $method -dsh $out/work_sh";
	print LOG "$job\n";
	`$job`;
	print LOG "$job\tdone!\n";
	print LOG "########################################\n";
	print LOG "Done and elapsed time : ",time()-$time,"s\n";
	print LOG "########################################\n";
	$step++ if ($step ne $stop);
}
if ($step == 3) {
	print LOG "########################################\n";
	print LOG "ipyrad for noref data\n"; 
	my $time = time();
	print LOG "########################################\n";
	my $fqlist=ABSOLUTE_DIR("$out/02.uniform/fq.list");
	my $job = "perl $Bin/bin/step03.ipyrad.pl -list $fqlist -outdir $out/03.ipyrad -method $method -cutseq $cutseq -dsh $out/work_sh";
	if ($send){
		$job .= " -send ";
	}else{
		$step = 10;
	}
	print LOG "$job\n";
	`$job`;
	print LOG "$job\tdone!\n";
	print LOG "########################################\n";
	print LOG "Done and elapsed time : ",time()-$time,"s\n";
	print LOG "########################################\n";
	$step++ if ($step ne $stop);
}
if ($step == 4) {
	print LOG "########################################\n";
	print LOG "calculate stat\n";
	my $time = time();
	print LOG "########################################\n";
	my $job = "perl $Bin/bin/step04.ipyradstat.pl -vcf $out/03.ipyrad/data_outfiles/data.vcf -outdir $out/04.stat -dsh $out/work_sh";
	print LOG "$job\n";
	`$job`;
	print LOG "$job\tdone!\n";
	print LOG "########################################\n";
	print LOG "Done and elapsed time : ",time()-$time,"s\n";
	print LOG "########################################\n";
	$step++ if ($step ne $stop);
}
if ($step == 5) {
	print LOG "########################################\n";
	print LOG "result\n";
	my $time = time();
	print LOG "########################################\n";
	my $job = "perl $Bin/bin/step05.report.pl -vcf $out/04.stat/final.vcf -statdir $out/04.stat/ -fastqc $out/01.fastqc -out $out/05.report -dsh $out/work_sh";
	print LOG "$job\n";
	`$job`;
	print LOG "$job\tdone!\n";
	print LOG "########################################\n";
	print LOG "Done and elapsed time : ",time()-$time,"s\n";
	print LOG "########################################\n";
	$step++ if ($step ne $stop);
}
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
		warn "Warning! just for file and dir.\n$in";
		exit;
	}
	chdir $cur_dir;
	return $return;
}

sub USAGE {           #5
        my $usage=<<"USAGE";
Contact:	meng.Luo\@majorbio.com
Version:	$version
Script:		$Script
Description:	ipyrad for noref data
Usage:
  perl $Script -fqlist  -cutseq  -outdir  -method 
  e.g
  perl $Script -fqlist fq.list  -cutseq TM  -outdir ./ -method GBS -send 
Options:
  -fqlist	<file>	input fqlist
  -cutseq	<str>   cut enzyme, eg. TM
  -outdir	<dir>	output dirname
  -method	<str>	GBS or RAD,
  -send		<bool>	if given, qsub ipyrad; if not, just create shell 
  -step		<num>	pipeline control, 1-3
  -stop		<num>	pipeline control, 1-3
  -h		Help

USAGE
        print $usage;
        exit;
}
