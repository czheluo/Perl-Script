package Plot::ManhattanPlot;

use warnings;
use strict;

use Chart::Gnuplot;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;


sub AssocManhattanPlot
{
my($output_text, $mw, $gp_win, $gnuplot)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";
my $output_name="";
my $ooo;
my $ok_frame;

my $ci;

my $size="default";

$gp_win->geometry("420x260");
$gp_win->title("Manhattan Plot");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $inframe1=$input_frame->Frame()->pack(-side => "top");
		$inframe1->Label(-text => ".assoc File")->pack(-side => "left");
		my $T1=$inframe1->Text(-height => 1, -width => 44)->pack(-side=>"left");
		$inframe1->Button(-text => 'Browse',
							-command => sub	{
											$T1->delete('0.0', 'end');
											$input_path=$mw->getOpenFile(-filetypes=>[
																						['Association files', '.assoc'],
																						['All files', '*'],
																					]);
											$T1->insert('end', $input_path);
											}
						)->pack(-side => "left");
my $chr_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$chr_frame->Label(-text=>"Chromosome:      ")->pack(-side=>'left');
		my $T99=$chr_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
		$T99->delete('0.0','end');
		$T99->insert('end','CHR');
my $bp_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$bp_frame->Label(-text=>"Physical position:")->pack(-side=>'left');
		my $T98=$bp_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
		$T98->delete('0.0','end');
		$T98->insert('end','BP');
my $p_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$p_frame->Label(-text=>"P value:              ")->pack(-side=>'left');
		my $T97=$p_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
		$T97->delete('0.0','end');
		$T97->insert('end','P');
		
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
	my $title_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #title frame
		$title_frame->Label(-text=>"Tile     ")->pack(-side=>'left');
		my $T2=$title_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T2->delete('0.0','end');
			$T2->insert('end','Manhattan plot');
	my $ylabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #Y label frame
		$ylabel_frame->Label(-text=>"Y label")->pack(-side=>'left');
		my $T4=$ylabel_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T4->delete('0.0','end');
			$T4->insert('end','-log10(P value)');
	###size
	my $size_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #size frame
		$size_frame->Label(-text=>"Size:")->pack(-side => "left");
		$size_frame->Radiobutton(-text=>"Default       ", -value=>'default', -variable=>\$size)->pack(-side => "left");
		$size_frame->Radiobutton(-text=>"Custom", -value=>'custom', -variable=>\$size)->pack(-side => "left");
		$size_frame->Label(-text=>"Length:")->pack(-side=>'left');
		my $T77=$size_frame->Text(-height => 1, -width => 10)->pack(-side=>"left");
		$size_frame->Label(-text=>"Height:")->pack(-side=>'left');
		my $T88=$size_frame->Text(-height => 1, -width => 10)->pack(-side=>"left");
		
	my $out_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T5=$out_frame->Text(-height => 1, -width => 46)->pack(-side=>"left");
			$T5->delete('0.0','end');
			$T5->insert('end','ManhattanPlot.png');
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
												$outname="$dir$outname";
												
												my $mytitle=$T2->get('0.0', 'end');
												$output_text->insert('end', "Plot Title: $mytitle"); #log
												chomp $mytitle;
												
												# my $myx=$T3->get('0.0', 'end');
												$output_text->insert('end', "Plot X label: Chromosome\n"); #log
												# chomp $myx;
												
												my $myy=$T4->get('0.0', 'end');
												$output_text->insert('end', "Plot Y label: $myy"); #log
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
												
												###------------------------------
												$output_text->insert('end', "Reading data from: [$inpath]\n"); #log
												print "Reading data from: [$inpath]\n";
												
												my $chrname=$T99->get('0.0','end');
												chomp $chrname;
												my $chrcol=0;
												
												my $bpname=$T98->get('0.0','end');
												chomp $bpname;
												my $bpcol=0;
												
												my $pname=$T97->get('0.0','end');
												chomp $pname;
												my $pcol=0;
												
												my %allinfo;
												
												open(f1, $inpath);
												
												while(<f1>)
												{
												chomp;
													if($_=~/$chrname/)
													{
													$_=~s/^\s+//;
													my @arr=split(/\s+/,$_);
													my $pflag=0;
													my $chrflag=0;
													my $bpflag=0;
														for(my $i=0; $i<=$#arr; $i++)
														{
															if($arr[$i] eq $pname)
															{
															$pcol=$i;
															$pflag=1;
															}
															if($arr[$i] eq $chrname)
															{
															$chrcol=$i;
															$chrflag=1;
															}
															if($arr[$i] eq $bpname)
															{
															$bpcol=$i;
															$bpflag=1;
															}
														}
														###check name
														
														if($pflag==0)
														{
														die "please specify the column name of P value\n";
														}
														if($chrflag==0)
														{
														die "please specify the column name of chromosome\n";
														}
														if($bpflag==0)
														{
														die "please specify the column name of physical position\n";
														}
													}
													else
													{
													$_=~s/^\s+//;
													my @arr=split(/\s+/, $_);
														if($arr[$pcol]=~/[0-9]/ && $arr[$pcol]>0 && $arr[$pcol]<1)
														{
														$allinfo{$arr[$chrcol]}{$arr[$bpcol]}=-log($arr[$pcol])/log(10);
														}
													}
												}
												close f1;
												
												### start chr & max pos on start chr
												my $startchr=1;
												my $maxstartpos=1;
												my $minstartpos=1;
												
												my @sortchr= sort {$a <=> $b} keys %allinfo;
												$startchr=$sortchr[0];
												
												my @sortstartpos= (sort{$b <=> $a} keys %{$allinfo{$startchr}});
												$maxstartpos=$sortstartpos[0];
												$minstartpos=$sortstartpos[$#sortstartpos];
												my $minx=$minstartpos/$maxstartpos - 0.05;
												
												my %maxpos;
												foreach my $key(@sortchr)
												{
												my @sortpos= (sort{$b <=> $a} keys %{$allinfo{$key}});
												$maxpos{$key}=$sortpos[0];
												}
												
												### convert relative phy pos
												my $lastTotalLen=0;
												foreach (my $i=0; $i<=$#sortchr; $i++)
												{
													foreach my $key (keys %{$allinfo{$sortchr[$i]}})
													{
													my $tempbp=$lastTotalLen+$key/$maxstartpos;
													$allinfo{$sortchr[$i]}{$tempbp}=$allinfo{$sortchr[$i]}{$key};
													delete $allinfo{$sortchr[$i]}{$key};
													}
												$lastTotalLen+=$maxpos{$sortchr[$i]}/$maxstartpos;
												}
												
												### plot
												
												$output_text->insert('end', "Plotting...\n"); #log
												print "Plotting...\n";
												
												my $maxx=$lastTotalLen+0.05;
												
												# Create chart object and specify the properties of the chart
													my $chart = Chart::Gnuplot->new(
														gnuplot => $gnuplot,   # for Windows, the address of gnuplot
														terminal => 'png',     # output format
														output => $outname,     # output name
														#xlabel => $myx,
														ylabel => $myy,
														title => $mytitle,
														xrange => [$minx, $maxx],
														xtics => {
														labels => [-1], #since x > 0, there is no tics.
														},
														imagesize => "$sizeX, $sizeY",
														legend => {
															position => "bottom outside below",  # left, right, top, bottom, outside, and below
															align => "left",   #left right
															#order => "horizontal", #"horizontal reverse",
															# sample   => {
																		   # length   => 3,
																		   # position => "left",
																		   # spacing  => 2,
																	   # },
														}
													);
													
												# Create dataset object and specify the properties of the dataset
												my @color=("#00FFFF", "#9932CC", "#000000", "#A52A2A", "#5F9EA0", "#7FFF00", "#6495ED", "#008B8B", "#B8860B", "#006400", "#556B2F", "#FF8C00", "#E9967A", "#483D8B", "#2F4F4F", "#FF1493", "#228B22", "#FF00FF", "#FFD700", "#ADFF2F", "#4B0082", "#FFCOCB", "#FF4500");
												my ($dataSet1, $dataSet2, $dataSet3, $dataSet4, $dataSet5, $dataSet6, $dataSet7, $dataSet8, $dataSet9, $dataSet10, $dataSet11, $dataSet12, $dataSet13, $dataSet14, $dataSet15, $dataSet16, $dataSet17, $dataSet18, $dataSet19, $dataSet20, $dataSet21, $dataSet22, $dataSet23);
												# my @color;
												# for(my$i=0; $i<23; $i+=2)
												# {
												# $color[$i]="black";
												# my $j=$i+1;
												# $color[$j]="gray";
												# }
												
												my $dataindex=0;
												my @myplotdata;
												
												if(exists $maxpos{"1"})
												{
												my @chrX=keys %{$allinfo{"1"}};
												my @chrY=values %{$allinfo{"1"}};
												$dataSet1= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[0],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 1",
														);
												$myplotdata[$dataindex++]=$dataSet1;
												}
												if(exists $maxpos{"2"})
												{
												my @chrX=keys %{$allinfo{"2"}};
												my @chrY=values %{$allinfo{"2"}};
												$dataSet2= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[1],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 2",
														);
												$myplotdata[$dataindex++]=$dataSet2;
												}
												if(exists $maxpos{"3"})
												{
												my @chrX=keys %{$allinfo{"3"}};
												my @chrY=values %{$allinfo{"3"}};
												$dataSet3= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[2],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 3",
														);
												$myplotdata[$dataindex++]=$dataSet3;
												}
												if(exists $maxpos{"4"})
												{
												my @chrX=keys %{$allinfo{"4"}};
												my @chrY=values %{$allinfo{"4"}};
												$dataSet4= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[3],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 4",
														);
												$myplotdata[$dataindex++]=$dataSet4;
												}
												if(exists $maxpos{"5"})
												{
												my @chrX=keys %{$allinfo{"5"}};
												my @chrY=values %{$allinfo{"5"}};
												$dataSet5= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[4],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 5",
														);
												$myplotdata[$dataindex++]=$dataSet5;
												}
												if(exists $maxpos{"6"})
												{
												my @chrX=keys %{$allinfo{"6"}};
												my @chrY=values %{$allinfo{"6"}};
												$dataSet6= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[5],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 6",
														);
												$myplotdata[$dataindex++]=$dataSet6;
												}
												if(exists $maxpos{"7"})
												{
												my @chrX=keys %{$allinfo{"7"}};
												my @chrY=values %{$allinfo{"7"}};
												$dataSet7= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[6],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 7",
														);
												$myplotdata[$dataindex++]=$dataSet7;
												}
												if(exists $maxpos{"8"})
												{
												my @chrX=keys %{$allinfo{"8"}};
												my @chrY=values %{$allinfo{"8"}};
												$dataSet8= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[7],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 8",
														);
												$myplotdata[$dataindex++]=$dataSet8;
												}
												if(exists $maxpos{"9"})
												{
												my @chrX=keys %{$allinfo{"9"}};
												my @chrY=values %{$allinfo{"9"}};
												$dataSet9= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[8],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 9",
														);
												$myplotdata[$dataindex++]=$dataSet9;
												}
												if(exists $maxpos{"10"})
												{
												my @chrX=keys %{$allinfo{"10"}};
												my @chrY=values %{$allinfo{"10"}};
												$dataSet10= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[9],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 10",
														);
												$myplotdata[$dataindex++]=$dataSet10;
												}
												if(exists $maxpos{"11"})
												{
												my @chrX=keys %{$allinfo{"11"}};
												my @chrY=values %{$allinfo{"11"}};
												$dataSet11= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[0],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 11",
														);
												$myplotdata[$dataindex++]=$dataSet11;
												}
												if(exists $maxpos{"12"})
												{
												my @chrX=keys %{$allinfo{"12"}};
												my @chrY=values %{$allinfo{"12"}};
												$dataSet12= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[1],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 12",
														);
												$myplotdata[$dataindex++]=$dataSet12;
												}
												if(exists $maxpos{"13"})
												{
												my @chrX=keys %{$allinfo{"13"}};
												my @chrY=values %{$allinfo{"13"}};
												$dataSet13= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[2],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 13",
														);
												$myplotdata[$dataindex++]=$dataSet13;
												}
												if(exists $maxpos{"14"})
												{
												my @chrX=keys %{$allinfo{"14"}};
												my @chrY=values %{$allinfo{"14"}};
												$dataSet14= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[3],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 14",
														);
												$myplotdata[$dataindex++]=$dataSet14;
												}
												if(exists $maxpos{"15"})
												{
												my @chrX=keys %{$allinfo{"15"}};
												my @chrY=values %{$allinfo{"15"}};
												$dataSet15= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[4],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 15",
														);
												$myplotdata[$dataindex++]=$dataSet15;
												}
												if(exists $maxpos{"16"})
												{
												my @chrX=keys %{$allinfo{"16"}};
												my @chrY=values %{$allinfo{"16"}};
												$dataSet16= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[5],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 16",
														);
												$myplotdata[$dataindex++]=$dataSet16;
												}
												if(exists $maxpos{"17"})
												{
												my @chrX=keys %{$allinfo{"17"}};
												my @chrY=values %{$allinfo{"17"}};
												$dataSet17= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[6],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 17",
														);
												$myplotdata[$dataindex++]=$dataSet17;
												}
												if(exists $maxpos{"18"})
												{
												my @chrX=keys %{$allinfo{"18"}};
												my @chrY=values %{$allinfo{"18"}};
												$dataSet18= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[7],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 18",
														);
												$myplotdata[$dataindex++]=$dataSet18;
												}
												if(exists $maxpos{"19"})
												{
												my @chrX=keys %{$allinfo{"19"}};
												my @chrY=values %{$allinfo{"19"}};
												$dataSet19= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[8],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 19",
														);
												$myplotdata[$dataindex++]=$dataSet19;
												}
												if(exists $maxpos{"20"})
												{
												my @chrX=keys %{$allinfo{"20"}};
												my @chrY=values %{$allinfo{"20"}};
												$dataSet20= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[9],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 20",
														);
												$myplotdata[$dataindex++]=$dataSet20;
												}
												if(exists $maxpos{"21"})
												{
												my @chrX=keys %{$allinfo{"21"}};
												my @chrY=values %{$allinfo{"21"}};
												$dataSet21= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[0],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 21",
														);
												$myplotdata[$dataindex++]=$dataSet21;
												}
												if(exists $maxpos{"22"})
												{
												my @chrX=keys %{$allinfo{"22"}};
												my @chrY=values %{$allinfo{"22"}};
												$dataSet22= Chart::Gnuplot::DataSet->new(
														xdata => \@chrX,
														ydata => \@chrY,
														style => "points",
														color => $color[1],
														pointsize => "0.25",
														pointtype => "3",   # *
														title => "chr 22",
														);
												$myplotdata[$dataindex++]=$dataSet22;
												}
												$chart->plot2d(@myplotdata);
												
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}

1;
