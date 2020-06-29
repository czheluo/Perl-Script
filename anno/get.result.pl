#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$result,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"result:s"=>\$result,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin;
open Out,">$fout/result.xls";
my %seqsum;
while (<In>) {
	chomp;
	my($seq,$all)=split/\s+/,$_;
	my @all = split/\,/,$all;
	$seqsum{$seq}=scalar(@all);
	print Out "$seq\t",scalar(@all),"\n";
}
close In;
#print Dumper %seqsum;
open TA,$result;
my %stats;
my %type;
while (<TA>) {
	chomp;
	next if ($_=~ "#");
	my @alls=split/\t/,$_;
	#my @alls=split/\t/,$all;
	#print scalar(@alls);die;
	next if($alls[4] =~ "-");
	$stats{"type"}{$alls[5]} +=$seqsum{$alls[0]};
	#$stats{$alls[4]} ++;#=$seqsum{$alls[0]};
	$stats{"COG"}{$alls[4]} +=$seqsum{$alls[0]};
	$type{"type"}{$alls[5]}=$alls[7];
	$type{"COG"}{$alls[4]}=$alls[1];
}
close TA;
#print Dumper %stats;
#print Dumper %type;
open NUMC,">$fout/COG.xls";
open NUMK,">$fout/type.xls";
foreach my $key (sort keys %stats) {
	if ($key eq "COG") {
		#print %{$stats{$key}};die;
		foreach my $ty (sort keys %{$stats{$key}}) {
			next if($ty eq "");
			print NUMC "$ty\t$stats{$key}{$ty}\t$type{$key}{$ty}\n"; 
		}
	}else{
		foreach my $ty (sort keys %{$type{$key}}) {
			next if($type{$key}{$ty} eq "");
			print NUMK "$ty\t$stats{$key}{$ty}\t$type{$key}{$ty}\n"; 
		}	
		#next;
	}
	#print Out "$key\t$stats{$key}\t$type"
}
close NUMK;
close NUMC;
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

	eg: perl $Script -int annotations.orthologs -out ./ -result eggNOG_result.xls
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
