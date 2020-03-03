#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
my ($vcf,$out,$s1,$s2);        #1
GetOptions(
	"help|?" =>\&USAGE,
	"vcf:s"=>\$vcf,     #2
	"s1:s"=>\$s1,
	"s2:s"=>\$s2,
	"out:s"=>\$out,   #3
			) or &USAGE;
&USAGE unless ($vcf and $out and $s1 and $s2); #4
#######################################################################################
$vcf = ABSOLUTE_DIR($vcf);
open IN,$vcf;
if ($vcf=~/.gz$/){
	close IN;
	open IN,"gzip -dc $vcf|"
}
open OUT,">$out";
my ($mark1,$mark2);#two sample's order
while (<IN>){
	chomp;
	next if (/^\s*$/||/^##/);
	my ($chr,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@samples) = split /\t/;
	if (/^#/){
		for(my $i=0;$i<@samples;$i++){
			if ($samples[$i]=~/$s1/){
				$mark1 = $i;
			}
			if ($samples[$i]=~/$s2/){
				$mark2 = $i;
			}
		}
		print "get sample location!\n";
		print OUT join("\t",$chr,$pos,$ref,$alt,"$s1\_Genotype","$s1\_Depth","$s1\_AlleleDepth","$s2\_Genotype","$s2\_Depth","$s2\_AlleleDepth","Annotation"),"\n";
		next;
	}
	#handle info
	my @infos = split /;/,$info;
	my @anns;
	foreach my $info(@infos){
		if($info=~/ANN/){
			$info=~s/ANN=//g;
			my @lists = split /,/,$info;
			foreach my $list (@lists){
				my @eachs = split /\|/,$list;
				#if (!defined @eachs[0..4]){
				#	print "@eachs[0..4]\n";die;
				#}
				push @anns,join("|",@eachs[0..4]);
			}
		}
	}

	my @formats = split /:/,$format;
	my ($GT,$DP,$AD);
	for(my $i=0;$i<@formats;$i++){
		if ($formats[$i] eq 'GT'){
			$GT = $i;
		}
		if ($formats[$i] eq 'DP'){
			$DP = $i;
		}
		if ($formats[$i] eq 'AD'){
			$AD = $i;
		}	
	}
	my @s1_formats = split /:/,$samples[$mark1];
	my @s2_formats = split /:/,$samples[$mark2];
	my $GT1 = $s1_formats[0];
	my $GT2 = $s2_formats[0];
	next if ($chr ne 'chr4');
	next if ($pos < 4000000);
	next if ($pos > 5000000);
	if ($GT1 ne $GT2){
		print OUT join("\t",$chr,$pos,$ref,$alt,$GT1,$s1_formats[$DP],$s1_formats[$AD],$GT2,$s2_formats[$DP],$s2_formats[$AD],join(",",@anns)),"\n";
	}

}
close IN;
close OUT;
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
		warn "Warning! just for existed file and dir.\n$in";
		exit;
	}
	chdir $cur_dir;
	return $return;
}

sub USAGE {           #5
        my $usage=<<"USAGE";
Contact:	meng.luo\@majorbio.com
Version:	$version
Script:		$Script
Description:	get two samples' different GT site from vcf file

	perl twosamplediff.pl -vcf pop.final.vcf.gz -s1 K -s2 Y -out KvsY.xls

Usage:
  Options:
  -vcf	<file>	input vcf file 
  -s1	<str>	sample 1
  -s2	<str>	sample 2
  -out	<file>	output file 
  -h		Help

USAGE
        print $usage;
        exit;
}
