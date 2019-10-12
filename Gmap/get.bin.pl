#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$name);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out:s"=>\$fout,
	"name:s"=>\$name,
			) or &USAGE;
&USAGE unless ($fin);
open In,$fin;
my %chrs;
while (<In>) {
	chomp;
	#next if (/^Var1/);
	next if (/^group/);
	#my ($dis,$num)=split/\,/,$_;
	my ($mark,$dis)=split/\s+/,$_;
	my ($chr,$pos)=split/\_/,$mark;
	#%chrs{$dis}=join("\t",$mark);
	#push @{$chrs{$chr}{$dis}},$mark;
	push @{$chrs{$chr}{$dis}},join("\t",$mark);
}
close In;
#print Dumper %chrs;die;
open Out,">$fout/$name.map";
open OUT,">$fout/total.$name.stat.xls";
print OUT "Chr\tnumber of marker\tdistance\tbinname\n";
my $n=1;
my $bn=1;
foreach my $chr (sort keys %chrs){
	#my $chr=~s/chr//;
	print Out "group\t$n\n";
	foreach my $dis (sort keys %{$chrs{$chr}}) {
		my $all=join("\t",@{$chrs{$chr}{$dis}});
		#print length($all),"\n";
		my @al=split/\s+/,$all;
		if (length($all) > 1) {
			print OUT "$n\t",join(",",@{$chrs{$chr}{$dis}}),"\t$dis","\t$chr\_bin$bn","\n";
			$bn++;
		}elsif(length($all) == 1){
			#die;
			print OUT "$n\t",join(",",@{$chrs{$chr}{$dis}}),"\t$dis\t",join("\t",@{$chrs{$chr}{$dis}}),"\n";
		}
		print Out $al[0],"\t$dis","\n";
		#print OUT "$n\t",join("\t",@{$chrs{$chr}{$dis}}),"\t$dis","\n";
	}
	$n++;
} 
close OUT;
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

	eg: perl $Script -int total.sexAver.map -out ./
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
