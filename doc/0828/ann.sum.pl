#!/usr/bin/perl -w
use warnings;
use strict;

my $BEGIN_TIME=time();
use Getopt::Long;
my ($inputA,$inputB,$output);
#use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"inputA:s"=>\$inputA,
	"inputB:s"=>\$inputB,
	"output:s"=>\$output,
			) or &USAGE;
&USAGE unless ($output);
#######################################################################################       


open INA,$inputA;
my $firname;
#$/=">";
my $n;
my %na;
while(<INA>){
	chomp;
	next if ($_=~ /^#/); 
		$n++;
	
	my ($id,@seq)=split(/\s+/);
       $na{$n}=$id;
	   #print "$n\n";die;
     
}
close INA;
open OUT,">$output";
open INB,$inputB;
my $m;
while(<INB>){
	chomp;
	
	if ($_ =~ /^\>/){
		#print $_;
		$m++;
		my ($id,$idname) = split(/\s+/,$_,2);
		print "$idname\n";
		my @idname=split(/\s+/,$idname);
		my @name;
		for (my $i=0;$i<@idname;$i++) {
			#next if($idname[$i] !~ /\=/);
			my @ida =split(/\=/,$idname[$i]);
			push @name,$ida[1];
			print "$ida[1]";
			#
		}

		print OUT join(":",$na{$m},@name),"\n";


	}

	#my ($id,@seq)=split(/\n/);
	#print "$id\n";
	#my @idna=split(/\t/,$id);
	
	#print "$idna[0]\n";die;

 
}
close INB;
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
Usage:
  Options:
  -inputA	<file>	input  file name
  -inputB	<file>	input file name
  -output	<file>	input RESULT file name
  -h         Help

USAGE
        print $usage;
        exit;
}
