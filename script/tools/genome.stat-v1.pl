#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fIn,$dOut,$Key);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"i:s"=>\$fIn,
	"o:s"=>\$dOut,
	"k:s"=>\$Key,
	) or &USAGE;
&USAGE unless ($fIn and $dOut and $Key);
my $mkdir=1;
$mkdir=(mkdir $dOut) if (!-d $dOut);
die "Error make dir $dOut" if($mkdir == 0);
die "Error input Genome $fIn!\n" if (!-f $fIn ) ;
open In,$fIn;
if($fIn=~/gz$/){
	close In;
	open In,"gunzip -c $fIn| ";
}
my %sequence;
$/=">";
my %GStat;
my $Nscaff=0;
while (<In>) {
	chomp;
	next if ($_ eq "" || /^$/ || /^#/);
	my ($id,@line)=split(/\n/,$_);
	my $newname="";
	$id =(split(/\s+/,$id))[0];
	if ($id =~ /(chr\d+)/ ) {
		$GStat{Nchrom}++;
		#$newname=(split(/\>/,$id))[1];
	}else{
		$GStat{Nscaff}++;
		#$newname=(split(/\>/,$id))[1];
	}
	my $seq=join("",@line);
	$seq =~ s/(\w+)/\U$1/;
	$sequence{$id}=length$seq;
	$GStat{Nlen}+=length($seq);
	my $nseq=$seq;
	$GStat{GC}+=($nseq=~s/G|C//g);
}
close In;
my $lastname = "";
my $lastseq="";
my $glen=0;
$/="\n";
open Out,">$dOut/$Key.genome.stat";
my $sum=0;
foreach my $id (sort {length($sequence{$b})<=>length($sequence{$a})} keys %sequence) {
	$sum=$sequence{$id} + $sum;
	if ($sum/$GStat{Nlen} < 0.5) {
		$GStat{N50n}++;
		$GStat{N50}=$sequence{$id};
	}
	if ($sum/$GStat{Nlen} < 0.7) {
		$GStat{N70n}++;
		$GStat{N70}=$sequence{$id};
	}
	if ($sum/$GStat{Nlen} < 0.9) {
		$GStat{N90n}++;
		$GStat{N90}=$sequence{$id};
	}
}
$GStat{Nscaff}||=0;
$GStat{Nchrom}||=0;
$GStat{Nlen}||=0;
$GStat{Glen}||=0;
$GStat{Gnum}||=0;
$GStat{GC}||=0;
$GStat{N50}||=0;
$GStat{N50n}||=0;
$GStat{N70}||=0;
$GStat{N70n}||=0;
$GStat{N90}||=0;
$GStat{N90n}||=0;
print Out "#Genome\tNChromosome\tNScaffold\tTotalLenth\tGeneLenth\tGeneNum\tGC(%)\tN50\tN50num\tN70\tN70num\tN90\tN90num\n";
print Out join("\t",$Key,$GStat{Nchrom},$GStat{Nscaff},$GStat{Nlen},$GStat{Glen},$GStat{Gnum},int($GStat{GC}/$GStat{Nlen}*10000)/100,$GStat{N50},$GStat{N50n},$GStat{N70},$GStat{N70n},$GStat{N90},$GStat{N90n}),"\n";
close Out;
#` /mnt/ilustre/users/meng.luo/Software/ncbi-blast-2.5.0+-src/c++/ReleaseMT/bin/makeblastdb  -dbtype nucl -in $dOut/$Key.gene.fa  -input_type fasta`;
#`bwa index $dOut/$Key.gene.fa`;
print STDERR "test!";
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:
	reformat genome,rename scaffold name at genome fa file and gff file
eg:
	perl $Script -i Genome.fa -k keyname -o dir 

Usage:
  Options:
  -i	<file>	input genome name,fasta format,
  -o	<dir>	output dir,
  -k	<str>	output keys of filename,


  -h         Help

USAGE
        print $usage;
        exit;
}
