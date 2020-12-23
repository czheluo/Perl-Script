#!/usr/bin/perl -w
use strict;
use warnings;
use List::MoreUtils qw(uniq);
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$tpm,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"tpm:s"=>\$tpm,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open TM,$tpm;
open OUT,">$fout/gene.list.tpm.txt";
my %ids;
while (<TM>) {
	chomp;

	my ($id,$all)=split/\t/,$_,2;
	if ($id eq "seq_id") {
		print OUT "$_\n";
	}
	$ids{$id}=$all;
}
close TM;

open In,$fin;
open Out,">$fout/gene.list";
my $fln=basename($fin);
my @nas=split/\./,$fln;
my @genes;
while (<In>) {
	chomp;
	my @all=split/\t/,$_;
	next if($_ =~ "id");
	my @gens=split/\;/,$all[8];
	foreach my $gene (@gens) {
		print Out "$nas[0]\t$gene\n";
		push @genes,join("\t",$gene);
	}
	
}
close In;
close Out;
my @uniq_genes= uniq @genes;
foreach my $gene (@uniq_genes) {
	if (exists $ids{$gene}) {
		print OUT "$gene\t$ids{$gene}\n";
	}
}
close OUT;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub ABSOLUTE_DIR #$pavfile=&ABSOLUTE_DIR($pavfile);
{
	my $cur_dir=`pwd`;chomp($cur_dir);
	my ($in)=@_;
	my $return="";
	if(-f $in){
		my $dir=dirname($in);
		my $file=basename($in);
		chdir $dir;$dir=`pwd`;chomp $dir;
		$return="$dir/$file";
	}elsif(-d $in){
		chdir $in;$return=`pwd`;chomp $return;
	}else{
		warn "Warning just for file and dir \n$in";
		exit;
	}
	chdir $cur_dir;
	return $return;
}
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:

	eg: perl -int filename -out filename 
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
