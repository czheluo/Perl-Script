#!/mnt/bin/env perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($ref,$list,$out);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
		"help|?" =>\&USAGE,
		"ref:s"=>\$ref,
		"out:s"=>\$out,
		"list:s"=>\$list,
                        ) or &USAGE;
&USAGE unless ($ref and $list and $out);
my %stat;
my $num;
my ($chr,$pos1,$pos2);
	open REAGION,$list;
	while (<REAGION>){
		chomp;
		next if ($_ eq "" || /^$/);
		my($chr,$pos1,$pos2)=split(/\t/,$_);
		$num++;
		my $length=$pos2 - $pos1 + 1;
		#print $length,"\n";die;
		my $start=$pos1 - 1;
		$stat{$num}=join("\t",$chr,$pos1,$pos2,$start,$length);
	}
	close REAGION;
my %seq;
$/=">";
open Ref,$ref;
while(<Ref>){
	chomp;
	next if ($_ eq ""|| /^$/);
	my($id,@seq)=split(/\n/,$_);
	my$seq=join("",@seq);
	$seq{$id}=$seq;
	
}
close Ref;
open Out,">$out";
foreach my$num(sort{$a<=>$b}keys %stat){
	my($chr,$pos1,$pos2,$start,$length)=split/\t/,$stat{$num};
	print length($seq{$chr}),"\n";
	my $geneseq=substr($seq{$chr},$start,$length);
	print Out ">$chr:$pos1-$pos2\n$geneseq\n";
}
close Out;

#######################################################################################
#print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
########################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:                 $Script
Description:
        get gene's seq
        eg:
        perl $Script -ref -gff -vcf -out -gene -list

Usage:
  Options:
	-ref	<file>  input ref.fa
	-out	<file>	output file name
	-list	<str>	region file
	-h			Help

USAGE
        print $usage;
        exit;
}
	

