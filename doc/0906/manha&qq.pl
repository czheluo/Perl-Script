#!/usr/bin/perl -w
use warnings;
use strict;
use Plot::QQplot;
use Plot::ManhattanPlot;
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
   
my ($gp_win_plot_qq, $gp_win_plot_man, $gp_win_plot_man2);
sub qqPlot
{
if(! Exists ($gp_win_plot_qq))
	{
	$gp_win_plot_qq = $mw->Toplevel;
	}
	else
	{
	$gp_win_plot_qq->deiconify();
	$gp_win_plot_qq->raise();
	}
Plot::QQplot::qqPlot($output_text, $mw, $gp_win_plot_qq, $gnuplot);
}
###-----------------------------------
sub manPlot
{
if(! Exists ($gp_win_plot_man))
	{
	$gp_win_plot_man = $mw->Toplevel;
	}
	else
	{
	$gp_win_plot_man->deiconify();
	$gp_win_plot_man->raise();
	}
Plot::ManhattanPlot::AssocManhattanPlot($output_text, $mw, $gp_win_plot_man, $gnuplot);
}

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

