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
	next if (/^##/);
	if (/^#/) {
		my ($CHROM,$POS,$ID,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,$hun1,$AI,$GAO,$hun2) =split(/\s+/,$_);
		print OUT "CHROM\t$POS\t$ID\t$AI\t$GAO\t$hun1\t$hun2\n";
	}else {
	#print Dumper $_;die;
	my ($CHROM,$POS,$ID,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,$hun1,$AI,$GAO,$hun2) =split(/\s+/,$_);
	#print Dumper $lv41;die;
	my ($na,undef)=split(/\:/,$AI);
	my ($nb,undef)=split(/\:/,$GAO);
	my ($na1,undef)=split(/\:/,$hun1);
	my ($nb1,undef)=split(/\:/,$hun2);
	next if($na eq "./." || $nb eq "./." || $na1 eq "./." || $nb1 eq "./.");
	#next if($na eq "1/0" || $na eq "0/1");
	#next if($nb eq "1/0" || $nb eq "0/1");
	#next if($nb1 eq "1/0" || $nb1 eq "0/1");
	#next if($na1 eq "1/0" || $na1 eq "0/1");
	#next if(($na1 eq "0/0" && $nb1 eq "0/0") || ($na1 eq "1/1" && $nb1 eq "1/1"));

	if (($na eq "0/0" && $na1 eq "1/1" && $nb1 eq "0/0") || ( $na eq "0/0" && $na1 eq "0/0" && $nb1 eq "1/1") || ($na eq "1/1" && $na1 eq "1/1" && $nb1 eq "0/0") ||( $na eq "1/1" && $na1 eq "0/0" && $nb1 eq "1/1")) {
		
		print OUT "$CHROM\t$POS\t$ID\t$na\t$nb\t$na1\t$nb1\n";
	
	}

	#if (($na eq "0/0" && $nb eq "1/1" && $na1 eq "1/1" && $nb1 eq "0/0") || ($na eq "0/0" && $nb eq "1/1" && $na1 eq "1/1" && $nb1 eq "0/0") ){
		#print OUT "$CHROM\t$POS\t$ID\t$na\t$nb\t$na1\t$nb1\n";
	#}elsif(($na eq "1/1" && $nb eq "0/0" && $na1 eq "0/0" && $nb1 eq "1/1") || ($na eq "1/1" && $nb eq "0/0" && $na1 eq "0/0" && $nb1 eq "1/1")){
		#print OUT "$CHROM\t$POS\t$ID\t$na\t$nb\t$na1\t$nb1\n";
	#}

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

