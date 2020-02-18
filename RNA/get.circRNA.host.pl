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
	"t:s"=>\$table,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin;
my %ids;
while (<In>) {
	chomp;
	next if (/^circRNA_ID/);
	my ($id1,$id2)=split/\s+/,$_;
	my ($id3,undef)=split/\|/,$id1;
	$ids{$id3}=$id2;
}
close In;

open IN,$table;
open Out,">$fout";
while (<IN>) {
	chomp;
	if (/#/) {
		print Out "$_\n";
	}else{
		my ($chr,undef,undef,$start,$end,undef,undef,undef,$all)=split/\s+/,$_,9;
		my $id4=join(":",$chr,$start);
		my ($tans,$gen)=split/\;/,$all;
		$gen=~s/gene_id//g;
		$gen=~s/"//g;
		$gen=~s/ //g;
		#print $gen;die;
		if (exists $ids{$id4}) {
			print Out "$gen\t$ids{$id4}\t$id4\|$end\n";
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
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
