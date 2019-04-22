#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$gro);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	#"i:s"=>\$fIn,
	#"i2:s"=>\$fIn,
	"i:s"=>\$fin,
	"o:s"=>\$fout,
	"g:s"=>\$gro,
			) or &USAGE;
&USAGE unless ($fout);
open IN,$gro;
my %gro1;
my %gro2;
while (<IN>) {
	chomp;
	next if ($_ eq "" || /^$/ || /^bulk/);
	my ($sam1,$sam2)=split/\s+/;
	$gro1{$sam1}=1;
	$gro2{$sam2}=1;
}
close IN;
#print Dumper \%gro2;die;
open IN,$fin;
my @indi;
open OUT,">$fout";
while (<IN>) {
	chomp;
	next if ($_ eq "" || /^$/ || /^##/);
	my ($chr,$pos,$id,$ref,$alt,$filter,$qual,$info,$format,$gene)=split/\s+/,$_,10;
	if (/^#/) {
		print OUT join("\t",$chr,$pos,$id,$ref,$alt,$filter,$qual,$info,$format,"bulk1","bulk2"),"\n";
		@indi = split/\s+/,$gene;
	}else{
		my @gene = split/\s+/,$gene;
		my @format = split/\:/,$format;
		my ($gtype1,$gtype2);
		my $m1 = 0;
		my $n1 = 0;
		my $m2 = 0;
		my $n2 = 0;
		for (my $i=0;$i<@indi ;$i++) {
			next if (!exists $gro1{$indi[$i]});
			my @info=split(/\:/,$gene[$i]);
			for (my $j=0;$j<@format ;$j++) {
				if ($format[$j] eq "GT") {
					my @ale=split(/\//,$info[$j]);
					foreach my $ale (@ale) {
						if ($ale eq "0") {
							$m1++;
						}elsif ($ale eq "1") {
							$n1++;
						}else{
							next;
						}
					}
				}
			}
		}
		my $dp1 = $m1 + $n1;
		#print "$m1\t$n1\n";die;
		if ($m1 != 0 && $n1 != 0) {
			$gtype1 = join (":",join("/","0/1"),join(",",$m1,$n1),$dp1);
		}elsif ($m1 != 0 && $n1 == 0) {
			$gtype1 = join (":",join("/","0/0"),join(",",$m1,$n1),$dp1);
		}elsif ($m1 == 0 && $n1 != 0) {
			$gtype1 = join (":",join("/","1/1"),join(",",$m1,$n1),$dp1);
		}else{
			$gtype1 = join (":",join("/","./."),join(",",$m1,$n1),$dp1);
		}
		for (my $i=0;$i<@indi ;$i++) {
			next if (!exists $gro2{$indi[$i]});
			my @info=split(/\:/,$gene[$i]);
			for (my $j=0;$j<@format ;$j++) {
				if ($format[$j] eq "GT") {
					my @ale=split(/\//,$info[$j]);
					foreach my $ale (@ale) {
						if ($ale eq "0") {
							$m2++;
						}elsif ($ale eq "1") {
							$n2++;
						}else{
							next;
						}
					}
				}
			}
		}
		my $dp2 = $m2 + $n2;
		#print "$m1\t$n1\t$m2\t$n2\n";
		if ($m2 != 0 && $n2 != 0) {

			$gtype2 = join (":",join("/","0/1"),join(",",$m2,$n2),$dp2);
		}elsif ($m2 != 0 && $n2 == 0) {
			$gtype2 = join (":",join("/","0/0"),join(",",$m2,$n2),$dp2);
		}elsif ($m2 == 0 && $n2 != 0) {
			$gtype2 = join (":",join("/","1/1"),join(",",$m2,$n2),$dp2);
		}else{
			$gtype2 = join (":",join("/","./."),join(",",$m2,$n2),$dp2);
		}
		print OUT join("\t",$chr,$pos,$id,$ref,$alt,$filter,$qual,$info,"GT:AD:DP",$gtype1,$gtype2),"\n";
	}
}
close IN;
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
	"i:s"=>\$fin,   pop.final.vcf
	"o:s"=>\$fout,  out file
	"g:s"=>\$gro,   group.list
  -h         Help

USAGE
        print $usage;
        exit;
}
