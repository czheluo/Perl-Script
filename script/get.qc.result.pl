#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$table);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"table:s"=>\$table,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin;
open OUT,">$fout";
my %ids;
while (<In>) {
	chomp;
	my($id,$file,$path)=split/\s+/,$_;
	my @all=split/\//,$path;
	my $name=(split/\./,$all[-1])[0];
	$name =~ s/-/_/g;
	$ids{$name}=$id;
	#print Out "$id\t$name\n";
}
close In;

open IN,$table;
while (<IN>) {
	chomp;
	if (/#/) {
		print OUT "$_\n";
	}else{
		my ($id,$all)=split/\s+/,$_,2;
		if (exists $ids{$id}) {
			print OUT "$ids{$id}\t$all\n";
		}else{next;}
	}
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

	eg: perl $Script -int fq.list -out QC.result -table QC_stat.xls
	
Usage:
  Options:
	-int input file name
	-table table result
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
