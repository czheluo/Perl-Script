package Plot::QQplot;

use warnings;
use strict;

use Chart::Gnuplot;
use Math::CDF;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;

sub qqPlot
{
my($output_text, $mw, $gp_win, $gnuplot)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

my $eig='assoc';
my $size="default";
my $ci=0;

$gp_win->geometry("420x220");
$gp_win->title("Quantile-Quantile Plot");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frames=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $input_frame=$input_frames->Frame()->pack(-side=>"top", -anchor=>'w'); #input file
	$input_frame->Label(-text => "Association File")->pack(-side => "left");
	my $T1=$input_frame->Text(-height => 1, -width => 40)->pack(-side=>"left");
	my $browse_button1 = $input_frame->Button(-text => 'Browse',
												-command => sub	{
																$T1->delete('0.0', 'end');
																$input_path=$mw->getOpenFile(-filetypes=>[
																										['Association files', '.assoc'],
																										['All files', '*'],
																																				]);
																$T1->insert('end', $input_path);
																}
												)->pack(-side => "left");
	my $eig_frame=$input_frames->Frame()->pack(-side=>"top", -anchor=>'w'); #eig or assoc or other
		$eig_frame->Checkbutton(-text=>"95% CI         ", -variable=>\$ci)->pack(-side => "left", -anchor=>'w');
		$eig_frame->Label(-text=>"         P value column")->pack(-side=>'left');
		my $T99=$eig_frame->Text(-height => 1, -width => 30)->pack(-side=>"left");
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame	
	my $title_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #title frame
		$title_frame->Label(-text=>"Tile     ")->pack(-side=>'left');
		my $T2=$title_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T2->delete('0.0','end');
			$T2->insert('end','Quantile-Quantile plot');
	my $xlabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #X label frame
		$xlabel_frame->Label(-text=>"X label")->pack(-side=>'left');
		my $T3=$xlabel_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end','-log10(Expected P value)');
	my $ylabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #Y label frame
		$ylabel_frame->Label(-text=>"Y label")->pack(-side=>'left');
		my $T4=$ylabel_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T4->delete('0.0','end');
			$T4->insert('end','-log10(Observer P value)');
	my $out_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T5=$out_frame->Text(-height => 1, -width => 46)->pack(-side=>"left");
			$T5->delete('0.0','end');
			$T5->insert('end','qqPlot.png');
	my $size_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #size frame
		$size_frame->Label(-text=>"Size:")->pack(-side => "left");
		$size_frame->Radiobutton(-text=>"Default       ", -value=>'default', -variable=>\$size)->pack(-side => "left");
		$size_frame->Radiobutton(-text=>"Custom", -value=>'custom', -variable=>\$size)->pack(-side => "left");
		$size_frame->Label(-text=>"Length:")->pack(-side=>'left');
		my $T77=$size_frame->Text(-height => 1, -width => 10)->pack(-side=>"left");
		$size_frame->Label(-text=>"Height:")->pack(-side=>'left');
		my $T88=$size_frame->Text(-height => 1, -width => 10)->pack(-side=>"left");
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .assoc file\n");
															die "No .assoc file: $!\n";
															}
												$output_text->insert('end', "$inpath opened\n"); #log
												print "$inpath opened\n";
												
												my($base,$dir,$ext)=fileparse($inpath,'\..*');
												
												my $outname=$T5->get('0.0', 'end');
												$output_text->insert('end', "output: $dir$outname"); #log
												chomp $outname;
												
												if($outname=~/.png$/)
												{
												$outname="$dir$outname";
												}
												else
												{
												$outname="$dir$outname.png";
												}
												
												my $mytitle=$T2->get('0.0', 'end');
												$output_text->insert('end', "Plot Title: $mytitle"); #log
												print "Plot Title: $mytitle";
												chomp $mytitle;
												
												my $myx=$T3->get('0.0', 'end');
												$output_text->insert('end', "Plot X label: $myx"); #log
												print "Plot X label: $myx";
												chomp $myx;
												
												my $myy=$T4->get('0.0', 'end');
												$output_text->insert('end', "Plot Y label: $myy"); #log
												print "Plot Y label: $myy";
												chomp $myy;
												
												#size
												my $sizeX=0;
												my $sizeY=0;
												if($size eq "default")
												{
												$sizeX=1260;
												$sizeY=689;
												}
												else
												{
												$sizeX=$T77->get('0.0', 'end');
												$sizeY=$T88->get('0.0', 'end');
												chomp $sizeX;
												chomp $sizeY;
													if(!$sizeX || !$sizeY)
													{
													die"Please specify the Length and/or the Height\n";
													}
												}
												
												$output_text->insert('end', "Plotting...\n"); #log
												print "Plotting...\n";
											#--------------------------------------------------------------

											my $pname=$T99->get('0.0','end');
											chomp $pname;
											my $col=0;
												open(f1, $inpath);

												my $snpno=0;
												my @passo;  #p-value of association

												while(<f1>)
												{
												chomp;
													if($_=~/$pname/)
													{
													$_=~s/^\s+//;
													my @arr=split(/\s+/,$_);
														for(my $i=0; $i<=$#arr; $i++)
														{
															if($arr[$i] eq $pname)
															{
															$col=$i;
															last;
															}
														}
													}
													else
													{
													$_=~s/^\s+//;
													my @arr=split(/\s+/,$_);
														if($arr[$col]=~/[0-9]/ && $arr[$col]>0 && $arr[$col]<1)
														{
														$passo[$snpno]=$arr[$col];
														$snpno++;
														}
													}
												
												}
												close f1;

												my @p; #expected p-value 
												for(my $i=0;$i<$snpno;$i++)
												{
												$p[$i]=(($i+1)/($snpno+1));
												}

												@passo=sort{$a <=> $b}@passo; #sort
												# @p=sort{$a <=> $b}@p;

												for(my $i=0;$i<$snpno;$i++)
												{
												$p[$i]=-log($p[$i])/log(10);
												$passo[$i]=-log($passo[$i])/log(10);
												}

												# Create chart object and specify the properties of the chart
													my $chart = Chart::Gnuplot->new(
														gnuplot => $gnuplot,   # for Windows, the address of gnuplot
														terminal => 'png',     # output format
														output => $outname,     # output name
														xlabel => $myx,
														ylabel => $myy,
														title => $mytitle,
														imagesize => "$sizeX, $sizeY",
														# legend => {
															# position => "left top",  # left, right, top, bottom, outside, and below
															# align => "left"   #left right
														# }
													);

												# Create dataset object and specify the properties of the dataset
													my $dataSet1 = Chart::Gnuplot::DataSet->new(
														xdata => \@p,
														ydata => \@passo,
														style => "points",
														color => "red",
														pointsize => "0.25",
														pointtype => "3",   
														# title => "Association"
													);
													my $dataSet2 = Chart::Gnuplot::DataSet->new(
														xdata => \@p,
														ydata => \@p,
														style => "lines",
														color => "black",
														# title => "NULL line"
													);
													# 95% CI
													if($ci==1)
													{
														my @ci95; #ci
														my @ci05;
														for(my $i=0;$i<$snpno;$i++) ##ci
														{
														my $tt=$i+1;
														my $ttt=$snpno-$i;
														$ci95[$i]=Math::CDF::qbeta(0.95, $tt, $ttt);
														$ci05[$i]=Math::CDF::qbeta(0.05, $tt, $ttt);
														$ci95[$i]=-log($ci95[$i])/log(10);
														$ci05[$i]=-log($ci05[$i])/log(10);
														}
														### Create dataset object and specify the properties of the dataset
														my $dataSet3 = Chart::Gnuplot::DataSet->new(
														xdata => \@p,
														ydata => \@ci95,
														style => "lines",
														color => "blue",
														);
														my $dataSet4 = Chart::Gnuplot::DataSet->new(
														xdata => \@p,
														ydata => \@ci05,
														style => "lines",
														color => "blue",
														);
														# Plot the data set on the chart
														$chart->plot2d($dataSet1, $dataSet2, $dataSet3, $dataSet4);
													}
													else
													{
													# Plot the data set on the chart
													$chart->plot2d($dataSet1, $dataSet2);
													}
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}
1;
