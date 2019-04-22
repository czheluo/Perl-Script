#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($infile,$outfile,$n);
use Data::Dumper;
use List::Util 'sum';
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"infile:s"=>\$infile,
	"outfile:s"=>\$outfile,
	"le:s"=>\$n,
			) or &USAGE;
&USAGE unless ($infile);
open IN,$infile;
open OUT,">$outfile";
my %chr;
while (<IN>) {
	chomp;
	next if (/^#/ || /^sca/);
	my ($ch,undef,$type,undef)=split(/\s+/,$_,4);
	$chr{$ch}{$type}++;
}
print OUT "Chromosome ID,SNP Number,InDel Number\n";
#print Dumper \%chr;
my $valuea;
my $valueb;
foreach my $chr (sort keys %chr) {
	 $valuea += $chr{$chr}{SNP};
	 $valueb += $chr{$chr}{INDEL};
	 print OUT "$chr,$chr{$chr}{SNP},$chr{$chr}{INDEL}\n";
 }

print OUT "total,$valuea,$valueb\n";

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
	fq thanslate to fa format
	eg:
	perl $Script -i -o -k -c

Usage:
  Options:
	"help|?" =>\&USAGE,
	"infile:s"=>\$infile,
	"outfile:s"=>\$outfile,

  -h         Help

USAGE
        print $usage;
        exit;
}


