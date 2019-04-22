#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fin1,$fout,$min,$fout1,$fout2,$fout3);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"int1:s"=>\$fin1,
	"out:s"=>\$fout,
	"out1:s"=>\$fout1,
	"out2:s"=>\$fout2,
	"out3:s"=>\$fout3,
			) or &USAGE;
&USAGE unless ($fin);

open IN,$fin;
my @start;
my @end;
my @id;
my @chr;
my %region;
#open Out,">$fout";
while (<IN>) {
	chomp;
	next if (/^Transposon_Name/);
	my ($id1,$ft,$start1,$end1,undef)=split/\s+/,$_;
	#print Dumper $id1;
	my ($id2,undef)=split/[E]/,$id1;
	#print Dumper @id2;die;
	$id2=~ s/AT/chr/g;
	$id2=~s/T//g;
	#print Dumper $id2;die;
	push @id,join("\t",$id1),"\n";
	push @chr,join("\t",$id2),"\n";
	push @start,join("\t",$start1),"\n";
	push @end,join("\t",$end1),"\n";
	#print Dumper $start;
	#print Dumper $end;die;
	my $chr=$id2;
	$region{$chr}{join("\t",$start1,$end1)}=$id1;
}

close IN;
#do not use the array to do complicate things
#print Out "@id\@chr";#\n@chr\t@start\t@end\n";

open IN,$fin1;
open Out,">$fout";
open Out1,">$fout1";
open Out2,">$fout2";
open Out3,">$fout3";
my %stat;
while (<IN>) {
	chomp;
	next if ($_ eq "" || /^##/ || /^#/);
	# g1      S1_Abn  S1_Nor  S3_Abn  S3_Nor
	#my ($chr,$pos,$ID,$REF,$ALT,$QUAL,$INFO,$g1,$S1_Abn,$S1_Nor,$S3_Abn,$S3_Nor) =split(/\s+/,$_);
	my ($chr,$pos,$ID,$REF,$ALT,$QUAL,$INFO,@gro) =split(/\s+/,$_);
	my ($g1,$S1_Abn,$S1_Nor,$S3_Abn,$S3_Nor)=split(/\s+/,@gro);
	#next if($FILTER eq "LowQual");
	#print Dumper $FILTER;die;
	#print Dumper @gro;die;
	#my ($gt1,undef)=split(/\:/,$g1);
	#my ($gt2,undef)=split(/\:/,$S1_Abn);
	#my ($gt3,undef)=split(/\:/,$S1_Nor);
	#my ($gt4,undef)=split(/\:/,$S3_Abn);
	#my ($gt5,undef)=split(/\:/,$S3_Nor);
	if ($QUAL eq "del") {
		print Out1 join("\t",$chr,$pos,$ID,$REF,$ALT,$QUAL,@gro),"\n";
	}else{
		print Out2 join("\t",$chr,$pos,$ID,$REF,$ALT,$QUAL,@gro),"\n";
	}
	foreach my $region (sort keys %{$region{$chr}}) {
		my ($pos3,$pos4)=split(/\t/,$region);
		#my @out;
		if ($pos >= $pos3 && $pos <= $pos4){
			my @out;
			my $i;
			for ($i=1;$i<@gro ;$i++) {
				#next if($gro[0] =~ "./." && $gro[$i] =~ "./.");
				if ($gro[0] =~ "./." && $gro[$i] !~ "./.") {
					push @out,join("\t",join("||",$gro[0],$gro[$i]));
				}else{
					my ($gt1,undef)=split(/\:/,$gro[0]);
					my ($gt2,undef)=split(/\:/,$gro[$i]);
					if ( $gt1 ne $gt2) {
						push @out,join("\t",join("||",$gro[0],$gro[$i]));
					#print Out join("\t",$region{$chr}{$region},$chr,$region,@out),"\n";
					}else{
						push @out,join("\t",join("||",qw(NA),qw(NA)));
					}
				}
				#print Dumper @out;die;
			}
			#print Dumper \@out;die;
			print Out join("\t",$region{$chr}{$region},$chr,$region,$QUAL,@out),"\n";
			print Out3 join("\t",$region{$chr}{$region},$chr,$region,$QUAL,@out),"\n";
		}
		print Out join("\t",$region{$chr}{$region},$chr,$region,"0","0","0","0","0"),"\n";	
	}
}
#print "$chr\t$pos\t$ID\t$REF\t$ALT\t$gt1\t$gt2\t$gt3\t$gt4\t$gt5\t\n";die;
#print Out "$chr\t$pos\t$ID\t$REF\t$ALT\t$gt1\t$gt2\t$gt3\t$gt4\t$gt5\t\n";
close IN;
close Out;
close Out1;
close Out2;
close Out3;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:

	eg:  perl cnv.geno.pl -int TAIR10_Transposable_Elements.txt -int1 pop.cnv.vcf -out cnvall.result -out1 del -out2 dul -out3 cnv.result
	
Usage:
  Options:
	-int input Transposon_Name file name
	-int1 input cnv or sv vcf result file name
	-out ouput geno pop (sample ID) file name 
	-out1 output final result 
	-h         Help

USAGE
        print $usage;
        exit;
}
