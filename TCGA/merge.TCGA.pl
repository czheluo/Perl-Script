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
	"int:s"=>\$fin,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
my @names;
my @files=glob("$fin/*.tsv");

my %maps;
foreach my $file (@files) {
	my $fln=basename($file);
	my ($name,undef)=split/\./,$fln,2;
	push @names,join("\t",$name);
	open IN,"<$fin/$fln";
	while (<IN>) {
		chomp;
		next if ($_ =~ "#" || $_ =~ "gene_id" || $_ =~ "N_unmapped" || $_ =~ "N_multimapping" ||$_ =~  "N_noFeature" ||$_ =~ "N_ambiguous");
		#print "$_";die;
		my($geneid,$genename,$type,$unst,$strf,$strs,$tpm,$fpkm,$fpkm_up)=split/\t/,$_;
		my ($gene_id,undef)=split/\./,$geneid;
		push @{$maps{$gene_id}{$genename}{tpm}},join("\t",$tpm);
		push @{$maps{$gene_id}{$genename}{fpkm}},join("\t",$fpkm);
		push @{$maps{$gene_id}{$genename}{fpkmup}},join("\t",$fpkm_up);
	}
	close IN;

}
#print Dumper %chrs;die;
open Out1,">$fout/tpm.txt";
open Out2,">$fout/fpkm.txt";
open Out3,">$fout/fpkmup.txt";
my $anames=join("\t",@names);
print Out1 "geneid\tgene_name\t$anames\n";
print Out2 "geneid\tgene_name\t$anames\n";
print Out3 "geneid\tgene_name\t$anames\n";
my $n=1;
my $bn=1;
foreach my $chr (sort keys %maps){
	#my $chr=~s/chr//;
	#print Out "group\t$n\n";
	foreach my $dis (sort keys %{$maps{$chr}}) {
		my $tpms=join("\t",@{$maps{$chr}{$dis}{tpm}});
		my $fpkms=join("\t",@{$maps{$chr}{$dis}{fpkm}});
		my $fpkmups=join("\t",@{$maps{$chr}{$dis}{fpkmup}});
		print Out1 "$chr\t$dis\t",join("\t",@{$maps{$chr}{$dis}{tpm}}),"\n";
		print Out2 "$chr\t$dis\t",join("\t",@{$maps{$chr}{$dis}{fpkm}}),"\n";
		print Out3 "$chr\t$dis\t",join("\t",@{$maps{$chr}{$dis}{fpkmup}}),"\n";
		#print Out1 "$tpms\n";
		#print Out2 "$fpkms\n";
		#print Out3 "$fpkmups\n";
	}	
} 
close Out1;
close Out2;
close Out3;

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

	eg: perl $Script -int tsv/ -out ./
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
