#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$rockindex);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out:s"=>\$fout,
	"rock:s"=>\$rockindex,
			) or &USAGE;
&USAGE unless ($fout);
open SH,">$fout/rockhopper2.sh";
print SH "#PBS -l nodes=1:ppn=6\n";
print SH "#PBS -l mem=20G\n";
print SH "#PBS -q rna\n";
print SH "cd $fout\n";
print SH "java -Xmx1200m -cp /mnt/ilustre/users/deqing.gu/software/Rockhopper.jar Rockhopper -s true -p 6  -rf -g $rockindex ";
#print SH "-s true \\ \n";
#print SH "-p 6 \\ \n";
#print SH "-rf \\ \n";
#print SH "-g $rockindex \\ \n";
open In,$fin;
my $rock=0;
my $name;
my @name;
while (<In>) {
	chomp;
	my($id,undef,$fq1,$fq2)=split/\s+/,$_;
	if ($rock eq 0) {
		$rock=1;
		print SH "$fq1%$fq2\,";
	}elsif ($rock eq 1) {
		$rock=2;
		print SH "$fq1%$fq2\,";
	}elsif ($rock eq 2) {
		$rock=0;
		print SH "$fq1%$fq2\t ";
		my @ids=split/\_/,$id;
		if (scalar @ids eq 2) {
			my ($id1,$id2)=split/\_/,$id;
			push @name,join("\t",$id1);
		}else{
			my ($id1,$id2,$id3,undef)=split/\_/,$id;
			$name =join("_",$id1,$id2,$id3);
			push @name,join("\t",$name);
		}
	}
}
print SH " -L ";
foreach my $nnm (@name) {
	print SH "$nnm\,";
}
#print SH " \\ \n";
print SH " -v true \n";
close In;
close SH;

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

	eg: perl rockhopper.pl -int trimPairFq.case5.list -out ./ -rock rock_index/
	

Usage:
  Options:
	-int input file name
	-out ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
