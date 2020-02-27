#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$index);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"index:s"=>\$index,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin;
open RE,">$fout/all.index.xls";
while (<In>) {
	chomp;
	open IN,$index;
	open Out,">$fout/$_.index-calc.result.xls";
	my $ch=$_;
	while(<IN>){
		chomp;
		if ($_ =~ "#") {
			print Out "#chr		pos	type	ref	Hongro-GT	Hongro-AD	Yanfu_6-GT	Yanfu_6-AD	mix1-G	mix1-AD	mix2-GT	mix2-AD	INDEX1	INDEX2	DELTA		|DELTA|	ANNOTATION	HIGH	MODERATE	LOW	MODIFIER\n";
		}else{
			my ($chr,$pos,$type,$ref,$HongroGT,$HongroAD,$Yanfu_6GT,$Yanfu_6AD,$mix1G,$mix1AD,$mix2GT,$mix2AD,$INDEX1,$INDEX2,$deta,$all)=split/\s+/,$_,16;
			next if ($chr ne $ch);
			my $absindex=abs($deta);
			#print "$absindex\n";
			print Out "$chr\t$pos\t$type\t$ref\t$HongroGT\t$HongroAD\t$Yanfu_6GT\t$Yanfu_6AD\t$mix1G\t$mix1AD\t$mix2GT\t$mix2AD\t$INDEX1\t$INDEX2\t$deta\t$absindex\t$all\n";
			print RE "$chr\t$pos\t$type\t$ref\t$HongroGT\t$HongroAD\t$Yanfu_6GT\t$Yanfu_6AD\t$mix1G\t$mix1AD\t$mix2GT\t$mix2AD\t$INDEX1\t$INDEX2\t$deta\t$absindex\t$all\n";
		}	
	}
	close Out;
	close IN;
}
close RE;
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

	eg: perl $Script -int list -index index-calc.result.index -out .
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-index bsa result table
	-h         Help

USAGE
        print $usage;
        exit;
}
