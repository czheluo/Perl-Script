#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$TF);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"tf:s"=>\$TF,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin;
$/=">";
my %seqs;
while(<In>){
	chomp;
	next if ($_ eq "" || /^$/);
	my ($gene,$seq) = split(/\n/,$_,2);
	$seq =~ s/\n//g;
	$seqs{$gene} = $seq;
}
close In;
$/="\n";
open Out,">$fout";
open TF,$TF;
while (<TF>) {
	chomp;
	next if($_ =~ "Query-Name");
	my ($T,undef)=split/\s+/,$_,2;
	if (exists $seqs{$T}) {
		print Out ">$T\n$seqs{$T}\n";
	}
}
close TF;
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

	eg: perl $Script -int gene.fa -out TF.fa -tf unigene_vs_PlantTFDB-all_TF.1.xls.detail.xls
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
