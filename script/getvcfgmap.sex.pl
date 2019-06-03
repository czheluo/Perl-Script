#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$vcf,$fmap);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"loc:s"=>\$fin,
	"map:s"=>\$fmap,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fmap;
my %fid;
while (<In>) {
	chomp;
	next if ($_ eq "" || $_ =~ "group");
	my ($fd,undef)=split/\s+/,$_,2;
	$fid{$fd}=1;
}
close In;
open In,$fin;
open Out,">$fout";
while (<In>) {
	chomp;
	next if ($_ =~ /=/);
	#print $_;die;
	my ($gid,undef)=split/\s+/,$_,2;
	#print $gid;die;
	if (exists $fid{$gid}) {
		print Out "$_\n";
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
	"loc:s"=>\$fin,
	"map:s"=>\$fmap,
	"out:s"=>\$fout,
	-h         Help

USAGE
        print $usage;
        exit;
}
