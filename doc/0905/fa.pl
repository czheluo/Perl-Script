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

open IN,$min;
#print "$fin";die;
my %seq;
my $chr;
while(<IN>){
	chomp;
	if (/>/) {
		$chr=$_;
		$chr=~s/>//g;
	}else {
		$seq{$chr}.=$_;
	}

}
close IN;

open INA,$fin;
open OUT,">$fout";
while (<INA>) {
	chomp;
	
	next if (/^group/ ||/^$/);
	#print "$_";die if (/^chr1_59142876/); 
	my @marker=split/\s+/,$_;
	#print "$_";die;
	my ($Chr,$pos)=split/\_/,$marker[0];
	my $start=$pos-500;
	my $end=$pos+500;
	my $POS=$start-1;

	if ($start<=0) {
		$start=0;
		$POS=0;
	}
	my $part=substr($seq{$Chr},$POS,$end-$start);
	print OUT ">$marker[0]:$start:$end\n$part\n";
}
close INA;
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
	perl /mnt/ilustre/users/meng.luo/project/perl/0905/fa.pl -i mappp.map -m ref.fa -o mapp.fa 

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
