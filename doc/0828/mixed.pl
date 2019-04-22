#!/usr/bin/perl -w
use warnings;
use strict;
use GD;      # for font names
use GD::Graph::Data;
use GD::Graph::mixed;
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
   
## Read in the data from a file
my $data = GD::Graph::Data->new( );
$data->read(file => 'stock_data.dat');

#print Dumper $data;

my $graph = new GD::Graph::mixed(900, 300);
$graph->set(
        title             => "Shemp Corp. stock 2002",
        types             => [qw(area area bars)],
        dclrs             => [qw(red white blue)],
        transparent       => 0,
);
# Set the attributes for the x-axis

$graph->set(
        x_label           => 'Day of Year',
        x_label_skip      => 5,
        x_labels_vertical => 1,
);

$graph->set(
        y_max_value       => ($data->get_min_max_y_all( ))[1]+25,
        y_tick_number     => 10,
        y_all_ticks       => 1,
        y_number_format   => sub { '$'.int(shift); },
);
# Set the legend

$graph->set_legend(undef, undef, 'Volume is in thousands of shares traded');
$graph->set_legend_font(gdLargeFont);
$graph->set(legend_placement => 'BL');

# Plot the data

my $gd = $graph->plot( $data );

my $logo = GD::Image->newFromPng('shempcorp.png');
my ($w, $h) = $logo->getBounds( );
$gd->copy($logo, 50, 25, 0, 0, $w, $h);

# Write the PNG
print $gd->png( );

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

