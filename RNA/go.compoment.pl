#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$min);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fin);
open In,$fin;
my (@out1,@out2,@out3,$id);
open Out1,">$fout/Biological.go";
open Out2,">$fout/Molecular.go";
open Out3,">$fout/Cellular.go";
while (<In>) {
	chomp;
	my @ID=split/\;;/,$_;
	foreach my $id (@ID) {
		if ($id =~ /Biological Process/) {
			my ($fn,$go)=split/\:\s+/,$id,2;
			$go=~s/\s+/_/g;
			#print $go;die;
			push @out1,join("\n",$go);
		}elsif ($id =~ /Molecular Function/) {
			my ($fn,$go)=split/\:\s+/,$id,2;
		    $go =~ s/\s+/_/g;
			#print $go;die;
			push @out2,join("\n",$go);
		}elsif ($id =~ /Cellular Component/) {
			my ($fn,$go)=split/\:\s+/,$id,2;
			$go=~s/\s+/_/g;
			#print $go;die;
			push @out3,join("\n",$go);
		}
	}
}
close In;
foreach my $ut (@out1) {
	print Out1 "$ut\n";
}
close Out1;
foreach my $ut (@out2) {
	print Out2 "$ut\n";
}
close Out2;
foreach my $ut (@out3) {
	print Out3 "$ut\n";
}
close Out3;


#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:

	eg: perl -int filename -out filename 
	

Usage:
  Options:
	-int input file name
	-out ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
