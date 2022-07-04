#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$Fin);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	#"i:s"=>\$fIn,
	#"i2:s"=>\$fIn,
	"i:s"=>\$fin,
	"m:s"=>\$Fin,
	"o:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open IN,$fin;
my %hash;
while (<IN>){
	chomp;
	next if ($_ eq ""|| /^$/ || /#/ || /\=/);
	my ($marker,$gtype,$info)=split(/\t/,$_,3);
	$gtype=~s/>//g;
	$gtype=~s/<//g;
	$hash{$marker}=$gtype;
}
close IN;
#print Dumper \%hash;die;
open IN,$Fin;
my %stat;
my $gtype;
while (<IN>){
	chomp;
	next if ($_ eq ""|| /^$/ || /^#/);
	my ($chr,$pos,$id,$ref,$alt,$data)=split(/\s+/,$_,6);
	my @alt = join(",",$ref,$alt);
	my %len;
	foreach my $ale (@alt) {
		$len{length($ale)}=1;
	}
	if (exists $hash{$id}){
		$gtype=$hash{$id};
		if (scalar keys %len > 1) {
			$stat{$chr}{$gtype}{indel}++;
		}else{
			$stat{$chr}{$gtype}{snp}++;
		}
	}
}
close IN;
#print Dumper \%stat;die;
open OUT,">$fout";
print OUT "chr\ttype\tsnp\tindel\n";
foreach my $chr (sort keys %stat) {
	foreach my $gtype(sort keys %{$stat{$chr}}) {
		$stat{$chr}{$gtype}{snp}||=0;
		$stat{$chr}{$gtype}{indel}||=0;
		print OUT join("\t",$chr,$gtype,$stat{$chr}{$gtype}{snp},$stat{$chr}{$gtype}{indel}),"\n";
	}
}
close OUT;		
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        minghao.zhang\@majorbio.com;
Script:			$Script
Description:
	fq thanslate to fa format
	eg:
	perl $Script -i -o -k -c

Usage:
  Options:
  -i	<file>	input total.qtl
  -m	<file>  input pop.final.vcf
  -o	<file>	marker.stat.result
  -h         Help

USAGE
        print $usage;
        exit;
}
