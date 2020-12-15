#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$asv);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"asv:s"=>\$asv,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
$fin=ABSOLUTE_DIR($fin);
open In,$asv;
my %mods;
while (<In>) {
	chomp;
	#my($module,$asv,$r,$p,$fa,$gen)=split/\s/,$_;
	my($module,$asv,$alls)=split/\s/,$_,3;
	$alls =~ s/\r//g;
	#print $alls;die;
	#$mods{$module}{$asv}=join("\t",$r,$p,$fa,$gen);
	$mods{$module}{$asv}=$alls;
}
close In;
open Out,">$fout";
my @files=glob("$fin/*.xls");
foreach my $file (@files) {
	my $fna=basename($file);
	my ($mod,undef)=split/\./,$fna,2;
	open IN,"<$fin/$fna";
	while (<IN>) {
		chomp;
		my @all=split/\t/,$_;
		next if($all[0] eq "id");
		next if($all[6]>0.01);
		foreach my $modu (sort keys %mods){
			if (exists $mods{$mod}) {
				foreach my $asvs (sort keys %{$mods{$modu}}){
					print Out "$mod\t$asvs\t$mods{$modu}{$asvs}\t$all[0]\t$all[2]\t$all[6]\t$all[7]\t$all[8]\n";
				}
			
			}
		}
	}
	close IN;
}
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

	eg: perl -int filename -out filename 
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
