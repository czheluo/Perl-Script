#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$result,$cog,$fun,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"cog:s"=>\$cog,
	"fun:s"=>\$fun,
	"result:s"=>\$result,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open CO,$cog;
my %cos;
while (<CO>) {
	chomp;
	next if($_=~"#" || $_=~"ENO");
	my($cg,$fn)=split/\t/,$_;
	#if (length($fn) >1 ) {
		#my @vals=split(undef,$fn);
		#foreach my $val (@vals) {
		#	push @{$cos{$cg}},join(",",$val);
		#}
	#	$cos{$cg}=join(",",split(undef,$fn));
	#}else{
		$cos{$cg}=$fn;
	#}	
}
close CO;
#print Dumper %cos;die;
open FU,$fun;
my %fu;
while (<FU>) {
	chomp;
	next if($_=~"#");
	my($fnn,$names)=split/\t/,$_;
	$fu{$fnn}=$names;
}
close FU;

open Out,">$fout/result.xls";
my %seqsum;
my @files=glob("$fin/*.emapper.annotations.orthologs");
foreach my $file (@files) {
	my $fn=basename($file);
	open In,"<$fin/$fn";
	while (<In>) {
		chomp;
		my($seq,$all)=split/\s+/,$_;
		my @all = split/\,/,$all;
		$seqsum{$seq}=scalar(@all);
		print Out "$seq\t",scalar(@all),"\n";
	}
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
open FUN,">$fout/FUN.xls";
open NUMK,">$fout/type.xls";
open COGS,">$fout/FUNS.xls";
my %cogs;
foreach my $key (sort keys %stats) {
	if ($key eq "COG") {
		#print %{$stats{$key}};die;
		foreach my $ty (sort keys %{$stats{$key}}) {
			next if($ty eq "");
			my $funs=$cos{$ty};
			if (length($funs) > 1  ) {
				#print "$funs\n";
				my $vals=join("\t",split(undef,$funs));
				my @all=split/\t/,$vals;
				#print @vals;die;
				foreach my $val (@all) {
					#print $val;die;
					$cogs{$val} +=$stats{$key}{$ty};
					print FUN "$ty\t$val\t$stats{$key}{$ty}\t$fu{$val}\n";
				}
			}else{
				$cogs{$funs} +=$stats{$key}{$ty};
				print NUMC "$ty\t$stats{$key}{$ty}\t$type{$key}{$ty}\n";
				print FUN "$ty\t$cos{$ty}\t$stats{$key}{$ty}\t$fu{$funs}\n";
			}

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
close FUN;
foreach my $kes (sort keys %cogs) {
	print COGS "$kes\t$cogs{$kes}\t$fu{$kes}\n";
}
close COGS;
#print Dumper %cogs;
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

	eg: perl $Script -int ./ -out ./ -result eggNOG_result.xls -cog NOG.funccat.txt -fun ../fun2003-2014.tab
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
