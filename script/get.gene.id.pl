#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$as,$gff,$fa);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"gene:s"=>\$fin,
	"gff:s"=>\$gff,
	"fa:s"=>\$fa,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($gff);
#$fout=ABSOLUTE_DIR($fout);
open In,$gff;
#open FA,">$fout/gene.fa";
#open Out,">$fout/gene.list";
my (%trans,%genes);
while(<In>){
	chomp;
	next if (/#/);
	my ($chr,$dbs,$type,$start,$end,undef,undef,undef,$details)=split/\s+/,$_,9;
	#print $end;die;
	if ($type eq "transcript"){
		my (undef,$tran,undef,$gene,undef)=split/\s+/,$details,5;
		$tran=~s/;//g;
		$tran=~s/"//g;
		$gene=~s/;//g;
		$gene=~s/"//g;
		#print $name;die;
		$trans{$tran}=$chr;
		$genes{$gene}=$chr;
	}
}
close In;
open In,$fin;
open Out,">$fout";
while(<In>){
	chomp;
	next if(/lncRNA/);
	if(exists $genes{$_}){
		print Out "$_\t$genes{$_}\n";
	}elsif(exists $trans{$_}){
		print Out "$_\t$trans{$_}\n";
	}else{
		print Out "$_\tNA\n";
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

	eg:perl $Script -gff gffcomp.annotated.gtf -out lncRNA.anno -gene lnc.list

Usage:
  Options:
  	gene
	"gene:s"=>\$fin,
	"gff:s"=>\$gff,
	"fa:s"=>\$fa,
	"out:s"=>\$fout,
USAGE
        print $usage;
        exit;
}
