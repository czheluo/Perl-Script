#! /usr/bin/perl -w
use strict;
use warnings;
use Math::Round qw(:all);

if( @ARGV<1 ){
	die ("perl $0 Trinity.fasta_vs_PlantTFDB-all_TF.xls.xls");
}

my $tffamily = "/mnt/ilustre/centos7users/meng.luo/Pipeline/RNA/Pipeline/08.TF/db/TF_family_new.fa.txt";
my $result = shift;


my %gene = ();
my %TF_family = ();

my %num;
open (FAMILY, "< $tffamily")|| die ("Could not open  file $tffamily !\n");
my $head = <FAMILY>;
while(<FAMILY>){
	chomp;
	my @line = split(/\t/,$_);
	if(! exists $gene{$line[2]}){
		$gene{$line[2]}{num} = 0;
		$gene{$line[2]}{gene} = "";
	}	
	$TF_family{$line[1]} = $line[2];
}
close FAMILY;

open (FILE, "< $result")|| die ("Could not open  file $result !\n");
my $head2 = <FILE>;
while(<FILE>){
	chomp;
	my @line = split(/\t/, $_);
	my $hit = $line[1];
	if(!exists $TF_family{$hit}){
		next;
	}
	my $type = $TF_family{$hit};
	$gene{$type}{num} ++;
	$gene{$type}{gene} .= $line[0].";";
}
close FILE;

print "family\tnum\tgene\n";
foreach(sort { $gene{$b}{num} <=> $gene{$a}{num} } keys %gene){
        my $family = $_;
		print $family."\t".$gene{$family}{num}."\t".$gene{$family}{gene}."\n";
}
