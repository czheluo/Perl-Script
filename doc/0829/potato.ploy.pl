#!/usr/bin/perl -w
use warnings;
use strict;

my $BEGIN_TIME=time();
use Getopt::Long;
my ($inputA,$inputB,$output);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"inputA:s"=>\$inputA,
	"inputB:s"=>\$inputB,
	"output:s"=>\$output,
			) or &USAGE;
&USAGE unless ($output);
#######################################################################################       
open IN,$inputA;
my %seq;
my @indi;

while (<IN>) {
	chomp;
	next if (/^##/);
	if (/^#/) {
		my ($chr,$pos,$id,$ref,$alt,$qual,$Filter,$indo,$format,$geno)=split(/\t/,$_,10);
	 #print OUT join("\t",@geno);
	 @indi=split(/\s+/,$geno);

		foreach my $ida (@indi) {
			$seq{$ida}="";
		}
	} else {
		my ($chr,$pos,$id,$ref,$alt,$qual,$Filter,$indo,$format,@geno)=split(/\t/,$_);
		my @format=split(/\:/,$format);
		my @gene;
		for (my $i=0;$i<@indi;$i++) {
			my ($gt,$ad,$dp);
			my @info =split(/\:/,$geno[$i]);
			for (my $j=0;$j<@info;$j++) {
				if ($format[$j] eq "GT") {
					$gt=$info[$j];
				}
			}
			if ($gt eq "0/0") {
				$gt="AA";
			} elsif ($gt eq "0/1") {
				$gt="AB";
			} elsif ($gt eq "1/1") {
				$gt="BB";

			}elsif ($gt eq "./.") {
				$gt="NA";

			}
			#push @gene,$gt;##connect together (all variables)
			$seq{$indi[$i]}.="$gt\t";
			

		}
		

		#print OUT "@gene\n";	

	
	}
    

}

close IN;
#print Dumper \%seq;
open IN,$inputB;
open OUT,">$output";
my %gro;
while (<IN>) {
	chomp;
	my ($idb,$gr)=split(/\s+/);
	$gro{$idb}=$gr;
}
foreach  my $idb (sort keys %seq) {
	print OUT join("\t",$idb,$gro{$idb},$seq{$idb}),"\n";
	}

close IN;

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
Usage:
  Options:
  -input	<file>	input  file name
  -output	<file>	input RESULT file name
  -h         Help

USAGE
        print $usage;
        exit;
}
