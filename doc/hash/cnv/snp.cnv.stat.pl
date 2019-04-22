#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fin1,$fout,$min);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"int1:s"=>\$fin1,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fin);

open IN,$fin;
my @start;
my @end;
my @id;
my @chr;
my %region;
#open Out,">$fout";
while (<IN>) {
	chomp;
	next if (/^Transposon_Name/);
	my ($id1,$ft,$start1,$end1,undef)=split/\s+/,$_;
	#print Dumper $id1;
	my ($id2,undef)=split/[E]/,$id1;
	#print Dumper @id2;die;
	$id2=~ s/AT/chr/g;
	$id2=~s/T//g;
	#print Dumper $id2;die;
	push @id,join("\t",$id1),"\n";
	push @chr,join("\t",$id2),"\n";
	push @start,join("\t",$start1),"\n";
	push @end,join("\t",$end1),"\n";
	#print Dumper $start;
	#print Dumper $end;die;
	my $chr=$id2;
	$region{$chr}{join("\t",$start1,$end1)}=$id1;
}

close IN;
#do not use the array to complicate things

#print Out "@id\@chr";#\n@chr\t@start\t@end\n";
open IN,$fin1,
my @chrn;
my @startn;
my @endn;
#my @id;
my %stat;
while (<IN>) {
	chomp;
	next if ($_ eq "" || /^##/ || /^#/);
	my ($chr,$intev,undef)=split/\s+/,$_;
	my ($ch,$se)=split/\:/,$intev;
	my ($Pos1,$Pos2)=split/\-/,$se;
	#push @chrn,join("\t",$ch),"\n";
	#push @startn,join("\t",$s),"\n";
	#push @endn,join("\t",$e),"\n"; 
	#my $ncnv=0;
	foreach my $region (sort keys %{$region{$ch}}) {
		my ($pos3,$pos4)=split(/\t/,$region);
		if (($Pos1 > $pos3 && $Pos1 <$pos4) ||($Pos2 > $pos3 && $Pos2 < $pos4) || ($pos3 > $Pos1 && $pos3 < $Pos2) || ($pos4 > $Pos1 && $pos4 < $Pos2)) {
				$stat{$ch}{$region}{cnv}++;
		}
		} 
}
close IN;
##from th first great to the more ....
open Out,">$fout";

foreach my $chr (sort keys %region) {
	foreach my $region (sort keys %{$region{$chr}}) {
		$stat{$chr}{$region}{cnv}||=0;
		print Out join("\t",$region{$chr}{$region},$chr,$region,$stat{$chr}{$region}{cnv}),"\n";
	}
}
close Out;



#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:

	eg: perl -int filename -out filename 
	

Usage:
  Options:
	-int input Transposon_Name file name
	-int1 input vcf or cnv result file name
	-out ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
