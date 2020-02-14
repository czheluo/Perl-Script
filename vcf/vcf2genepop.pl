#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($vcf,$group,$dir,$key);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"vcf:s"=>\$vcf,
    "group:s"=>\$group,
	"dir:s"=>\$dir,
    "key:s"=>\$key,
			) or &USAGE;
&USAGE unless ($vcf );
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:
	vcf to genepop format
	eg:
	perl $Script -vcf -group -o 

Usage:
  Options:
  -vcf	<file>	input vcf file
  -group <file> input group list
  -dir	<file>	
  -key  out file key
  -h         Help

USAGE
        print $usage;
        exit;
}
my $spid="/mnt/ilustre/users/meng.luo/Pipeline/PGDSpider.spid";
if($group){
    open SP,"$spid";
    open OUT,">$dir/PGDSpider.spid";
    while(<SP>){
        $_=~s/[\n\r]//g;
        $_=~s/VCF_PARSER_POP_FILE_QUESTION=/VCF_PARSER_POP_FILE_QUESTION=$group/g;
        $_=~s/VCF_PARSER_POP_QUESTION=/VCF_PARSER_POP_QUESTION=true/g;
        print OUT "$_\n";
        }
        close SP;
    `java -jar PGDSpider2-cli.jar -inputfile $vcf -inputformat VCF -outputfile $dir/$key.genepop -outputformat GENEPOP -spid $dir/PGDSpider.spid`;
    }else{
        `java -jar PGDSpider2-cli.jar -inputfile $vcf -inputformat VCF -outputfile $dir/$key.genepop -outputformat GENEPOP -spid /mnt/ilustre/users/nanshan.yang/Pipline/02.distance/PGDSpider.spid`;
        }

#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub ABSOLUTE_DIR
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

