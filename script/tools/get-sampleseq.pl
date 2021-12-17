#!/mnt/bin/env perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($ref,$gff,$vcf,$list,$gene,$out);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
        "help|?" =>\&USAGE,
        "ref:s"=>\$ref,
        "vcf:s"=>\$vcf,
		"out:s"=>\$out,
		"list:s"=>\$list,
                        ) or &USAGE;
&USAGE unless ($ref and $vcf and $list);
my %stat;
open Ref,$ref;
if($ref=~/gz$/){
        close Ref;
        open Ref,"gunzip -c $ref|";
}
$/=">";
while(<Ref>){
        chomp;
        next if ($_ eq ""|| /^$/);
        my($chr,@seq)=split(/\s+/,$_);
        my $seq=join("",@seq);
        $stat{$chr}{seq}=$seq;
}       
close Ref;
my $geneinfo;
open LIST,$list;
$/="\n";
while (<LIST>){
	chomp;
	next if ($_ eq "" || /^$/|| /^#/);#chr1	2000	3000
	my ($chr,$start,$end)=split(/\t/,$_);
	$geneinfo=join("\-",$chr,$start,$end);
}
close LIST;

my @samples;

my $geneseq;
foreach my $chr(keys %stat ){
	my($id,$start,$end)=split(/\-/,$geneinfo);
	if($chr eq $id){
		my $length=$end - $start + 1;
		$geneseq=substr($stat{$chr}{seq},$start - 1,$length);
	}
}

open In,$vcf;
if($vcf=~/gz$/){
	close In;
	open In,"gunzip -c $vcf|";
}
open OUT1,">$out/region.vcf";
while (<In>){
	chomp;
	next if ($_ =~ "" || /^$/|| /##/);
	my($chr,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@undi)=split(/\t/,$_);#chr1	1072	chr1_1072	A	C	154.84	PASS	AC=2;AF=1.00;AN=2;ANN=C|upstream_gene_variant|MODIFIER|NAC001|gene0|transcript|rna0|protein_coding||c.-2688A>C|||||2559|,C|intergenic_region|MODIFIER|CHR_START-NAC001|CHR_START-gene0|intergenic_region|CHR_START-gene0|||n.1072A>C||||||;DP=6;ExcessHet=3.0103;FS=0;MLEAC=2;MLEAF=1;MQ=60;QD=25.81;SOR=2.303;set=variant	GT:AD:DP:GQ:PL	1/1:0,6:6:18:183,18,0
	if($chr eq "#CHROM"){
		@samples=@undi;
		print OUT1 $_,"\n";
		#print join("\t",@samples),"\n";
	}else{
		my ($genechr,$genestart,$geneend)=split(/\,/,$geneinfo);
		next if($chr ne $genechr);	#!=
		if($pos>=$genestart and $pos<= $geneend){
			print OUT1 $_,"\n";
			my @alt=split(/,/,join(",",$ref,$alt));
			my (%ale,%len);
			for (my $i=0;$i<@alt;$i++) {
				$ale{$alt[$i]}=$i;
				$len{length($alt[$i])}=1;
			}
			my $snptype="SNP";
			$snptype="INDEL"  if ((length$alt[0] > "1")||(length$alt[1] > "1"));

			my $snppos=$pos - $genestart;
			my @format=split(/:/,$format);
			my ($gt,$ad);
			for (my $i=0;$i<@format;$i++) {
				$gt = $i if ($format[$i] eq "GT");
				$ad = $i if ($format[$i] eq "AD");
			}
			for (my $i=0;$i<@samples;$i++) {
				my $sample=$samples[$i];
				my @info=split(/:/,$undi[$i]);
				for (my $j=0;$j<@info;$j++) {
					next if (($info[$gt] eq "./.") || ($info[$j] eq "0/0"));
					my ($g1,$g2)=split(/\//,$info[$gt]);
					my ($d1,$d2)=split(/\//,$info[$ad]);
					#print "$id\t$alt[$g1]\/$alt[$g2]\t$snppos\n";
					my $type=length$ref ;
					if ($g1 eq $g2) {
						$stat{$sample}{$snppos}{$type}=$alt[$g1] ;
					}else{
						my $percent1=sprintf("%.2f",$d1/$d2);
						my $percent2=sprintf("%.2f",$d2/$d1);
						if($percent1 > "2"){
							$stat{$sample}{$snppos}{$type}=$alt[$g1] ;
						}elsif($percent2 > "2"){
							$stat{$sample}{$snppos}{$type}=$alt[$g2] ;
						}else{	
							if($snptype eq "SNP"){
								my $basetype=join("\/",$alt[$g1],$alt[$g2]);
								$stat{$sample}{$snppos}{$type}="R" if($basetype eq "A\/G");
								$stat{$sample}{$snppos}{$type}="M" if($basetype eq "A\/C");
								$stat{$sample}{$snppos}{$type}="W" if($basetype eq "A\/T");
								$stat{$sample}{$snppos}{$type}="Y" if($basetype eq "C\/T");
								$stat{$sample}{$snppos}{$type}="K" if($basetype eq "G\/T");
								$stat{$sample}{$snppos}{$type}="S" if($basetype eq "G\/C");
							}else{
								my $lang;	
								if(length$alt[$g1] >= length$alt[$g2]){
									$lang = $alt[$g1];
								}else{
									$lang = $alt[$g2];
								}
								$stat{$sample}{$snppos}{$type}=$lang;
							}
						}
					}
				}
			}
		}
	}
}
close In;
open Out,">$out/$geneinfo.fa";
foreach my $sample (keys %stat){
	my $seq=$geneseq;
			
	my ($left,$right,$cutpos);
	foreach my $snppos(sort{$a<=>$b}keys %{$stat{$sample}}){
		foreach my $type(keys %{$stat{$sample}{$snppos}}){
			$cutpos=$snppos + $type;
			$left=substr($seq,0,$snppos);
			$right=substr($seq,$cutpos);
			$seq=join("",$left,$stat{$sample}{$snppos}{$type},$right);
		}
	}
	print Out ">$sample\n$seq\n";
}
close Out;
#my $job="clustalo -i $out/$gene.fa -o $gene.diff.phy --outfmt=phy ";
#`$job`;

#######################################################################################
#print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
########################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:                 $Script
Description:
        get gene's seq
        eg:
        perl $Script -ref -gff -vcf -out -gene -list

Usage:
  Options:
	-ref	<file>  input ref.fa
	-vcf	<file>	pop.final.vcf
	-out	<file>	output file name
	-list	<file>	input sample.list
	-h			Help

USAGE
        print $usage;
        exit;
}
	

