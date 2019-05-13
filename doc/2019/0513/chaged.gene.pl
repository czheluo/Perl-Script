#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$as,$gtf);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"as:s"=>\$as,
	"gtf:s"=>\$gtf,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
$gtf=ABSOLUTE_DIR($gtf);
$as=ABSOLUTE_DIR($as);
$fout=ABSOLUTE_DIR($fout);
open In,$gtf;
my %genss;
open OUT,">$fout/gtf.refid";
while (<In>){
	chomp;
	next if (/#/);
	my(undef,undef,$type,undef,undef,undef,undef,undef,$genids)=split/\s+/,$_,9;
	next if ($type ne "transcript");
	my @gens=split/\;/,$genids;
	my $refid="NA";
	my $gensid="NA";
	my $relgen="NA";
	foreach my $gen (@gens){
		my ($geneid,undef)=split/\s+/,$gen;
		#print $geneid;die;
		if ($geneid eq "gene_id"){
			(undef,$gensid)=split/\s+/,$gen;
			$gensid=~s/"//g;
			#print $gensid,"\n";die;
		}elsif($gen=~ "ref_gene_id"){
			$relgen=$gen;
			#print $gen;die;
			(undef,undef,$refid)=split/\s+/,$gen;
			$refid=~s/"//g;
			#print $refid;die;
		}else{
			next;
		}
	}
	$genss{$gensid}=$refid;
	print OUT "$gensid\t$refid\n";
	#print $genids;die;
}
close In;
close OUT;
open As,$as;
open Out,">$fout/ref.xls";
while (<As>) {
	chomp;
	if (/event_id/){
		print Out "$_\treference_id\n";
	}
	my (undef,undef,$genid,undef)=split/\s+/,$_,4;
	if (exists $genss{$genid}){
		print Out "$_\t$genss{$genid}\n";
	}else{
		print Out "$_\tNA\n";
	}
}
close As;
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
	-out ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
