#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$list,$anno);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"list:s"=>\$list,
	"anno:s"=>\$anno,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
my @files=glob("$fin/*.list");
foreach my $file (@files) {
	my $fln=basename($file);
	my ($name,undef,undef)=split/\./,$fln;
	#print $fln;die;
	open In,"<$fin/$fln";
	my %lis;
	while (<In>) {
		chomp;
		#print $_;die;
		my $lit=lc($_);
		#print $lit;die;
		$lis{$lit}=1;
	}
	close In;
	open IN,$anno;
	open Out,">$fout/$name.anno.xls";
	print Out "MapMan Bin\tName\tDESCRIPTION\tgene id\n";
	while (<IN>) {
		chomp;
		next if (/^BINCODE/);
		my ($bin,$NAME,$ID,$Descrip,$type)=split/\t/,$_;
		$bin=~s/'//g;
		$NAME=~s/'//g;
		$ID=~s/'//g;
		#print $ID;die;
		$Descrip=~s/'//g;
		if (exists $lis{$ID}) {
			my $UID=uc($ID);
			print Out "$bin\t$NAME\t$Descrip\t$UID\n";
		}
	}
	#print $ID;die;
	close IN;
	close Out;
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

	eg: perl $Script -int list/ -out ./ -anno case11.results.txt
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
