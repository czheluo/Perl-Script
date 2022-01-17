#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$faout,$fa);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"fa:s"=>\$fa,
	"out:s"=>\$fout,
	"fo:s"=>\$faout
				) or &USAGE;
&USAGE unless ($fout);

open In,$fin;
open Out,">$fout";
while (<In>) {
	chomp;
	if($_ =~ "\@SQ" || $_ =~ "\@PG" ){
		print Out "$_\n";
	}else{
		my ($ids,$all)=split/\s+/,$_,2;
		my ($num,$id)=split/\|/,$ids;
		print Out "$id\t$all\n";
	}
		
}
close In;
close Out;
open FA,$fa;
open FO,">$faout";
#$/=">";
while (<FA>) {
	chomp;
	if ($_ =~ ">") {
		my($ch,$pos,$sample,$trans,undef)=split/\|/,$_,5;
		print "$ch\t$trans\n";
		print FO ">$trans\n";
	}else{
		print FO "$_\n";
	}
	#my ($chr,$seq) = split(/\n/,$_,2);
	#my ($id,undef)=split/\|/,$chr;
	#print FO ">$id\n$seq\n";
}
close FA;
close FO;
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

	eg: perl $Script -int PF_R1.sort.sam -out PF_R1.sam -fa PF_R1.collapsed.fas -fo PF_R1.fa > log

	
Usage:
  Options:
	-int input file name
	-out output file name 
	-fa fasta file name
	-fo fa outfile name
	-h         Help

USAGE
        print $usage;
        exit;
}
