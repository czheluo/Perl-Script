#!/usr/bin/perl -w
use warnings;
use strict;
use GD;      # for font names
use GD::Graph::pie;
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

my $pie_labels = [ qw(Pride Envy Avarice
                      Wrath Lust Gluttony Sloth)];
my %cities = (
    'Boston' => { size => 175,
                  x => 260,
                  y => 100,
                 data => [24, 9, 18, 12, 35, 40, 19] },
    'Providence' => {
                  size => 80,
                  x => 200,
                  y => 300,
                  data => [5, 10, 60, 8, 35, 40, 19] },
    'Hartford' => {
                  size => 100,
                  x => 50,
                  y => 350,
                  data => [100, 9, 18, 2, 35, 40, 9] },
    'Worcester' => {
                  size => 75,
                  x => 70,
                  y => 200,
                  data => [2, 9, 1, 12, 3, 4, 10] },
    'P-town' => {
                  size => 50,
                  x => 475,
                  y => 140,
                  data => [2, 9, 18, 12, 35, 90, 19] },
);

my $map = GD::Image->newFromPng('map.png');

# Loop through the cities, creating a graph for each
foreach my $city (keys(%cities)) {
    my $size = $cities{$city}->{'size'};

    my $graph = new GD::Graph::pie($size,$size)
        or die "Can't create graph!";
    $graph->set( transparent    => 1,
                 suppress_angle => 360*($size<150),
                '3d'           => 1,
                 title          => $city,
    );
# Plot the graph

    my $gd = $graph->plot([ $pie_labels,
                            $cities{$city}->{'data'} ])
        or die "Can't plot graph";

    # Copy the graph onto the map at the specified coordinate

    my ($w, $h) = $graph->gd( )->getBounds( );
    $map->copy($graph->gd( ),
               $cities{$city}->{'x'},
               $cities{$city}->{'y'},
               0, 0, $w, $h);
}
# Print the map to STDOUT

print $map->png( );

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

