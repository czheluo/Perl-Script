#!/usr/bin/perl -w
use warnings;
use strict;

my $BEGIN_TIME=time();
use Getopt::Long;
my ($input,$output);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"input:s"=>\$input,
	"output:s"=>\$output,
			) or &USAGE;
&USAGE unless ($input and $output);
#######################################################################################       


open OUT,">$output";
print OUT "ID\tlnL0\tlnL1\n";

my @file=glob("$input/ORTHOMCL*/*.log");
#my @fileB=glob("$input/ORTHOMCL*/*H1.log");
#print Dumper @file;
my %alllnL;
foreach  my $file(@file) {
	my $fname=basename($file);
	#print "$fname";
	my @na=split(/\./,$fname);
    my $naa=$na[0];
	#my $lnLa;
	my $lnLb;
	
	if ($fname =~ /H0/) {
		open IN,$file;
		while(<IN>){
			chomp;
			next if ($_ !~ /lnL/);
			#$lnL=$_;
			 (undef,$lnLb)=split(/=/,$_);
            $alllnL{$naa}{H0}=$lnLb;
            
			#print "$lnLb";
}
close IN;
	} else {
	open IN,$file;
		while(<IN>){
			chomp;
			next if ($_ !~ /lnL/);
			#$lnL=$_;
			 (undef,$lnLb)=split(/=/,$_);
            $alllnL{$naa}{H1}=$lnLb;
	
	}
	close IN;
	}
}

print Dumper \%alllnL; #die;

	foreach  my $key (keys %alllnL) {
		#my $value = $alllnL{$key};
		print OUT "$key\t$alllnL{$key}{H0}\t$alllnL{$key}{H1}\n";
		}

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
  -input	<file>	input dirname
  -output	<file>	input result file name
  -h         Help

USAGE
        print $usage;
        exit;
}
