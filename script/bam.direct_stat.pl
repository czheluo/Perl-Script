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
	"i:s"=>\$fin,
	"o:s"=>\$fout,
	"m:s"=>\$min,
			) or &USAGE;
&USAGE unless ($fout);
open IN,"samtools view $fin |";
open OUT,">$fout";
while (<IN>) {
	chomp;
	my ($reads,$flag,undef)=split/\s+/;
	my $bflag = sprintf("%b",$flag);
	my @bflag = split//,$bflag;
	if (scalar @bflag >= 5 && $bflag[-5] eq "1") {
		print OUT "$reads\treverse\n"
	}else{
		print OUT "$reads\tforward\n"
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
