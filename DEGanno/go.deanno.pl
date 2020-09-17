#!/usr/bin/perl
use strict;
use warnings;

#define the de_kegg execute bin
my $de_go = "$script/go-multi-bars.pl";	

my ($help, $type);
my $reg=9;
my $sig=13;
	
GetOptions(
	"type:s" => \$type,
	"help!"  => \$help,
	"reg:i"  => \$reg,
	"sig:i"  => \$sig,
);
$type ||= "edgeR";

if ( $help ){
	my $help_inf = `$de_go 2>&1`;
	die "$help_inf";
}

die(qq/
Usage:   RNAseq_StatBox de_go <GO file> <diff_exp_result>
         GO file:            *\/annotation\/GO\/GO.list
         diff_exp_result:      *\/RSEM\/diffexpstat-edgeR-FDR:0.05-logFC:1\/Expression_Analysis\/*\/*diff*result, if euk choose "gene" or choose "isoform".

         This need run local!!!

Options: 
         -type          "edgeR"(default) or "cufflink".
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
		
	open(FILE, $file_std) or die $!;
	my $head = <FILE>;
	my @cols = split(/\t/,$head);
	close FILE;
	foreach(my $ie = 0; $ie <= $#cols; $ie ++){
		if ($cols[$ie] =~ /significant/){
			$sig = $ie + 1;
		}
		if ($cols[$ie] =~ /regulate/){
			$reg = $ie + 1;
		}			
	}

system "cat $file_std | awk '\$$reg==\"up\"&&\$$sig==\"yes\"'|cut -f 1 >$ARGV[1].up.list
cat $file_std |awk '\$$reg==\"down\"&&\$$sig==\"yes\"'|cut -f 1 >$ARGV[1].down.list
$de_go -i $ARGV[0] -u $ARGV[1].up.list -d $ARGV[1].down.list";
		


