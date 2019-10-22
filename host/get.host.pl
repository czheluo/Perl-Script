#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$xls,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"xls:s"=>\$xls,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin;
my %gene;
while (<In>) {
	chomp;
	$gene{$_}=1;
}
close In;
my @files=glob("$xls/*.xls");
my %allgene;
my @allname;
foreach my $file(@files){
	my $fln=basename($file);
	my ($id,undef)=split/\./,$fln,2;
	#print $id;die;
	push @allname,join("\t",$id);
	open In,"<$xls/$fln";
	while(<In>){
		chomp;
		next if (/^seq_id /);
		my @all=split/\s+/,$_;
		#print $all[0];die;
		if(exists $gene{$all[0]}){
			push @{$allgene{$all[0]}},join("\t",$all[-5]);
		}
	}
	close In;
}

#print Dumper %allgene;die;
open Out,">$fout";
print Out "gene\t",join("\t",@allname),"\n";
foreach my $gen (sort keys %allgene){
	print Out "$gen\t",join("\t",@{$allgene{$gen}}),"\n";
}
close Out;
#open Out,">$fout/$name.map";
#open OUT,">$fout/total.$name.stat.xls";
#print OUT "Chr\tnumber of marker\tdistance\tbinname\n";
#my $n=1;
#my $bn=1;
#foreach my $chr (sort keys %chrs){
#	#my $chr=~s/chr//;
#	print Out "group\t$n\n";
#	foreach my $dis (sort keys %{$chrs{$chr}}) {
#		my $all=join("\t",@{$chrs{$chr}{$dis}});
###		if (length($all) > 1) {
#			print OUT "$n\t",join(",",@{$chrs{$chr}{$dis}}),"\t$dis","\t$chr\_bin$bn","\n";
#			$bn++;
#		}elsif(length($all) == 1){
##			print OUT "$n\t",join(",",@{$chrs{$chr}{$dis}}),"\t$dis\t",join("\t",@{$chrs{$chr}{$dis}}),"\n";
#		}
#		print Out $al[0],"\t$dis","\n";
#		#print OUT "$n\t",join("\t",@{$chrs{$chr}{$dis}}),"\t$dis","\n";
#	}
#	$n++;
#}# 
#close OUT;
#close Out;

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

	eg: perl $Script -int gene.list -xls xls/ -out case6.path.xls
	
Usage:
  Options:
	-int input file name
	-xls input xls file
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
