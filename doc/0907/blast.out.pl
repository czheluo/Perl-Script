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
	"i:s"=>\$fin,
	"o:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open IN,$fin;
open OUT,">$fout";
print OUT "Chr\tpos1\tpos2\tchr\tpos3\tpos4\tevalue\tbit score\n";
$/="# BLASTN 2.7.1+";
while (<IN>) {
	chomp;
	next if ($_ eq "" || /^$/ || /# 0 hits found/);
	my (undef,undef,undef,undef,undef,$blast)=split(/\n/,$_,6);
#	print $blast;
#	print $_;
	my @blast = split/\n/,$blast;
	my (undef,undef,undef,undef,undef,undef,undef,undef,undef,undef,$mevalue,$mbitscore)=split/\s+/,$blast[0];
	my $maxbitscore = $mbitscore;
	for (my $i=0;$i<@blast;$i++) {
		my ($tag,$chr,undef,undef,undef,undef,$qstrt,$qend,$sstart,$send,$evalue,$bitscore)=split/\s+/,$blast[$i];
		if ($bitscore eq $maxbitscore) {
			print OUT "$tag\t$qstrt\t$qend\t$chr\t$sstart\t$send\t$evalue\t$bitscore\n";
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
	fq thanslate to fa format
	eg:
	perl $Script -i -o -k -c

Usage:
  Options:
	"i:s"=>\$fin, blast result
	"o:s"=>\$fout, output file
  -h         Help

USAGE
        print $usage;
        exit;
}
