#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$vcf);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"loc:s"=>\$fin,
	"vcf:s"=>\$vcf,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin;
my %id;
while (<In>) {
	chomp;
	next if ($_ =~ /=/);
	#print $_;die;
	my ($gid,undef)=split/\s+/,$_,2;
	#print $gid;die;
	$id{$gid}=1;
}
close In;
open IN,$vcf;
open Out,">$fout";
while (<IN>) {
	chomp;
	if ($_ =~ "#" || $_ =~ "##" ) {
		print Out "$_\n";
	}else{
		my (undef,undef,$cid,undef)=split/\s+/,$_,4;
		#print $cid;die;
		if (exists $id{$cid}){
			print Out "$_\n";
		}
	}
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

	eg: perl -int filename -out filename 
	

Usage:
  Options:
	"loc:s"=>\$fin,
	"vcf:s"=>\$vcf,
	"out:s"=>\$fout,
	-h         Help

USAGE
        print $usage;
        exit;
}
