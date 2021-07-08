#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$node,$edge,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"node:s"=>\$node,
	"edge:s"=>\$edge,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);

open NO,$node;
my %ids;
while (<NO>) {
	chomp;
	next if(/^id/);
	my($id,undef,undef,undef,undef,$modeul,undef)=split/\s+/,$_;
	$ids{$id}=$modeul;
}
close NO;
open In,$fin;
while (<In>) {
	chomp;
	my $mod=$_;
	open ED,$edge;
	open Out,">$fout/$mod.txt";
	print Out "source\ttarget\tweight\n";
	while (<ED>) {
		chomp;
		next if(/^source/);
		my($source,$target,$weight,undef)=split/\s+/,$_,4;
		if ($ids{$source} eq $mod ) {
			print Out "$source\t$target\t$weight\n";
		}
	}
	close Out;
	close ED;
}
close In;
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

	eg: perl -int list -node network.nodes.txt -edge network.edges.txt -out ./
	
Usage:
  Options:
	"int:s"=>\$fin,
	"node:s"=>\$node,
	"edge:s"=>\$edge,
	"out:s"=>\$fout,
	-h         Help

USAGE
        print $usage;
        exit;
}
