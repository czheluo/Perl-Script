#!/usr/bin/perl -w
use warnings;
use strict;
use Algorithm::KMeans;
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
#&USAGE unless ($input and $output);
#######################################################################################       

my $datafile = "mydatafile.csv";
 
my $mask = "N0111";
 
my $clusterer = Algorithm::KMeans->new( datafile        => $datafile,
                                        mask            => $mask,
                                        K               => 3,
                                        cluster_seeding => 'random',
                                        terminal_output => 1,
                                        write_clusters_to_files => 1,
                                      );
 
my $clusterer = Algorithm::KMeans->new( datafile        => $datafile,
                                        mask            => $mask,
                                        K               => 3,
                                        cluster_seeding => 'random',
                                        use_mahalanobis_metric => 1,
                                        terminal_output => 1,
                                        write_clusters_to_files => 1,
                                      );

 
my $clusterer = Algorithm::KMeans->new( datafile => $datafile,
                                        mask     => $mask,
                                        K        => 3,
                                        cluster_seeding => 'smart',    # or 'random'
                                        terminal_output => 1,
                                        do_variance_normalization => 1,
                                        write_clusters_to_files => 1,
                                      );
 

my $clusterer = Algorithm::KMeans->new( datafile => $datafile,
                                        mask     => $mask,
                                        K        => 0,
                                        cluster_seeding => 'random',    # or 'smart'
                                        terminal_output => 1,
                                        write_clusters_to_files => 1,
                                      );
 

my $clusterer = Algorithm::KMeans->new( datafile => $datafile,
                                        mask     => "N111",
                                        Kmin     => 3,
                                        Kmax     => 10,
                                        cluster_seeding => 'random',    # or 'smart'
                                        terminal_output => 1,
                                        write_clusters_to_files => 1,
                                      );
 
$clusterer->read_data_from_file();
$clusterer->kmeans();
 
$clusterer->read_data_from_file();
my ($clusters_hash, $cluster_centers_hash) = $clusterer->kmeans();
 
# You can subsequently access the clusters directly in your own code, as in:
 
foreach my $cluster_id (sort keys %{$clusters_hash}) {
    print "\n$cluster_id   =>   @{$clusters_hash->{$cluster_id}}\n";
}
foreach my $cluster_id (sort keys %{$cluster_centers_hash}) {
    print "\n$cluster_id   =>   @{$cluster_centers_hash->{$cluster_id}}\n";
}
 
my $visualization_mask = "111";
$clusterer->visualize_clusters($visualization_mask);
 
my $parameter_file = "param.txt";
my $out_datafile = "mydatafile.dat";
Algorithm::KMeans->cluster_data_generator(
                        input_parameter_file => $parameter_file,
                        output_datafile => $out_datafile,
                        number_data_points_per_cluster => $N );

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
