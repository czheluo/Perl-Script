#!/usr/bin/perl
use strict;
use warnings;

#define the de_kegg execute bin
my $de_kegg = "/mnt/ilustre/centos7users/meng.luo/Pipeline/RNA/Pipeline/11.scRNA/songweiwen_MJ20200701041/07.DEG.enrich/script/KEGG_add_exp2.pl";

my ($help, $type, $use_proxy, $org);
GetOptions(
	"type:s" => \$type,
	"help!"  => \$help,
	"use_proxy!" =>\$use_proxy,
	"org:s" =>\$org,
);

$type ||= "edgeR";
	
if ( $help ){
	my $help_inf = `$de_kegg 2>&1`;
	die "$help_inf";
}

die(qq/
Usage:   RNAseq_StatBox de_kegg <kegg file> <diff_exp_result>

		
         kegg file:            *\/annotation\/KEGG\/pathway.txt
         diff_exp_result:      *\/RSEM\/diffexpstat-edgeR-FDR:0.05-logFC:1\/Expression_Analysis\/*\/*diff*result, if euk choose "gene" or choose "isoform".
         
         This need run local!!!

Options: 
         -type          "edgeR"(default) or "cufflink".
		 -org           ko or species
		 -use_proxy             use proxy or not
		 
         -help          see the detail help information about diff-expression kegg.

\n/) if (@ARGV != 2);
	my $file_std = $ARGV[1];

	if($type eq "cufflink"){
		open(IN, $ARGV[1]);
		open(OUT, "> $ARGV[1].std");
		my $head = <IN>;
		chomp($head);
		my @cols = split(/\t/,$head);
		print OUT join("\t", @cols[0..4]);
		print OUT "\t".$cols[7]."\tp-value\tFDR\tsignificant\tregulate\n";			
		close OUT;
		
		my $std_format = "sed '1d' $ARGV[1] |awk '{print \$1\"\\t\"\$2\"\\t\"\$3\"\\t\"\$4\"\\t\"\$5\"\\t\"\$8\"\\t\"\$6\"\\t\"\$7\"\\t\"\$12\"\\t\"\$10}' >> $ARGV[1].std";
		# print $std_format;
		system($std_format);
		
		close IN;
		$file_std = "$ARGV[1].std";
	}

	# my $cmd = "$de_kegg -i $ARGV[0] -exp $file_std -exptype $type -o $ARGV[1].path";
	my $cmd = "$de_kegg -i $ARGV[0] -exp $file_std -o $ARGV[1].path";
	if($use_proxy){
		$cmd .= " -use_proxy";
	}
	if($org){
		$cmd .= " -org $org";
	}

system $cmd;



