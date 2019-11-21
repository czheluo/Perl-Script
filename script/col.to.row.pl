#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$GO,$out1,$kegg);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out1:s"=>\$fout,
	"GO:s"=>\$GO,
	"KEGG:s"=>\$kegg,
	"out2:s"=>\$out1,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin;
my %list;
while (<In>) {
	chomp;
	my $u=uc($_);
	$list{$u}=1;
}
close In;

open IN,$GO;
open Out,">$fout";
print Out "term\tgene\n";
while (<IN>) {
	chomp;
	next if (/^id/);
	my ($go,undef,$desc,undef,undef,undef,undef,$type,$gene)=split/\t/,$_;
	my @allgene=split/\;/,$gene;
	#print @allgene;die;
	for (my $i=0;$i < scalar @allgene ;$i++) {
		if (exists $list{$allgene[$i]}) {
			print Out "$type\t$allgene[$i]\n";
		}else{next;}	
	}
}
close IN;
close Out;

open KO,$kegg;
open OUT,">$out1";
print OUT "term\tgene\n";
while (<KO>) {
	chomp;
	next if (/^#/);
	my ($term,undef,$ko,undef,undef,undef,undef,$gene,undef)=split/\t/,$_,9;
	my @allgene=split/\|/,$gene;
	#print @allgene;die;
	for (my $i=0;$i < scalar @allgene ;$i++) {
		if (exists $list{$allgene[$i]}) {
			print OUT "$term\t$allgene[$i]\n";
		}else{next;}	
	}
}
close KO;
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

	eg: perl $Script -int family.xls -out case3.family.xls
	
Usage:
  Options:
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out1:s"=>\$fout,
	"GO:s"=>\$GO,
	"KEGG:s"=>\$kegg,
	"out2:s"=>\$out1,

USAGE
        print $usage;
        exit;
}
