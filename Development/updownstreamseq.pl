#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
my ($in,$out,$fa,$length);        
GetOptions(
	"help|?" =>\&USAGE,
	"i:s"=>\$in,     
	"o:s"=>\$out,   
	"fa:s"=>\$fa,
	"L:s"=>\$length,
			) or &USAGE;
&USAGE unless ($in and $out and $fa);
#######################################################################################
$in = ABSOLUTE_DIR($in);
$fa = ABSOLUTE_DIR($fa);
$length||=2000;

$/ = ">";
my %fasta;
open REF,$fa;
while (<REF>){
	chomp;
	next if (/^\s*$/);
	my ($header,@seq) = split /\n/;
	my $seq = join "",@seq;
	($header,undef) = split /\s+/,$header;
	#	@seq = split //,$seq;
	#push @{ $fasta{$header} },"get";
	#push @{ $fasta{$header} },@seq;
	$fasta{$header} = $seq;
	print "$header get!\n";
}
close REF;
$/ = "\n";

open IN,$in;
my $temp = 0;
while (<IN>){
	chomp;
	next if (/^\s*$/);
	my ($insert,$start,$end,$strand,$chr,$pos,$reads) = split /\t/;
	if ($temp == 0){
		$temp ++;
		next;
	}
	$pos=~/([0-9]+)( - )([0-9]+)/;
	my $from = $1;
	my $to = $3;
	if ($from > $to){
		my $temp = $from;
		$from = $to;
		$to = $temp;
	}
	my $up = $from-$length;
	my $down = $to+$length;
	#print "up$up;from$from;to$to;down$down\n";die;
	
	open OUT,">$out/$insert\.$chr\.$up\-$from\.fa";
	print OUT ">$chr pos:$up-$from\n";
	#my $seq = join "",@{ $fasta{$chr} }[$up..$from];
	my $seq = substr($fasta{$chr},$up-1,$from-$up+1);
	print OUT "$seq\n";
	close OUT;
	
	open OUT,">$out/$insert\.$chr\.$to\-$down\.fa";
	print OUT ">$chr pos:$to-$down\n";
	#$seq = join "",@{ $fasta{$chr} }[$to..$down];
	$seq = substr($fasta{$chr},$to-1,$down-$to+1);
	print OUT "$seq\n";
	close OUT;
	
	open OUT,">$out/$insert\.$chr\.$up\-$down\.fa";
	print OUT ">$chr pos:$up-$down\n";
	#$seq = join "",@{ $fasta{$chr} }[$up..$down];
	$seq = substr($fasta{$chr},$up-1,$down-$up+1);
	print OUT "$seq\n";
	close OUT;
}
close IN;

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
		warn "Warning! just for existed file and dir \n$in";
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
Description:	
		just for aimhii result from insertresult.pl
		get seq from specific range's upstream and downstream
Usage:
  Options:
	-i	<file>	input file
	-L	<str>	(bp) upstream and downstream length, default 2000bp
	-fa	<file>	ref.fa used in aimhii.sh
	-o	<dir>	output dir 
	-h		Help

USAGE
        print $usage;
        exit;
}
