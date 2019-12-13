#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$table,$result,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"table:s"=>\$table,
	"result:s"=>\$result,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin;
my %seq;
$/ = ">";
while(<In>){
	chomp;
	next if ($_ eq "" || /^$/);
	my ($chr,$seq) = split(/\n/,$_,2);
	$seq =~ s/\n//g;
	$seq{$chr} = $chr;
}
close In;
$/ = "\n";
open RE,$result;
my %seq1;
while (<RE>) {
	chomp;
	next if($_ =~ "#");
	my ($id,$all)=split/\s+/,$_,2;
	$seq1{$id} = $all;
}
close RE;
open IN,$table;
open Out,">$fout";
while (<IN>) {
	chomp;
	my ($old,$new,$mapping)=split/\s+/,$_,3;
	my @all=split/\s+/,$mapping;
	if (exists $seq1{$new}) {
		print Out "$old\t$new\t$all[0]\t$seq1{$new}\n";
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

	eg: perl $Script -int list.fa -result  all.nt.blast.best -table list.id -out list.result.xls 
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
