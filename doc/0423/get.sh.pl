#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$min);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
$fout=ABSOLUTE_DIR($fout);
my @out=glob("$fout/*.out");
my $gt="/mnt/ilustre/centos7users/meng.luo/project/RNA/lncRNA/liqiang_MJ20180711017/pipeline/target/trans/data/get.trans.pl";
open SH,">$fout/out.sh";
foreach my $ot (@out) {
		my $uot=basename($ot);
		print SH "perl $gt -ref $fout/$uot -lnc $fout/lnvall.list -mr $fout/mall.list -out $fout/$uot.mat \n";
}
close SH;
my @out1=glob("$fout/*.mat");
my $ch="/mnt/ilustre/centos7users/meng.luo/project/RNA/lncRNA/liqiang_MJ20180711017/pipeline/target/trans/data/choose_transtarget.pl";
open SH,">$fout/mat.sh";
foreach my $ot (@out1) {
		my $uot=basename($ot);
		print SH "perl $ch -int $fout/$uot -out $fout/$uot.txt \n";
}
close SH;
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
	-int input file name
	-out ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
