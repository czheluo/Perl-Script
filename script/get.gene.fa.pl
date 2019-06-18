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
&USAGE unless ($fin);
#$fout=ABSOLUTE_DIR($fout);
open In,$fin;
my %gene;
while(<In>){
	chomp;
	$gene{$_}=1;
}
close In;
open IN,$fa;
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
#print Dumper \%seq;die;
open In,$gff;
open FA,">$fout/gene.fa";
open Out,">$fout/gene.list";
while(<In>){
	chomp;
	next if (/#/);
	my ($chr,$dbs,$type,$start,$end,undef,undef,undef,$details)=split/\s+/,$_,9;
	#print $end;die;
	if ($type eq "gene"){
		my ($ged,$name)=split/\=/,$details;
		$name=~s/;//g;
		#print $name;die;
		my $len=$end-$start;
		if(exists $gene{$name}){
			print Out "$name\t$chr\t$start\t$end\t$len\n";
			my $pos = $start-1;
			if ($pos <= 0) {
				$pos =0;
			}else{
				$pos =$pos;	
			}
			my $part = substr($seq{$chr},$pos,($end-$start));
			print FA ">$chr:$start-$end\n$part\n";
		}else{
			next;
		}
	}else{
		next;
	}
}
close In;
close Out;
close FA;
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

	eg:perl $Script -gene new.x.csv -gtf ref.gff -out gene.anno  
	

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
