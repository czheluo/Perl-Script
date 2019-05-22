#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$fa);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out:s"=>\$fout,
	"fa:s"=>\$fa,
			) or &USAGE;
&USAGE unless ($fin);
$fa=ABSOLUTE_DIR($fa);
$fin=ABSOLUTE_DIR($fin);
open In,$fin;
my %grs;
while (<In>) {
	chomp;
	my($id,$gro)=split/\s+/,$_;
	$grs{$id}=$gro;
}
close In;
my @file=glob("$fa/*.fasta");
my %allfa;
foreach my $fil(@file) {
	my $flns=basename($fil);
	my ($nam,undef)=split/\./,$flns;
	#print $nam;die;
	open IN,"<$fa/$flns";
	$/ = ">";
	while (<IN>) {
		chomp;
		next if ($_ eq "" || /^$/);
		my (undef,$seq) = split(/\n/,$_,2);
		$seq =~ s/\n//g;
		$allfa{$grs{$nam}} .=$seq;
		#push @{$allfa{$gros{$id}}},$seq;
		#print $seq;
		#print length($seq);die;
	}
	close IN;
}
open Out,">$fout/all.fa";
foreach my $names (sort keys %allfa) {
	#print length($allfa{$names}),"\n";
	print Out ">$names\n$allfa{$names}\n";
}
close Out;
open SH,">$fout/muscle.sh";
print SH "muscle -in $fout/all.fa -out $fout/out.fa";
close SH;
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

	eg: perl $Script -int group.245.list -fa ../psmc/psmc/ -out all.fa
	

Usage:
  Options:
	-int group.list
	-out ouput dir
	-fa all fasta file dir
	-h         Help

USAGE
        print $usage;
        exit;
}
