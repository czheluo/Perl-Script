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
	#"i:s"=>\$fIn,
	#"i2:s"=>\$fIn,
	"iA:s"=>\$finA,
	"iB:s"=>\$finB,
	"o:s"=>\$fout,
	"m:s"=>\$min,
			) or &USAGE;
&USAGE unless ($fout);
open IN,$finA;
my %sca;

while (<IN>) {
	chomp;
	my ($chr,$sca{$chr})=split/\s+/;
    
}
close IN;
open IN,$finB;
open OUT,">$fout";
#print OUT "$head\n";
my $n= 0;
foreach my $pval (sort {$b<=>$a} keys %pval) {
	$n++;
	print OUT "$pval{$pval}\n";
	last if ($n == 100);
}
close OUT;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub log10 {
	my $n = shift;
    return log($n)/log(10);
}

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
	"i:s"=>\$fin,                                                                                                                                                                        
    "o:s"=>\$fout,
	"m:s"=>\$min,
  -h         Help

USAGE
        print $usage;
        exit;
}
