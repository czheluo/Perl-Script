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
	next if ($_ eq /^$/ || /#/ || /\=/);
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
my %stats;
while (<IN>){
	chomp;
	next if ($_ eq ""|| /^$/ || /^#/);
	my ($chr,$pos,$id,$ref,$alt,$data)=split(/\s+/,$_,6);
	my $ids=join("-",$chr,$pos);
	my @alt = join(",",$ref,$alt);
	my %len;
	foreach my $ale (@alt) {
		$len{length($ale)}=1;
	}
	my $les=length($alt);
	if (exists $hash{$ids}){
		$gtype=$hash{$ids};
		if ($les > 1) {
			#print "$ids\t$hash{$ids}\tindel\t$alt\n";
			$stat{$chr}{indel}++;
			$stats{$gtype}{indel}++;
		}else{
			#print "$ids\t$hash{$ids}\tSNP\t$alt\n";
			$stat{$chr}{snp}++;
			$stats{$gtype}{snp}++;
		}
	}
}

close IN;
#print Dumper \%stat;die;
open OUT,">$fout/$fin.type.stat.xls";
print OUT "type\tsnp\tindel\n";
my $snp1=0;
my $indel1=0;
foreach my $type (sort keys %stats){
	#print $type;
	$stats{$type}{snp}||=0;
	$stats{$type}{indel}||=0;
	$snp1=$snp1+$stats{$type}{snp};
	$indel1=$indel1+$stats{$type}{indel};
	print OUT join("\t",$type,$stats{$type}{snp},$stats{$type}{indel}),"\n";	
}
print OUT "Total\t$snp1\t$indel1";
open OUT1,">$fout/$fin.LG.stat.xls";
print OUT1 "LG\tsnp\tindel\n";
my $snp2=0;
my $indel2=0;
foreach my $chrs (sort keys %stat){
	$stat{$chrs}{snp}||=0;
	$stat{$chrs}{indel}||=0;
	$snp2=$snp2+$stat{$chrs}{snp};
	$indel2=$indel2+$stat{$chrs}{indel};
	#$chrs=~s/chr/LG/g;
	print OUT1 join("\t",$chrs,$stat{$chrs}{snp},$stat{$chrs}{indel}),"\n";	
}
#print  Dumper \%stat;die;
print OUT1 "Total\t$snp2\t$indel2";
#foreach my $chr (sort keys %stat) {
#	foreach my $gtype(sort keys %{$stat{$chr}}) {
#		$stat{$chr}{$gtype}{snp}||=0;
#		$stat{$chr}{$gtype}{indel}||=0;
#		print OUT join("\t",$chr,$gtype,$stat{$chr}{$gtype}{snp},$stat{$chr}{$gtype}{indel}),"\n";
#	}
#}
close OUT1;
close OUT;		
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
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
