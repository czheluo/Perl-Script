#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$as,$gtf);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"gene:s"=>\$fin,
	"gtf:s"=>\$gtf,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fin);
#$gtf=ABSOLUTE_DIR($gtf);
#$as=ABSOLUTE_DIR($as);
#$fout=ABSOLUTE_DIR($fout);
open In,$fin;
my %gene;
open Out,">$fout";
while(<In>){
	chomp;
	if(/seq_id/){
		my (undef,$allname)=split/\s+/,$_,2;
		print Out "gene_id\tgene_name\tchromosome\tstart\tend\tgene_length\t$allname\n";
	}else{
		my ($gen,$all)=split/\s+/,$_,2;
		$gene{$gen}=$all;
	}
}
close In;
open In,$gtf;
while(<In>){
	chomp;
	next if (/#/);
	#print $_;die;
	my ($chr,$dbs,$type,$start,$end,undef,undef,undef,$details)=split/\s+/,$_,9;
	next if ($type ne "gene");
	#print $type;die;
	my ($ged,$name,$biotype,$description,$gene_id,undef)=split/\;/,$details,6;
	my (undef,$gens)=split/\:/,$ged;
	my (undef,$gene_name)=split/\=/,$name;
	my (undef,$desc)=split/\=/,$description;
	my $len=$end-$start;
	if(exists $gene{$gens}){
		print Out "$gens\t$gene_name\t$chr\t$start\t$end\t$len\t$desc\t$gene{$gens}\n";
	}else{
		print Out "_\t_\t_\t_\t_\t_\t_\t_\t_\n";
	}
}
close In;
close Out;
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

	eg:perl $Script -gene CN_vs_KA.diff.exp.annot.xls -gtf Mus_musculus.GRCm38.96.gff3 -out gene.anno 
	

Usage:
  Options:
	"gene:s"=>\$fin,
	"gtf:s"=>\$gtf,
	"out:s"=>\$fout,
USAGE
        print $usage;
        exit;
}
