#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$Fin,$seq);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"loc:s"=>\$fin,
	"vcf:s"=>\$Fin,
	"out:s"=>\$fout,
	"seq:s"=>\$seq,
			) or &USAGE;
&USAGE unless ($fout);
open IN,$fin;
my %hash;
while (<IN>){
	chomp;
	next if ($_ eq ""|| /^$/ || /#/ || /\=/);
	my ($marker,$gtype,$info)=split(/\t/,$_,3);
	if ($gtype =~ />/ || $gtype =~ /</ ) {
		$gtype=~s/>//g;
		$gtype=~s/<//g;
		$hash{$marker}=$gtype;
	}else{
		$hash{$marker}=$gtype;
	}
}
close IN;
#print Dumper \%hash;die;
open IN,$Fin;
my %stat;
my $gtype;
open Out,">$seq";
print Out "marker\ttype\tref\talt\n";
while (<IN>){
	chomp;
	next if ($_ eq ""|| /^$/ || /^#/);
	my ($chr,$pos,$id,$ref,$alt,$data)=split(/\s+/,$_,6);
	#my @alt = join("\t",$ref,$alt);
	#print length($alt),"\n";
	my $seq=join("\t",$ref,$alt);
	#my %len;
	#foreach my $ale (@alt) {
		#print $ale,"\n";
		#$len{length($ale)}=1;
	#}
	#print Dumper %len;die;
	my @alt = split/\,/,$alt;
	#print $alt[0];die;
	if (exists $hash{$id}){
		$gtype=$hash{$id};
		if (length($alt[0]) ne length($ref) ) {
			print Out "$id\t$hash{$id}\t$seq\n";
			$stat{$chr}{$gtype}{indel}++;
		}else{
			print Out "$id\t$hash{$id}\t$seq\n";
			$stat{$chr}{$gtype}{snp}++;
		}
	}
}
close IN;
close Out;
#print Dumper \%stat;die;
open OUT,">$fout";
print OUT "chr\ttype\tsnp\tindel\n";
foreach my $chr (sort keys %stat) {
	foreach my $gtype(sort keys %{$stat{$chr}}) {
		$stat{$chr}{$gtype}{snp}||=0;
		$stat{$chr}{$gtype}{indel}||=0;
		print OUT join("\t",$chr,$gtype,$stat{$chr}{$gtype}{snp},$stat{$chr}{$gtype}{indel}),"\n";
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

	eg:

	perl $Script -i total.qtl (pop.primary.marker) -m pop.final.vcf -o marker.stat.result

Usage:
  Options:
  -loc	<file>	input total.qtl & pop.primary.marker
  -vcf	<file>  input pop.final.vcf (vcf file)
  -out	<file>	marker.stat.result
  -seq  <file>	output file names 
  -h         Help

USAGE
        print $usage;
        exit;
}
