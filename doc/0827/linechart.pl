#!/usr/bin/perl -w
use warnings;
use strict;
use GD;      # for font names
use GD::Graph::lines;
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
my @data = ( [ qw(1955 1956 1957 1958
                  1959 1960 1961 1962
                  1963 1964 1965 1966
                  1967 1968 1969 1970
                  1971 1972 1973 ) ],   # timespan of data

             # thousands of people in New York
             [ 2,  5,  16.8,  18, 19, 22.6, 26, 32, 34, 39,
               43, 48, 49, 49, 54.2, 58, 68, 72, 79 ],

             # thousands of people in SF
             [ 11,  18,  29.4,  35.7, 36, 38.2, 36, 41, 45, 49,
               50, 51, 51.4, 52.6, 53.2, 54, 67, 73, 78 ],

             # thousands of people in Peoria
             [ 5,  8,  24,  32, 37, 40, 50, 55, 61, 63,
               61, 60, 65.5, 68, 71, 69, 73, 73.5, 78, 78.5],

             # thousands of people in Seattle
             [ 4.25,  8.9, 19, 21, 25, 24, 27, 29, 33, 35,
               41, 40, 45, 42, 44, 49, 51, 58, 61, 66],

             # thousands of people in Tangiers
             [ 2,  11,  9,  9.2, 9.8, 10.1, 8.2, 8.5, 9, 7,
               6, 5.5, 6.5, 5.2, 4.5, 4.2, 4, 3, 2, 1 ],

             # thousands of people in Moscow
             [ 3.5,  8,  22,  22.5, 23, 25, 25, 25, 26, 21,
               20, 19.2, 19.7, 21, 18, 23, 17, 12, 10, 5],

             # thousands of people in Istanbul
             [ 6.5,  12.8,  31.7,  34, 32, 29, 19, 20.5, 28, 35,
              34, 33, 30, 28, 25, 21, 20, 16, 11, 9]
     );

     print Dumper @data;

my $graph = new GD::Graph::lines( );
$graph->set(
        title             => "America's love affair with cheese",
        x_label           => 'Time',
        y_label           => 'People (thousands)',
        y_max_value       => 80,
        y_tick_number     => 8,
        x_all_ticks       => 1,
        y_all_ticks       => 1,
        x_label_skip      => 3,
    );
    $graph->set_legend_font(GD::gdFontTiny);
    $graph->set_legend('New York', 'San Francisco', 'Peoria',
                    'Seattle', 'Tangiers', 'Moscow', 'Istanbul');
my $gd = $graph->plot( \@data );

open OUT, ">cheese.png" or die "Couldn't open for output: $!";
binmode(OUT);
print OUT $gd->png( );
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
