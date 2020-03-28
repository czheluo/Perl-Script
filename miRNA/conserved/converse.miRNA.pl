#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"fa:s"=>\$fin,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
$fin=ABSOLUTE_DIR($fin);
$fout=ABSOLUTE_DIR($fout);

open SH,">$fout/converse.sh";
print SH " blastn -query $fin -db /mnt/ilustre/centos7users/meng.luo/project/RNA/miRNA/demo/TarHunter/database/hairpin -evalue 1e-5 -num_threads 8  -outfmt 7 -out $fin.table\n";
print SH " blastn -task blastn-short -query $fin -db /mnt/ilustre/centos7users/meng.luo/project/RNA/miRNA/demo/TarHunter/database/hairpin -evalue 1e-5 -num_threads 8  -outfmt 7 -out $fin.table\n";
print SH " blastn -query $fin -db /mnt/ilustre/centos7users/meng.luo/project/RNA/miRNA/demo/TarHunter/database/mature -evalue 1e-5 -num_threads 8  -outfmt 7 -out $fin.table\n";
print SH " blastn -task blastn-short -query $fin -db /mnt/ilustre/centos7users/meng.luo/project/RNA/miRNA/demo/TarHunter/database/mature -evalue 1e-5 -num_threads 8  -outfmt 7 -out $fin.table\n";
close SH;
my $job="qsub-slurm.pl --Resource mem=5G  --CPU 8 --Maxjob 20 --Queue $fout/converse.sh\n";
`$job`;
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

	eg: perl -int filename -out filename 
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
