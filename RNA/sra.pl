#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$table);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"table:s"=>\$table,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin;
open Out,">$fout";
while (<In>) {
	chomp;
	my($id1,$sra1)=split/\s+/,$_;
	open TA,$table;
	while (<TA>) {
		chomp;
		my($path,$id2,$sra2)=split/\s+/,$_;
		next if(($id2 eq $id1) && ($sra2 eq $sra1));
		if (($id2 eq $id1) && ($sra2 ne $sra1)) {
			print Out "mkdir -p /mnt/ilustre/centos7users/meng.luo/project/liushuqin/XJAWS/$id2/$sra1 && ";
			print Out "mv $path /mnt/ilustre/centos7users/meng.luo/project/liushuqin/XJAWS/$id2/$sra1/$sra1.sra\n";
			#print "$id2\t/mnt/ilustre/centos7users/meng.luo/project/liushuqin/XJAWS/$id2/$sra1/$sra1.sra\n";
			print "fastq-dump --split-3 /mnt/ilustre/centos7users/meng.luo/project/liushuqin/XJAWS/$id2/$sra1/$sra1.sra -O /mnt/ilustre/centos7users/meng.luo/project/liushuqin/XJAWS/$id2/$sra1  &&  ";
		}
		
	}
}
close Out;
close In;
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
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
