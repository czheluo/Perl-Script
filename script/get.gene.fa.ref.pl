#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$gen);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"gff:s"=>\$gen,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);

open IN,$fin;
my %seq;
$/ = ">";
while(<IN>){
	chomp;
	next if ($_ eq "" || /^$/);
	my ($chr,$seq) = split(/\n/,$_,2);
	$seq =~ s/\n//g;
	$seq{$chr} = $seq;
}
close IN;
$/ = "\n";
open In,$gen;
open Out,">$fout";
while (<In>) {
	chomp;
	#my ($gene,$trans)=split/\s+/,$_;
	my ($chr,undef,$type,$start,$end,undef,undef,undef,$details)=split/\s+/,$_;
	#print $details;die;
	if ($type  eq "gene"){
		my @all=split/\;/,$details;
		my (undef,$genename)=split/\=/,$all[0];
		#print $genename;die;
		my $pos = $start-1;
		if ($pos <= 0) {
			$pos =0;
		}else{
			$pos =$pos;	
		}
		my $part = substr($seq{$chr},$pos,($end-$start));
		print Out ">$genename\n$part\n";
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

	eg:  perl $Script -int ref.fa -out gene.fa -gff ref.gff 
	
Usage:
  Options:
	"int:s"=>\$fin,
	"gff:s"=>\$gen,
	"out:s"=>\$fout,

USAGE
        print $usage;
        exit;
}
