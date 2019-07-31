#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$bwt);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"bwt:s"=>\$bwt,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin;
my $fln=basename($fin);
my %nam;
my $na;
while (<In>) {
	chomp;
	if (/>/) {
		$na=$_;
		$na=~s/>//g;
	}else{next;}
	$nam{$na}=1;
}
close In;
open IN,$bwt;
open OutA,">$fout/$fln.A.txt";
open OutB,">$fout/$fln.B.txt";
while (<IN>) {
	chomp;
	my ($id,$strand,$geno,$start,$seq,undef)=split/\s+/,$_,6;
	if ((exists $nam{$id}) && ($geno eq "DQ906921.1")) {
		my $end=$start+length($seq);
		print OutA "$id\t$strand\t$geno\t$start\t$end\n";
	}elsif ((exists $nam{$id}) && ($geno eq "DQ906922.1")) {
		my $end=$start+length($seq);
		print OutB "$id\t$strand\t$geno\t$start\t$end\n";
	}
}
close IN;
close OutA;
close OutB;
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
	-out ouput dir name 
	-bwt the result of bowtie
	-h         Help

USAGE
        print $usage;
        exit;
}
