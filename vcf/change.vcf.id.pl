#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$list);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out:s"=>\$fout,
	"list:s"=>\$list,
			) or &USAGE;
&USAGE unless ($fout);
open IN,$list;
my %ch;
my (@sam1,@sam2);
while (<IN>) {
	chomp;
	my($id1,$id2)=split/\s+/,$_;
	$ch{$id2}=$id1;
	push @sam1,join("\t",$id2);
	push @sam2,join("\t",$id1);
}
close IN;
open In,$fin;
if ($fin=~/.gz$/) {
	close IN;
	open IN,"gunzip -c $fin|";
}
open Out,">$fout";
my %sams;
while (<In>) {
	chomp;
	if (/^##/) {
		print Out "$_\n";
	}elsif(/^#/){
		my($chr,$pos,$id,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,$SAMPLE)=split/\s+/,$_,10;
		my @sam=split/\s+/,$SAMPLE;
		for (my $i=0;$i<scalar @sam ;$i++) {
			$sams{$sam[$i]}=$i;
		}
		print Out "$chr\t$pos\t$id\t$REF\t$ALT\t$QUAL\t$FILTER\t$INFO\t$FORMAT\t",join("\t",@sam2),"\n";
	}else{
		my($chr,$pos,$id,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,$SAMPLE)=split/\s+/,$_,10;
		my @sam=split/\s+/,$SAMPLE;
		my @sams;
		for (my $i=0;$i<scalar @sam ;$i++) {
			push @sams,join("\t",$sam[$sams{$sam1[$i]}]);
		}
        print Out "$chr\t$pos\t$chr:$pos\t$REF\t$ALT\t$QUAL\t$FILTER\t$INFO\t$FORMAT\t",join("\t",@sams),"\n";
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

	eg: perl change.vcfID.pl -int yl.recode.vcf -out yl.vcf -list comp.list
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
