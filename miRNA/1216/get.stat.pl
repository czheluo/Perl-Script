#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fa1,$fa2,$table,$norm,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int1:s"=>\$fa1,
	"int2:s"=>\$fa2,
	"table:s"=>\$table,
	"norm:s"=>\$norm,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);

open In,$fa1;
$/=">";
my %seq1;
while (<In>) {
	chomp;
	next if ($_ eq "" || /^$/);
	my ($chr,$seq1) = split(/\n/,$_,2);
	$seq1 =~ s/\n//g;
	$seq1{$chr} = $seq1;
}
close In;

open IN,$fa2;
my %seq;
while (<IN>) {
	chomp;
	next if ($_ eq "" || /^$/);
	my ($chr,$seq,$tr) = split(/\n/,$_,3);
	$seq =~ s/\n//g;
	$tr =~ s/\n//g;
	$seq{$chr}{fa} = $seq;
	$seq{$chr}{ss} = $tr;
	#print $tr;die;
	my $len = length($seq);
	my $GC = $seq =~ tr/gcGC/gcGC/;
	my $GC_percent = $GC/$len;
	#print $GC_percent;die;
	$seq{$chr}{gc} = int(100*$GC_percent);
}
close IN;

$/="\n";
open NO,$norm;
my %ids;
while (<NO>) {
	chomp;
	next if ($_ =~ "miRNA");
	my ($id,$all)=split/\s+/,$_,2;
	$ids{$id}=$all;
}
close NO;
open TA,$table;
open Out,">$fout";
while (<TA>) {
	chomp;
	next if ($_ =~ "M_id");
	my($m,$mchr,$mstrand,$mstart,$mend,$pid,$pchr,$pstart,$pend,$pstrand,$plength,$penger)=split/\s+/,$_;
	my $len1=length($seq1{$m});
	my $MEF=-$penger*100/$len1/$seq{$pid}{gc}; #-dG*100/mirLen/CG%
	#print $MEF;die;
	print Out "$m\t$seq1{$m}\t$len1\t$mchr\t$mstrand\t$mstart\t$mend\t$pid\t$seq{$pid}{fa}\t$pchr\t$pstart\t$pend\t$pstrand\t$plength\t$penger\t$seq{$pid}{ss}\t$seq{$pid}{gc}\t$MEF\t$ids{$m}\n";
}
close TA;
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

	eg: perl $Script -int1 novel_miR_mature.fa -int2 novel_miR_pre.fa -table novel_miR_mature_infor.xls -norm novel_miR_norm.xls -out novel_miR_all.xls
	
Usage:
  Options:
	"int1:s"=>\$fa1,
	"int2:s"=>\$fa2,
	"table:s"=>\$table,
	"norm:s"=>\$norm,
	"out:s"=>\$fout, 
	-h         Help

USAGE
        print $usage;
        exit;
}
