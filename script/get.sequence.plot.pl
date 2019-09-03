#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout);
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
open In,$fin;
open Out,">$fout";
my $ty=" ";
my $n1=1;
my $n=2;
my $n2=3;
while (<In>) {
	chomp;
	my($chr,$pos,$d1,$d2,$type,$dp)=split/\s+/,$_;
	#my $d=$d1-$d2;
	my $d=0;
	if ($d >0) {
		my $dd=$d2/2;
		my $pos1=$pos-$dd;
		my $pos2=$pos+$dd;
		print Out "$chr\t$pos1\t$type\t0\n";
		print Out "$chr\t$pos\t$type\t$dp\n";
		print Out "$chr\t$pos2\t$type\t0\n";
	}elsif ($d < 0) {
		my $dd=$d1/2;
		my $pos1=$pos-$dd;
		my $pos2=$pos+$dd;
		print Out "$chr\t$pos1\t$type\t0\n";
		print Out "$chr\t$pos\t$type\t$dp\n";
		print Out "$chr\t$pos2\t$type\t0\n";		
	}else{
		print Out "$chr\t$n1\t$ty\t0\n";
		print Out "$chr\t$n\t$type\t$dp\n";
		print Out "$chr\t$n2\t$ty\t0\n";	
		$n1=$n2+1;
		$n=$n1+1;
		$n2=$n+1;
	}
}
close In;
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
