#/usr/bin/perl -w
use strict;
use warnings;

my $BEGIN_TIME=time();
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Cwd qw(abs_path);

my $version="1.0.0";
my ($in,$out);                 #1
GetOptions(
	"help|?" =>\&USAGE,
	"in:s"=>\$in,              #2
	"out:s"=>\$out,            
) or &USAGE;
&USAGE unless ($in and $out);  #3
#######################################################################################
sub USAGE {                    #4
        my $usage=<<"USAGE";

Contact:	tong.wang\@majorbio.com
Script:		$Script
Version:	v$version

Description:	split snp, indel
Usage:
  Options:
  -in		<file>	input file 
  -out		<dir>	output dir
  -h		Help

USAGE
		die "$usage";
}
#######################################################################################
$in = abs_path($in);
$out = abs_path($out);
my $file_out = basename($in,".xls");

open SNP,">$out/$file_out.snp.xls";
open INDEL,">$out/$file_out.indel.xls";
open IN,$in;
my $header = <IN>;
print INDEL "$header";
print SNP "$header";
while(<IN>){
	chomp;
	next if (/^\s*$/);
	my @bases;
	my $indel_flag = 0;
	my ($chr,undef,$ref,$alt) = split /\t/;
	
	push @bases,$ref;
	push @bases,split(/,/,$alt);
	
	foreach my $base (@bases){
		if(length($base)>1){
			$indel_flag++;
		}	
	}
	if ($indel_flag){
		print INDEL "$_\n";
	}else{
		print SNP "$_\n";
	}
}
close IN;
close SNP;
close INDEL;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
