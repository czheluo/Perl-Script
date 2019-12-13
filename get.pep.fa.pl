#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fa,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"fa:s"=>\$fa,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open FA,$fa;
$/=">";
my %seqs;
while (<FA>) {
	chomp;
	next if ($_ eq "" || /^$/);
	my ($chr,$seq) = split(/\n/,$_,2);
	my ($id,undef)=split/\./,$chr;
	$seq =~ s/\n//g;
	#print $id;die;
	$seqs{$id}=$seq;
}
#print Dumper %seqs;die;
close FA;
$/="\n";
open In,$fin;
open Out,">$fout";
while (<In>) {
	chomp;
	my $upc=uc($_);
	#print $upc;die;
	if (exists $seqs{$upc}) {
		print "$_\n";
		print Out ">$upc\n$seqs{$upc}\n";
	}
}
close In;
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

	eg: perl perl.model.pl -int pep.list -fa ref.pep.fa -out pep.fa >fa.list
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
