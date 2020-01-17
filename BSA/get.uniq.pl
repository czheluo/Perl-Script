#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$vcf,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"vcf:s"=>\$vcf,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);

open In,$fin;
my %list;
while (<In>) {
	chomp;
	$list{$_}=1;
}
close In;
open VCF,$vcf;
if ($vcf =~ /.gz/) {
	close VCF;
	open VCF,"zcat $vcf|";
}
open Out,">$fout";
while (<VCF>) {
	chomp;
	next if($_ =~ "#");
	my ($CHROM,$POS,$ID,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,$all) =split(/\s+/,$_,10);
	#print $ID;die;
	if (exists $list{$ID}) {
		my @alls=split/\s+/,$all;
		my @gt;
		for (my $i =0;$i < scalar @alls ;$i++) {
			my ($ai,undef,undef)=split/\:/,$alls[$i],3;
			push @gt,join("\t",$ai);
		}
		print Out join("\t",$ID,@gt),"\n";
	}
	
}
close VCF;
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
	-vcf input vcf files
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
