#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($genotype,$miss_stat,$identity_stat,$out,$gender_info,$remove_rsid,$uniq);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"v|genotype:s"=>\$genotype,
	"m|miss:s"=>\$miss_stat,
	"i|identity:s"=>\$identity_stat,
	"g|gender:s"=>\$gender_info,
	"r|remove:s"=>\$remove_rsid,
	"u|uniq:s"=>\$uniq,
	"o|out:s"=>\$out,
			) or &USAGE;
&USAGE unless ($genotype and $out and $remove_rsid and $gender_info and $identity_stat and $miss_stat);
my ($remove_sam,$patient_info) = DEL_SAM($gender_info,$miss_stat);
#print Dumper \$remove_sam;die;
my $identity_sam = IDENTITY($identity_stat);
#print Dumper \$identity_sam;die;
my ($remove_rs,$change_rs) = DEL_RSID($remove_rsid);
my (@num,@indi);
$uniq||="uniq";
open IN,$genotype;
open OUT1,">$out/filter.genotype.result";
open OUT2,">$out/filter.patient_info.list";
open OUT3,">$out/no_passing.patient_info.list";
while (<IN>) {
	chomp;
	next if ($_ eq "" || /^$/);
	my ($id,$ref,$alt,@geno) = split/\s+/;
	if (/^ID/) {
		for (my $i = 0;$i<scalar @geno;$i++) {
			if ($uniq eq "uniq"){
				if ( !exists $$remove_sam{$geno[$i]} && !exists $$identity_sam{$geno[$i]}) {
					push @num,$i;
					push @indi,$geno[$i];
				}
			}elsif (exists $$patient_info{$geno[$i]}) {
				push @num,$i;
				push @indi,$geno[$i];
			}	
		}
		foreach my $indi (@indi) {
			if (exists $$patient_info{$indi}) {
				print OUT2 "$$patient_info{$indi}\n";
			}else{
				print OUT3 "$indi\n";
			}
		}
		print OUT1 join("\t","#".$id,$ref,$alt,@indi),"\n";
	}else{
		if (!exists $$remove_rs{$id}) {
			if (exists $$change_rs{$id}) {
				($id,$ref,$alt) = split/\s+/,$$change_rs{$id};
			}
			my $miss_num = 0;
			for (my $i=0;$i<scalar @geno ;$i++) {
				if ($geno[$i] eq "./.") {
					$miss_num++;
				}
			}
			my $miss_ratio = $miss_num/scalar @geno;
			next if ($miss_ratio > 0.1);
			my @genotype;
			foreach my $num (@num) {
				push @genotype,$geno[$num];
			}
			print OUT1 join("\t",$id,$ref,$alt,@genotype),"\n";
		}
	}
}
close IN;
close OUT1;
close OUT2;
close OUT3;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub DEL_RSID{#select RS_id to delete or change genotype#
	my ($rsid) = @_;
	open IN,$rsid;
	my (%rs_remove,%rs_change);
	while (<IN>) {
		chomp;
		next if ($_ eq "" || /^$/);
		my @rs_id = split/\s+/;
		if (scalar @rs_id eq 1) {
			$rs_remove{$rs_id[0]} = 1 
		}else{
			$rs_change{$rs_id[0]} = $_;
		}
	}
	return \%rs_remove,\%rs_change;
}
sub DEL_SAM {#select sample which missing ratio is too high(missing ratio grater than 0.1) and the gender type is not the same(provide info and gender info calculate from genotype),then delete the sample#
	my ($gender,$missing_file) = @_;
	my %sample_remove;
	open IN,$gender;
	my (%gender,%gender_info);
	while (<IN>) {
		chomp;
		next if ($_ eq "" || /^$/);
		my @gender = split/\s+/;
		if (scalar @gender <= 5) {
			$sample_remove{$gender[0]}=1;
		}else{
			$gender{$gender[0]} = $gender[5];
			$gender_info{$gender[0]} = $_;
		}
	}
	close IN;
	open IN,$missing_file;
	while (<IN>) {
		chomp;
		my ($sample_id,$miss_ratio,$gender_type)=split/\s+/;
		if (($miss_ratio > 0.1) || (exists $gender{$sample_id} && $gender{$sample_id} ne $gender_type)) {
			$sample_remove{$sample_id}=1;
		}
	}
	close IN;
	return \%sample_remove,\%gender_info;
}

sub IDENTITY {#select the sample which identity ratio grater than 0.9 #
	my ($identity_file)=@_;
	open IN,$identity_file;
	my %identity;
	while (<IN>) {
		chomp;
		next if ($_ eq "" || /^$/);
		my ($sample1,$sample2,$identity_ratio)=split/\s+/;
		if ($identity_ratio > 0.9) {
			$identity{$sample1}=1;
			$identity{$sample2}=1;
		}
	}
	close IN;
	return \%identity;
}

sub USAGE {
        my $usage=<<"USAGE";
Contact:        czheluo\@gmail.com;
Script:			$Bin/$Script
Description:
	eg:
	perl $Bin/$Script -v -m -i -g -r -u -o 

Usage:
  Options:
	"help|?" =>\&USAGE,
	-v	<file>	inut pop.genotype.result
	-m	<file>	input sample_mising_and_gender.stat.result
	-i	<file>	inout sample_identity.stat.result
	-g	<file>	input sample_gender.list
	-r	<file>	input cbc_allele.list
	-u	<string>	input uniq or repeat(default uniq)
	-o	<dir>	output dir
USAGE
        print $usage;
        exit;
}
