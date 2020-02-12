#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout);
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
my $file = (split/\./,basename($fin))[0];
open IN,$fin;
$/="# BLASTN 2.7.1+";
my %hash;
my %region;
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
		my ($reads,$chr,undef,undef,undef,undef,$qstrt,$qend,$sstart,$send,$evalue,$bitscore)=split/\s+/,$blast[$i];
		if ($bitscore eq $maxbitscore) {
			#print OUT "$tag\t$qstrt\t$qend\t$chr\t$sstart\t$send\t$evalue\t$bitscore\n";
			my $len = $qend - $qstrt;
			next if ($len > 130);
			$hash{$chr}{$sstart}{$send}{$reads}=join("\t",$reads,$qstrt,$qend,$chr,$sstart,$send,$evalue,$bitscore);
			($sstart,$send)=sort($sstart,$send);
			$region{$chr}{$sstart}{$send}{$reads}=$send;
		}
	}
}
close IN;
$/="\n";
#print Dumper \%hash;die;
open OUT,">$fout/$file.blast.out";
open RE,">$fout/$file.region.tmp";
print OUT "#Reads\tpos1\tpos2\tchr\tpos3\tpos4\tevalue\tbit score\n";
foreach my  $chr(sort keys %hash ) {
	foreach my $pos (sort {$a<=>$b} keys %{$hash{$chr}}) {
		foreach my $end (sort {$a<=>$b} keys %{$hash{$chr}{$pos}}) {
			foreach my $read (sort keys %{$hash{$chr}{$pos}{$end}}) {
				print OUT "$hash{$chr}{$pos}{$end}{$read}\n";
			}
		}
	}
	foreach my $pos (sort {$a <=> $b} keys %{$region{$chr}}) {
		foreach my $end (sort {$a<=>$b} keys %{$region{$chr}{$pos}}) {
			foreach my $read (sort keys %{$region{$chr}{$pos}{$end}}) {
				print RE join("\t",$read,$chr,$pos,$region{$chr}{$pos}{$end}{$read}),"\n";
			}
		}
	}
}
close RE;
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
