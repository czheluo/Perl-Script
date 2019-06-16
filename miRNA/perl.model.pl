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
$fin=ABSOLUTE_DIR($fin);
my @xlss=glob("$fin/*.xls");
foreach my $xls (@xlss) {
	my $fln=basename($xls);
	my ($name,undef)=split/\./,$fln;
	#print $name;die;
	open In,"<$fin/$fln";
	open Out,">$fout/$name.txt";
	print Out "Chr\tReads\tStrand\n";
	while (<In>) {
		chomp;
		if (/^Lachesis/){
			my ($unname,undef,undef,$forword,$reverse)=split/\s+/,$_;
			print Out "$unname\t$forword\tForword\n";
			print Out "$unname\t-$reverse\tReverse\n";
		}else{
			next;
		}
	}
	close In;
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
