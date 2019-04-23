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
open IN,$fin;
my $trans_id;
my $lnc_id;
my $energy;
my $flag=0;
open OUT,">$fout";
while (<IN>){
	chomp;
	if ($flag==0 && $_=~/Cs1g/){
		$trans_id = $_;
		$flag=1;
	}elsif($flag==1 && $_=~/MSTRG/){
		$lnc_id = $_;
		$flag=2;
	}elsif ($flag==2 && $_=~/\(\.&\.\)/){
		#my @f1 = split /\s+/;
		#print $f1[-1],"\n";
		#$f1[-1] =~ /\((.*)\)/;
		#$energy = $1;
		#print $energy,"\n";
		my (undef,undef,undef,undef,$ids,undef)=split/\s+/,$_,6;
		$ids =~ s/\(//g;
		$ids =~ s/\)//g;
		#print $ids;die;
		#print 
		if ($ids <= -30){
			print OUT "$trans_id\n$lnc_id\n$_\n";
			$flag=0;
		}else{
			$flag=0;
		}
	}
}
close IN;
close OUT;

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
