#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fa1,$fa2,$fa3,$table,$mrd,$list,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int1:s"=>\$fa1,
	"int2:s"=>\$fa2,
	"int3:s"=>\$fa3,
	"table:s"=>\$table,
	"list:s"=>\$list,
	"mrd:s"=>\$mrd,
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
open FA,$fa3;
$/=">";
my %seq3;
while (<FA>) {
	chomp;
	next if ($_ eq "" || /^$/);
	my ($chr,$seq1) = split(/\n/,$_,2);
	$seq1 =~ s/\n//g;
	$seq3{$chr} = $seq1;
}
close FA;

open IN,$fa2;
my %seq;

while (<IN>) {
	chomp;
	next if ($_ eq "" || /^$/);
	my ($chr,$tr) = split(/\n/,$_,3);
	#$seq =~ s/\n//g;
	$tr =~ s/\n//g;
	#$seq{$chr}{fa} = $seq;
	#$seq{$chr}{ss} = $tr;
	#print $tr;die;
	$seq{$chr} = $tr;
	#my $len = length($seq);
	#my $GC = $seq =~ tr/gcGC/gcGC/;
	#my $GC_percent = $GC/$len;
	#print $GC_percent;die;
	#$seq{$chr}{gc} = int(100*$GC_percent);
}
close IN;
open MR,$mrd;
my %mrds;
$/=">";
while (<MR>) {
	chomp;
	next if ($_ eq "" || /^$/);
	my ($chr,$all) = split(/\n/,$_,2);
	my @alls=split/\n/,$all;
	my $str;
	for (my $i=0;$i< scalar @alls;$i++) {
		if ($alls[$i] =~ "pri_struct") {
			(undef,$str,undef)=split/\s+/,$alls[$i];
			$str =~ s/\n//g;
			#print "$str\t$chr\n";die;
		}
	}
	#print $chr;die;
	$mrds{$chr}=$str;
}
close MR;
#print Dumper %mrds;die;
$/="\n";
open NO,$list;
my %ids;
while (<NO>) {
	chomp;
	next if ($_ =~ "#miRNA");
	my ($id,$all)=split/\s+/,$_,2;
	$ids{$id}=$all;
}
close NO;

open TA,$table;
open Out,">$fout";
while (<TA>) {
	chomp;
	next if ($_ =~ "miRNA_name");
	#my($m,$mchr,$mstrand,$mstart,$mend,$pid,$pchr,$pstart,$pend,$pstrand,$plength,$penger)=split/\s+/,$_;
	my ($id1,$id2)=split/\s+/,$_,2;
	my $len1=length($seq1{$id1});
	my $len2=length($seq3{$ids{$id1}});
	my $len3=length($seq{$ids{$id1}});
	my $seqq=$seq{$ids{$id1}};
	my $GC = $seqq =~ tr/gcGC/gcGC/;
	my $GC_percent = $GC/$len3;
	#print $GC_percent;die;
	my $gcc = int(100*$GC_percent);
	#my $MEF=-$penger*100/$len1/$seq{$pid}{gc}; #-dG*100/mirLen/CG%
	#print $MEF;die;
	#print $ids{$id1};die;
	my $id3=$ids{$id1};
	#print %mrds;die;
	#print $mrds{$id3};die;
	#print Out "$m\t$seq1{$m}\t$len1\t$mchr\t$mstrand\t$mstart\t$mend\t$pid\t$seq{$pid}{fa}\t$pchr\t$pstart\t$pend\t$pstrand\t$plength\t$penger\t$seq{$pid}{ss}\t$seq{$pid}{gc}\t$MEF\t$ids{$m}\n";
	print Out "$id1\t$seq1{$id1}\t$len1\t$ids{$id1}\t$seq3{$ids{$id1}}\t$len2\t$mrds{$ids{$id1}}\t$seq{$ids{$id1}}\t$len3\t$gcc\t$id2\n";
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

	eg: perl $Script -int1 plant.mature.dna.fa -int2 plant.hairpin.dna.fa -int3  precursor.converted -mrd miRBase.mrd -list known_miR.list -table known_miR_norm.xls -out known_result.xls
	
Usage:
  Options:
	"int1:s"=>\$fa1,
	"int2:s"=>\$fa2,
	"int3:s"=>\$fa3,
	"table:s"=>\$table,
	"list:s">\$list,
	"mrd:s">=\$mrd,
	"out:s"=>\$fout,
	-h         Help

USAGE
        print $usage;
        exit;
}
