#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$result);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out:s"=>\$fout,
	"result:s"=>\$result,
			) or &USAGE;
&USAGE unless ($fout);

open In,$fin;
my %ids;
while (<In>) {
	chomp;
	$ids{$_}=1;
}
close In;
open IN,$fout;
open Out,">$result";
my $add="--disable_gapped";
my $stacks="/mnt/ilustre/users/dna/.env/stacks-2.2/bin/sstacks";
while (<IN>) {
	chomp;
	my ($def1,$def2,$pid,$def3)=split/\s+/,$_,4;
	my @rid=split/\//,$pid;
	if (!exists $ids{$rid[-1]}) {
		print Out "$stacks\t$def2\t$pid\t$add\t$def3\n";
	}else{
		next;
	}
	#print $rid[-1];die;

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

	eg: 
perl rm.complete.sh.pl -int complete.list -out work_sh/step05.sstacks.sh -result step5.sh 
	

Usage:
  Options:
	-int input file name
	-out ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
