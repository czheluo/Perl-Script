#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$min);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out:s"=>\$fout,
	"m:s"=>\$min,
			) or &USAGE;
&USAGE unless ($fout);

open IN,$fin;
open OUT,">$fout";
while (<IN>) {
	chomp;
	next if (/^##/ || /^sca/);
	if (/^#/) {
		my ($CHROM,$POS,$ID,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,$AI,$GAO,$hun1,$hun2) =split(/\s+/,$_);
		print OUT "$CHROM\t$POS\t$ID\t$hun1\t$hun2\n";
	}else {
	#print Dumper $_;die;
	my ($CHROM,$POS,$ID,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,$AI,$GAO,$hun1,$hun2) =split(/\s+/,$_);
	#print Dumper $lv41;die;
	my ($na,undef)=split(/\:/,$hun1);
	my ($nb,undef)=split(/\:/,$hun2);
	#my ($na,undef)=split(/\:/,$AI);
	#my ($nb,undef)=split(/\:/,$GAO);
	next if($nb eq "./.");
	if ($nb eq "0/0" || $nb eq "1/1") {
		print OUT "$CHROM\t$POS\t$ID\t$na\t$nb\n";
	}
	}
}

close IN;
close OUT;


#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:
	eg:
	perl $Script -i -o -k -c

Usage:
  Options:
	-int input filename 
	-out output filename
     -h     Help

USAGE
        print $usage;
        exit;
}


