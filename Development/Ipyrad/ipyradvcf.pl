#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
my ($in,$out);
GetOptions(
	"help|?" =>\&USAGE,
	"in:s"=>\$in,
	"out:s"=>\$out,
			) or &USAGE;
&USAGE unless ($in and $out);
#######################################################################################
$in = &ABSOLUTE_DIR($in);
open IN,$in;
open OUT,">$out";
my $Format = 'GT:DP:AD';
while (<IN>){
	chomp;
	next if (/^\s*$/);
	
	#print header line (start with #)
	if (/^#/){
		if (/ID=CATG/){
			print OUT '##FORMAT=<ID=AD,Number=.,Type=Integer,Description="Allelic depths for the ref and alt alleles in the order listed">',"\n";
		}else{
			print OUT "$_\n";
		}
		next;
	}
	
	my ($chr,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@samples) = split /\t/;
	
	my @formats = split /:/,$format;
	my ($GTmark,$DPmark,$CATGmark);
	for(my $i = 0;$i < scalar @formats;$i++){
		if ($formats[$i]=~/GT/){
			$GTmark = $i;
		}elsif($formats[$i]=~/DP/){
			$DPmark = $i;
		}elsif($formats[$i]=~/CATG/){
			$CATGmark = $i;
		}
	}
	
	my @sampleinfo; 
	foreach my $each (@samples){
		my %list;
		my @temp = split /:/,$each;
		($list{C},$list{A},$list{T},$list{G}) = split /\,/,$temp[$CATGmark];
		my ($AD1,@AD2);
		$AD1 = $list{$ref};
		if ($alt=~/\,/){
			foreach my $i(split /\,/,$alt){
				push @AD2,$list{$i};
			}
		}else{
			push @AD2,$list{$alt};
		}
		my $AD2 = join(",",@AD2);
		my ($GT1,$GT2) = split /\//,$temp[$GTmark];
		if($GT1 eq '.' && $GT2 eq '.'){
			#don't change
		}elsif($GT1 > $GT2) {
			my $change = $GT1;
			$GT1 = $GT2;
			$GT2 = $change;
			$temp[$GTmark] = join("/",$GT1,$GT2);
		}
		push @sampleinfo,"$temp[$GTmark]:$temp[$DPmark]:$AD1,$AD2";
	}
	print OUT join("\t",$chr,$pos,$id,$ref,$alt,$qual,$filter,$info,$Format,join("\t",@sampleinfo)),"\n";
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
		warn "Warning! just for existed file and dir.\n$in";
		exit;
	}
	chdir $cur_dir;
	return $return;
}

sub USAGE {           #5
        my $usage=<<"USAGE";
Contact:	meng.luo\@majorbio.com
Version:	$version
Script:		$Script
Description:	transform ipyrad_vcf to normal_vcf
		(FORMAT GT:DP:AD)
Usage:
  Options:
  -in		<file>	input raw vcf file 
  -out		<file>	output new vcf file 
  -h		Help

USAGE
        print $usage;
        exit;
}
