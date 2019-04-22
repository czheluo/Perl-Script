#!/usr/bin/perl -w
use warnings;
use strict;

my $BEGIN_TIME=time();
use Getopt::Long;
my ($input,$output,$ref);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"input:s"=>\$input,
	"output:s"=>\$output,
    "ref:s"=>\$ref,
			) or &USAGE;
&USAGE unless ($input and $output);
###############################################################`#######################       

open IN,"$input";
my $oldchr;
my $head;
my %filehand;
while (<IN>){
	chomp;
	next if ($_ eq ""||/^$/);
	my @line=split(/\s+/,$_);
	if($line[0] eq "#CHROM" ){
		 $head=$_;
	}else{
		if(!exists $filehand{$line[0]}){
			open $filehand{$line[0]},">$line[0].file";
			print {$filehand{$line[0]}} $head,"\n";
		}
			print {$filehand{$line[0]}} $_,"\n";
		
	}
}
close IN;
close Out;
#print Dumper \$seq;
#print Dumper \%chr;
#3print Dumper \$seqlength;
#print Dumper \%slength;


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
Usage:
  Options:
  -input	<file>	input reference file name
  -output	<file>	input gff file name
  -h         Help

USAGE
        print $usage;
        exit;
}



