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
&USAGE unless ($fin);
my @file=glob("$fin/*.vcf");
my $head;
my @id;
my %chr;

foreach my $file (@file) {
	open In,$file;
	my ($id,undef)=split/\./,basename($file);
	push @id,$id;
	while (<In>) {
		chomp;
		next if(/^##/ || /^#/);
		my ($chr,$pos,$ids,$ref,$alt,$qual,$filter,$info,$format,$geno)=split(/\t/,$_);
		#$chr{join("\t",$chr,$pos)}{ref}{$id}=$ref;
		#$chr{join("\t",$chr,$pos)}{alt}{$id}=$alt;
		$chr{$chr}{$pos}{$id}{ref}=$ref;
		$chr{$chr}{$pos}{$id}{alt}=$alt;
		#$chr{$chr}{$pos}{$id}{qual}=$qual;
		#$chr{$chr}{$pos}{$id}{filter}=$filter;
		$chr{$chr}{$pos}{$id}{info}=$info;
		#$chr{$chr}{$pos}{$id}{format}=$format;
		$chr{$chr}{$pos}{$id}{geno}=$geno;
		#$ID{$chr}{$pos}{out}=$;
	}
	close In;
}
my $N;
open Out,">$fout";
print Out "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tg1\tS1_Abn\tS1_Nor\tS3_Abn\tS3_Nor\n";
foreach my $chr (sort keys %chr) {
		foreach my $pos (sort keys %{$chr{$chr}}) {
			$N++;
			my $keys=scalar %{$chr{$chr}{$pos}};
			my @geno;
			my @info;
			my @alt;
			my %hash;
			for (my $i=1;$i<=6 ;$i++) {
			if ($keys == $i) {
				foreach my $ID (@id) {
					if (exists $chr{$chr}{$pos}{$ID} ) {
						push @geno,$chr{$chr}{$pos}{$ID}{geno};
						push @info,$chr{$chr}{$pos}{$ID}{info};
						push @alt,$chr{$chr}{$pos}{$ID}{alt};
					}else{
						push @geno,"./.";
						push @info,"--";
						#push @alt,"-";
					}
				}
			}
			}
			@alt = grep { ++$hash{$_} < 2 } @alt;
			my $id_alt;
			foreach my $idal (@alt) {
				$idal=~s/<//g;
				$idal=~s/>//g;
				$idal=lc($idal);
				$id_alt="CNVnator_".$idal."_".$N;
			}
			print Out join("\t",$chr,$pos,$id_alt,"N","PASS",join("/",@alt),join("||",@info),@geno),"\n";
		}
}
close Out;

#print Dumper \%chr;


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

