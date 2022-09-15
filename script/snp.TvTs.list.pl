#!/usr/bin/env perl
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fIn,$fOut,$list);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"list:s"=>\$list,
	"stat:s"=>\$fOut,
			) or &USAGE;
&USAGE unless ($list and $fOut);
$fOut=ABSOLUTE_DIR($fOut);
my %TsTv=(
	"AG"=>"Ts",
	"TC"=>"Ts",
	"CT"=>"Ts",
	"GA"=>"Ts",
	"AT"=>"Tv",
	"AC"=>"Tv",
	"GT"=>"Tv",
	"CG"=>"Tv",
	"CA"=>"Tv",
	"GC"=>"Tv",
	"TA"=>"Tv",
	"TG"=>"Tv",
);
open IN,$list;
while(<IN>){
	chomp;
	$fIn=$_;
	my @all=split/\//,$_;
	my ($sam,undef,undef)=split/\./,$all[-1];
	#print $sam;die;
	open In,$fIn;
	if ($fIn=~/.gz$/) {
		close In;
		open In,"gunzip -c $fIn|";
	}
	my %diff;
	while(<In>){
		chomp;
		next if ($_ eq "" || /^$/ || /^##/);
		my($chr,$pos,$id,$ref,$alt,$qual,$Filter,$indo,$format,@geno)=split(/\t/,$_);
		#next if ($Filter ne "PASS" && $Filter ne "SNP" && $Filter ne "INDEL" && $Filter ne "FILTER" && $Filter ne ".");
		next if (length($ref) >1 || length($alt) > 1);
		my $all=join("",$ref,$alt);
		#print $all;die;
		if (exists $TsTv{$all}){
			$diff{$all}{$TsTv{$all}}++;
		}
	}
	close In;
	open Out,">$fOut/$sam.snp.stat";
	print Out "geneotype\tTransition(Ts)\&Transversion(Tv)\tNumber of SNP\n";
	#print Out "#sampleID\tSNPnumber\tTransition\tTransvertion \n";#\tTs/Tv\tHeterozygosity Number\tHomozygosity Number\tAverage Depth\tMiss Number\tRef Number\n";
	foreach my $type (sort keys %diff) {
		foreach my $TT (sort keys %{$diff{$type}}){
			print Out join("\t",$type,$TT,$diff{$type}{$TT}),"\n";
		}
	}
	close Out;
}

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
	eg:
	perl $Script -list vcf.list -stat ./

Usage:
  Options:
  -list	<file>	input list file name included
  -out	<file>	output file name
  -h         Help

USAGE
        print $usage;
        exit;
}
