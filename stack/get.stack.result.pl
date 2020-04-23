#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$name,$nt,$fa,$table);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"fa:s"=>\$fa,
	"out:s"=>\$fout,
	"nt:s"=>\$nt,
	"table:s"=>\$table,
	"name:s"=>\$name,
			) or &USAGE;
&USAGE unless ($fout);

open In,$fin;
my %un;
while (<In>) {
	chomp;
	next if ($_ =~ "#");
	my (undef,undef,$id,undef)=split/\s+/,$_,4;
	my ($sca,$pos)=split/\_/,$id;
	$un{$sca}=$pos;
}
close In;
open IN,$fa;
open Out,">$fout/$name.fa";
my %seq;
$/ = ">";
while(<IN>){
	chomp;
	next if ($_ eq "" || /^$/);
	my ($chr,$seq) = split(/\n/,$_,2);
	$seq =~ s/\n//g;
	if (exists $un{$chr}) {
		print Out ">$chr\n$seq\n";
	}
	$seq{$chr} = $seq;
}
#print Dumper %seq;die;
close IN;
close Out;
open NT,">$fout/$name.nt.xls";
$/ = "\n";
open TA,$table;
while (<TA>) {
	chomp;
	if ($_ =~ "#") {
		print NT "$_\n";
	}else{
		my ($id,undef)=split/\s+/,$_,2;
		if (exists $un{$id}) {
			print NT "$_\n";
		}
	}
}
close TA;
close NT;
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

	eg: perl $Script -int North_latitude.vcf -table population.nt.blast.result.xls -fa population.fa -out ./ -name North_latitude
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
