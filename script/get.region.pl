#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($list,$fout,$gff);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"list:s"=>\$list,
	"gff:s"=>\$gff,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($gff);
#$gff=ABSOLUTE_DIR($gff);
open In,$gff;
my %genes;
while(<In>){
	chomp;
	next if (/sca/);
	#print $_;die;
	my ($chr,$dbs,$type,$start,$end,undef,undef,undef,$details)=split/\s+/,$_,9;
	if ($type eq "ncRNA_gene" || $type eq "gene"){
		#print $type;die;
		my ($ged,$name,$biotype,$description,$gene_id,undef)=split/\;/,$details,6;
		my (undef,$gens)=split/\:/,$ged;
		my (undef,$gene_name)=split/\=/,$name;
		my (undef,$desc)=split/\=/,$description;
		$genes{$chr}=join("\t",$start,$end,$gens);
		#if(exists $gene{$gens}){
			#print Out "$gens\t$gene_name\t$chr\t$start\t$end\t$len\t$gene{$gens}\t$desc\n";
		#}elsif(!exists $gene{$gens}){
			#next;
			#print Out "$gens\t_\t_\t_\t_\t_\t_\t_\t_\n";
		#}else{
			#next;
		#}
	#}else{
		#next;
	}
}
close In;
open IN,$list;
my %chrs;
while(<IN>){
	chomp;
	my ($ch,$pos)=split/\_/,$_;
	my $star=$pos-500000;
	my $end=$pos+500000;
	if (exists $genes{$ch}){
		my @re=split("\t",$genes{$ch});
		if ($re[0]>$star && $re[0]<$end){
			$chrs{$_}=$re[2];
			#push @{$chrs{$_}},$re[2];
			#print $re[2];
		}elsif($re[1]>$star && $re[1]<$end){
			$chrs{$_}=$re[2];
			#push @{$chrs{$_}},$re[2];
			#print $re[2];
		}elsif($re[0]<$star && $re[1]>$end){
			$chrs{$_}=$re[2];
			#push @{$chrs{$_}},$re[2];
			#print $re[2];
		}else{
			$chrs{$_}="NA";
		}
	}

	#print Dumper %chrs;die;
}
close In;
print Dumper %chrs;
open Out,">$fout";
#my @all=keys %chrs
foreach my $marker (sort keys %chrs){
	#my @all=split/\s+/,$chrs{$marker};
	#if(sc)
	#print @all;
	#print $marker;
	#print $chrs{$marker};
	print Out "$marker\t$chrs{$marker}\n";
	#print Out join("\t",$marker,join("\t",$chrs{$marker})),"\n";
}
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

	eg:perl $Script -list uniq.list -gff ref.gff -out 10k.region
	

Usage:
  Options:
  	gene
	"list:s"=>\$list, #marker list(chr1_28743659)
	"gff:s"=>\$gff,#ref.gff file
	"out:s"=>\$fout, #output file name
USAGE
        print $usage;
        exit;
}
