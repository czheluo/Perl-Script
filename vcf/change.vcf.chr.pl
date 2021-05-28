#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$as,$list,$flat);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"list:s"=>\$list,
	"id:s"=>\$flat,
	"vcf:s"=>\$fin,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fin);
open IN,$flat;
my %chs;
my (@sam1,@sam2);
while (<IN>) {
	chomp;
	my($id1,$id2)=split/\s+/,$_;
	$id1=~s/R//g;
	$chs{$id2}=$id1;
	push @sam1,join("\t",$id2);
	push @sam2,join("\t",$id1);
}
close IN;

open LT,$list;
my %ch;
while (<LT>) {
	chomp;
	my($chr1,$chr2)=split/\s+/,$_;
	$ch{$chr2}=$chr1;
}
close LT;

open In,$fin;
open Out,">$fout";
while (<In>) {
	chomp;
	if (/^##/) {
		print Out "$_\n";
	}elsif(/^#/){
		my($chr,$pos,$id,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,$SAMPLE)=split/\s+/,$_,10;
		print Out "$chr\t$pos\t$id\t$REF\t$ALT\t$QUAL\t$FILTER\t$INFO\t$FORMAT\t",join("\t",@sam2),"\n";
	}else{
		my($chr,$pos,$id,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,$SAMPLE)=split/\s+/,$_,10;
		print Out "$ch{$chr}\t$pos\t$ch{$chr}:$pos\t$REF\t$ALT\t$QUAL\t$FILTER\t$INFO\t$FORMAT\t$SAMPLE\n";
	}
}
close Out;
close In;
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

	eg:perl $Script -list chr.list -id kf.list -vcf kf.all.vcf -out kf.vcf
	

Usage:
  Options:
	"list:s"=>\$list,
	"id:s"=>\$flat,
	"vcf:s"=>\$fin,
	"out:s"=>\$fout,
USAGE
        print $usage;
        exit;
}
