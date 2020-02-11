#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($com,$vcf,$out);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"vcf:s"=>\$vcf,
	"out:s"=>\$out,
	"c:s"=>\$com,
			) or &USAGE;
&USAGE unless ($vcf and $out);
open IN,$com;
my %gro;
while (<IN>) {
	chomp;
	next if ($_ eq "" || /^$/ || /^#/);
	my@info=split/\s+/,$_;
	my$new=pop(@info);
	push @{$gro{$new}},@info;
}
close IN;
open IN,$vcf;
if($vcf=~/gz/){
	close IN;
	open IN,"gunzip -c $vcf| ";
}

my (@indi,%stat,$gt,$ad,$dp);
my $get=0;
open OUT,">$out";
while (<IN>) {
	chomp;
	next if ($_ eq "" || /^$/);
	if(/^##/){
		print OUT "$_\n";
		next;
	}
	my ($chr,$pos,$id,$ref,$alt,$filter,$qual,$info,$format,$gene)=split/\s+/,$_,10;
	if (/^#/) {
		print OUT join("\t",$chr,$pos,$id,$ref,$alt,$filter,$qual,$info,$format);
		@indi = split/\s+/,$gene;
		foreach my$sam(sort keys %gro){
			print OUT "\t$sam";
			foreach my$id(@{$gro{$sam}}){
				for (my$i=0;$i<scalar@indi;$i++){
					if($id eq $indi[$i]){
						push @{$stat{$sam}},$i;
					}
				}
			}
		}
		print OUT "\n";
		next;
	}
	my$gts=join(",",$ref,$alt);
	my@gts=split/\,/,$gts;
	next if(scalar@gts > "2");
	print OUT join("\t",$chr,$pos,$id,$ref,$alt,$filter,$qual,$info,"GT:AD:DP");
	my @gene = split/\s+/,$gene;
	if($get eq "0"){
		my @format = split/\:/,$format;
		for (my $j=0;$j<scalar@format ;$j++) {
			$gt=$j if ($format[$j] eq "GT");
			$ad=$j if ($format[$j] eq "AD");
			$dp=$j if ($format[$j] eq "DP");
		}
	}

	foreach my$sam(sort keys%stat){
#		print "$sam\t",join("\t",@{$stat{$sam}}),"\n";
		if(scalar@{$stat{$sam}} eq "1"){
			my@sinfo=split(/\:/,$gene[${$stat{$sam}}[0]]);
			print OUT "\t$sinfo[$gt]:$sinfo[$ad]:$sinfo[$dp]";
		}else{
			my%mar;
			my$depth=0;
			foreach my$n(@{$stat{$sam}}){	
				my@gentype=split(/\//,(split(/\:/,$gene[$n]))[$gt]);
				next if($gentype[0] eq "\.");
				my@averdep=split(/\,/,(split(/\:/,$gene[$n]))[$ad]);
				$depth += (split(/\:/,$gene[$n]))[$dp];
				$mar{$gentype[0]} += $averdep[0];
				$mar{$gentype[1]} += $averdep[1];
			}
			my($gt1,$ad1,$gt2,$ad2);
			my$scalars=0;
			foreach my$key(keys %mar){
				$scalars++;
			}
			if($scalars eq "0"){
				$gt1="\.";
				$gt2="\.";
				$ad1=0;
				$ad2=0;
			}elsif($scalars eq "1"){
				foreach my$key(keys %mar){
					$gt1=$key;
					$gt2=$key;
					if($key eq "0"){
						$ad1=$mar{$key};
						$ad2=0;
					}elsif($key eq "1"){
						$ad2=$mar{$key};
						$ad1=0;
					}
				}
			}else{
				foreach my$key(keys %mar){
					if($key eq "0"){
						$gt1=$key;
						$ad1=$mar{$key};
					}elsif($key eq "1"){
						$gt2=$key;
						$ad2=$mar{$key};
					}
				}
			}
			print OUT "\t$gt1\/$gt2:$ad1,$ad2:$depth";
		}
	}
	print OUT "\n";
}

close IN;
close OUT;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:
	fq thanslate to fa format
	eg:
	perl $Script -i -o -k -c

Usage:
  Options:
	-vcf	input vcf file
	-out	out file
	-c   combine.list
  -h         Help

USAGE
        print $usage;
        exit;
}
