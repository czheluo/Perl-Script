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
&USAGE unless ($fout);
$fin=ABSOLUTE_DIR($fin);
$fout=ABSOLUTE_DIR($fout);
my @files=glob("$fin/*.txt");

foreach my $file (@files) {
	my $flns=basename($file);
	my ($id,undef)=split/\_/,$flns;
	`mkdir -p $fout/$id`;
	`mv $fin/$id.bayes.bayes.png $fin/$id.bayes.bayes.pdf $fout/$id`;
	`mv $fin/$id.bayes.outliers $fout/$id`;
	open In,"<$fin/$flns";
	open Out,">$fout/$id/$id\_fst.xls";
	while (<In>) {
		chomp;
		my ($i1,$i2,$i3,$i4,$i5,$i6)=split/\s+/,$_;
		if ($i1 eq "") {
			print Out "SNPs\t$i2\t$i3\t$i4\t$i5\t$i6\n";
		}else{
			print Out "$i1\t$i2\t$i3\t$i4\t$i5\t$i6\n";
		}		
	}
	close In;
	close Out;
}
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

	eg: perl -int ./ -out ./ 
	

Usage:
  Options:
	-int input file name
	-out ouput file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
