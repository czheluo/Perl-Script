#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fIn,$id,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fIn,
	"id:s"=>\$id,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fIn;
if ($fIn =~ /.gz/) {
	close In;
	open In,"zcat $fIn|";
}
open Out,">$fout";
my %sams;
while (<In>) {
	chomp;
	#next if($_ eq ""|| /^$/);
	if($_ =~ "##"){
		print Out $_,"\n";
	}elsif($_ =~ "#"){
		my($CHROM,$POS,$ID,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,$sample)=split/\t/,$_,10;
		my $n=0;
		my @samples=split/\t/,$sample;
		foreach my $sam (@samples){
			$sams{$sam}=$n;
			$n++;
		}
		#print Dumper %sams;
		open IN,$id;
		my @gene;
		while (<IN>) {
			chomp;
			my $gen=$samples[$sams{$_}];
			push @gene,join("\t",$gen);
		}
		print Out join("\t",$CHROM,$POS,$ID,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,@gene),"\n";
		close IN;
		#die;
	}else{
		my($CHROM,$POS,$ID,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,$genes)=split/\t/,$_,10;
		open IN,$id;
		my @gene=split/\t/,$genes;
		my @geness;
		while (<IN>) {
			chomp;
			my $gen=$gene[$sams{$_}];
			push @geness,join("\t",$gen);
		}
		print Out join("\t",$CHROM,$POS,$ID,$REF,$ALT,$QUAL,$FILTER,$INFO,$FORMAT,@geness),"\n";
		close IN;
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

	eg: perl $Script -int pop.recode.vcf -out id.recode.vcf -id id.list 
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
