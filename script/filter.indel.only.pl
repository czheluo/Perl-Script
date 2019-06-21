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
	"vcf:s"=>\$fin,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin;
open Out,">$fout";
while (<In>) {
	chomp;
	if (/#/) {
		print Out "$_\n";
	}else{
		my ($chr,$pos,$id,$ref,$alt,undef,undef,undef,undef,$data)=split(/\s+/,$_,10);
		my @alt = split/\,/,$alt;
		#print $alt[0];die;
		if (length($alt[0]) ne length($ref) ) {
			my $ndep=0;
			my @sample=split/\s+/,$data;
			for (my $i=0;$i< @sample ;$i++) {
				my ($ad,undef,$dep,undef)=split(/\:/,$sample[$i],4);
				next if($ad eq "./.");
				#print $dep;die;
				if ($dep >=10) {
					$ndep++;
				}
			}
			if ($ndep>=50) {
				print Out "$_\n";
			}else{
				next;
			}
		}elsif(length($alt) ne length($ref)) {
			my $ndep=0;
			my @sample=split/\s+/,$data;
			for (my $i=0;$i< @sample ;$i++) {
				my ($ad,undef,$dep,undef)=split(/\:/,$sample[$i],4);
				next if($ad eq "./.");
				if ($dep >=10) {
					$ndep++;
				}
			}
			if ($ndep>=50) {
				print Out "$_\n";
			}else{
				next;
			}
		}else{
			print Out "$_\n";
		}
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

	eg: perl $Script -vcf filename -out filename 
	

Usage:
  Options:
	-vcf input file name
	-out ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
