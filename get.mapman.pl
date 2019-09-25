#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$result);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"r:s"=>\$result,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
$result=ABSOLUTE_DIR($result);
open In,$fin;
my %list;
while (<In>) {
	chomp;
	$list{$_}=1;
}
close In;

my %res;
my @names;
my @files=glob("$result/*.xls");
open Out,">$fout";
foreach my $file (@files) {
	my $fln=basename($file);
	my ($name,undef)=split/\./,$fln,2;
	push @names,join("\t",$name);
	open IN,"<$result/$fln";
	while (<IN>) {
		chomp;
		next if (/^seq_id/);
		my ($id,$all)=split/\s+/,$_,2;
		my @alls=split/\s+/,$all;
		#print Dumper $alls[14];die;
		if (exists $list{$id}) {
			#$res{$id}=join("\t",$alls[14]);
			push @{ $res{$id} },$alls[14];
		}
	}
	close IN;

}
print Out join("\t","	",join("\t",@names)),"\n";
foreach my $key (sort keys %res) {
	print Out join("\t",$key,join("\t",@{$res{$key}})),"\n";
}

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

	eg: perl $Script -int list -r case6 -out case6.mapman.txt
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
