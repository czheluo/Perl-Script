#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$or,$po,$link,$list,$result);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out:s"=>\$fout,
	"or:s"=>\$or,
	"po:s"=>\$po,
	"link:s"=>\$link,
	"list:s"=>\$list,
	"result:s"=>\$result,
			) or &USAGE;
&USAGE unless ($fout);

open In,$or;
my %ors;
while (<In>) {
	chomp;
	next if(/^Query-Name/);
	my ($orn,$gene,undef)=split/\s+/,$_,3;
	$ors{$orn}=$gene;
}
close In;

open IN,$po;
my %pro;
while (<IN>) {
	chomp;
	next if(/^Query-Name/);
	my ($gene,$porn,undef)=split/\s+/,$_,3;
	$pro{$porn}=$gene;
}
close IN;

open RO,$link;
open Out,">$fout";
while (<RO>) {
	chomp;
	next if(/^protein1/);
	my ($pro1,$pro2,$score)=split/\s+/,$_;
	#print $pro{$pro1};
	#print $ors{$pro1} ;die;
	if (exists $pro{$pro1} && exists $ors{$pro1} && $pro{$pro1} eq $ors{$pro1}) {
		if (exists $pro{$pro2}) {
			print Out "$pro{$pro1}\t$pro{$pro2}\t$score\n";
		}elsif(exists $ors{$pro2}){
			print Out "$pro{$pro1}\t$ors{$pro2}\t$score\n";
		}
	}
}

close RO;
close Out;
open LT,$list;
my %ls;
while (<LT>) {
	chomp;
	$ls{$_}=1;
}
close LT;
open OM,"<com.xls";
open OUT,">$result";
while (<OM>) {
	chomp;
	my ($gen,$target,$score)=split/\s+/,$_;
	if (exists $ls{$gen}|| exists $ls{$target}){#|| exists $ls{$target}
		print OUT "$_\n";
	}
}
close OM;
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

	eg: perl -int filename -out filename 
	
Usage:
  Options:
	"int:s"=>\$fin,
	"out:s"=>\$fout,
	"or:s"=>\$or,
	"po:s"=>\$po,
	"link:s"=>\$link,
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
