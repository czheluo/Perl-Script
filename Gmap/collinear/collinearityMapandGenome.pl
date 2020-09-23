#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $BEGIN_TIME=time();
my $version="1.0.0";
#######################################################################################

# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($R_map,$C_map,$All,$Key,$fOut);
GetOptions(
				"help|?" =>\&USAGE,
				"r:s"=>\$R_map,
				"c:s"=>\$C_map,
				"k:s"=>\$Key,
				"o:s"=>\$fOut,
				"All"=>\$All,
				) or &USAGE;
&USAGE unless (($R_map and $C_map and $Key)||$All);
if ($All) {
	my @files=glob("*.map");
	if (!-d "LG") {
		mkdir "LG";
	}
	my $dir=`pwd`;
	chomp $dir;
	foreach my $key1 (@files) {
		my $name=(split(/\./,$key1))[0];
		my $read;
		my %marker_sexAver;
		my %marker_Chro;
		my $max_sexAver=0;
		my $max_Chro=0;
		open In,"$name.map";
			while ($read =<In>) {
				s/\r//g;
				chomp $read;
				next if ($read eq "" || $read =~ /^$/ || $read =~ /^;/ );
				my ($markerID,$posi,undef)=split(/\s+/,$read);
				$marker_sexAver{$markerID}=$posi;
				if ($max_sexAver < $posi) {
					$max_sexAver=$posi;
				}
			}
		close In;
		open In,"$name.posi";
			while ($read =<In>) {
				chomp $read;
				next if ($read eq "" || $read =~ /^$/);
				my ($markerID,$posi,undef)=split(/\s+/,$read);
				$posi=(split(/\,/,$posi))[1];
				next if (!exists $marker_sexAver{$markerID});
				$marker_Chro{$markerID}=$posi/1000;
				if ($max_Chro < $marker_Chro{$markerID}) {
					$max_Chro=$marker_Chro{$markerID};
				}
			}
		close In;
		my $Max=($max_Chro > $max_sexAver)?$max_Chro:$max_sexAver;
		my $Sum_sexAver=scalar keys %marker_sexAver;
		my $Sum_Chro=scalar keys %marker_Chro;
	###########################################################################################
	my $LeftMargin=50;
	my $RightMargin=50;
	my $TopMargin=100;
	my $BottomMargin=300;

	my $LineWidth=2;
	my $LineColor="#6B8E23";

	my $TextColor="black";
	my $TextLineHeight=50;
	my $TilteSize="50";

	my $Space=500;
	my $ScaleCrossLine=3000;
	my $rulor_Chro=$ScaleCrossLine/$max_Chro;
	my $rulor_SexAver=$ScaleCrossLine/$max_sexAver;
	my $ChroWidth=100;

	my $MarkerTxtSpace=70;
	my $MarkerLineSpace=20;
	my $Marker_LineSpace=40;

	############################################################################################
	my $ChroSpace=$ChroWidth*2+$ScaleCrossLine;
	my $PaperHeight=$TopMargin+$BottomMargin+$ScaleCrossLine;
	my $PaperWidth=$LeftMargin+$RightMargin+$Space*6+$ChroWidth*4;
	print "Draw $name.svg\t............................";
	open (SVG,">","LG/$name.svg") or die $!;
	print SVG &svg_paper($PaperWidth,$PaperHeight),"\n";
	print SVG &svg_txt($PaperWidth/2,$TopMargin,$TilteSize,$TextColor,"$name",1);
	#print SVG &svg_txt($LeftMargin+$ChroWidth/2+$Space*2,$TopMargin+50,40,$TextColor,"Chrosome",1);
	print SVG &svg_txt($LeftMargin+$ChroWidth/2+$Space*2,$TopMargin+50,40,$TextColor,"Chr",1);
	#print SVG &svg_txt($LeftMargin+$ChroWidth/2+$Space*4,$TopMargin+50,40,$TextColor,"sexAver",1);
	print SVG &svg_txt($LeftMargin+$ChroWidth/2+$Space*4,$TopMargin+50,40,$TextColor,"Map",1);
	my $y=$TopMargin+100;
	print SVG &svg_linear("royalblue","skyblue","physical");
	print SVG &svg_circle($LeftMargin+$Space*2+$ChroWidth/2,$y+$ChroWidth/2,$ChroWidth/2,"black","physical");
	print SVG &svg_circle($LeftMargin+$Space*2+$ChroWidth/2,$y+$ChroWidth/2+$max_Chro*$rulor_Chro,$ChroWidth/2,"black","physical");
	print SVG &svg_rect($LeftMargin+$Space*2,$y+$ChroWidth/2,$ChroWidth,$max_Chro*$rulor_Chro,"black","physical");
	print SVG &svg_linear("#999900","rgb(247,251,209)","recombinant");
	print SVG &svg_circle($LeftMargin+$ChroWidth/2+$Space*4,$y+$ChroWidth/2,$ChroWidth/2,"black","recombinant");
	print SVG &svg_circle($LeftMargin+$ChroWidth/2+$Space*4,$y+$ChroWidth/2+$max_sexAver*$rulor_SexAver,$ChroWidth/2,"black","recombinant"); 
	print SVG &svg_rect($LeftMargin+$Space*4,$y+$ChroWidth/2,$ChroWidth,$max_sexAver*$rulor_SexAver,"black","recombinant");
    my $font_depth=$ScaleCrossLine/$Sum_sexAver;
	my $n=0;
	my @Marker_sexAver=sort {$marker_sexAver{$a}<=>$marker_sexAver{$b}} keys %marker_sexAver;
	my @Marker_Chro=sort {$marker_Chro{$a}<=>$marker_Chro{$b}} keys %marker_Chro;
	my $test=Order(\@Marker_Chro,\@Marker_sexAver);
	my %marker;
	if ($test == 2 ) {
		for (my $i=0;$i<@Marker_sexAver;$i++) {
			if (!defined $marker_sexAver{$Marker_sexAver[@Marker_sexAver-$i-1]} ) {
				print @Marker_sexAver-$i-1;
				die;
			}
			$marker{$Marker_sexAver[$i]}=$marker_sexAver{$Marker_sexAver[@Marker_sexAver-$i-1]};
		}
	}else{
		%marker=%marker_sexAver;
	}
	foreach my $key (sort {$marker{$a}<=>$marker{$b}} keys %marker) {
        next if (!exists $marker{$key});
        my $line="$key($marker{$key}cM)";
        print SVG &svg_txt($LeftMargin+$Space*5+10,$y+$ChroWidth/2+$font_depth*$n+15/2,20,$TextColor,$line);
        print SVG &svg_line($LeftMargin+$Space*4-$ChroWidth/2,$y+$ChroWidth/2+$marker{$key}*$rulor_SexAver,$LeftMargin+$Space*4+$ChroWidth/2*3,$y+$ChroWidth/2+$marker{$key}*$rulor_SexAver,$LineColor,$LineWidth);
        print SVG &svg_line($LeftMargin+$Space*5,$y+$ChroWidth/2+$font_depth*$n+15/2,$LeftMargin+$Space*4+$ChroWidth/2*3,$y+$ChroWidth/2+$marker{$key}*$rulor_SexAver,$LineColor,$LineWidth);
        $n++;
    }
    $font_depth=$ScaleCrossLine/$Sum_Chro;
	$n=0;
	foreach my $key (sort {$marker_Chro{$a}<=>$marker_Chro{$b}} keys %marker_Chro) {
        next if (!exists $marker_Chro{$key});
        my $line="$key($marker_Chro{$key}kb)";
        print SVG &svg_txt($LeftMargin+$Space*1,$y+$ChroWidth/2+$font_depth*$n+15/2,20,$TextColor,$line,2);
        print SVG &svg_line($LeftMargin+$Space*2-$ChroWidth/2,$y+$ChroWidth/2+$marker_Chro{$key}*$rulor_Chro,$LeftMargin+$Space*2+$ChroWidth/2*3,$y+$ChroWidth/2+$marker_Chro{$key}*$rulor_Chro,$LineColor,$LineWidth);
        print SVG &svg_line($LeftMargin+$Space*1,$y+$ChroWidth/2+$font_depth*$n+15/2,$LeftMargin+$Space*2-$ChroWidth/2,$y+$ChroWidth/2+$marker_Chro{$key}*$rulor_Chro,$LineColor,$LineWidth);
        $n++;
    }
	foreach my $key (keys %marker_Chro) {
		next if (!exists $marker_sexAver{$key});
		print SVG &svg_line($LeftMargin+$Space*2+$ChroWidth/2*3,$y+$ChroWidth/2+$marker_Chro{$key}*$rulor_Chro,$LeftMargin+$Space*4-$ChroWidth/2,$y+$ChroWidth/2+$marker{$key}*$rulor_SexAver,$LineColor,$LineWidth);
	}
	print SVG &svg_end();
	close (SVG);
		chdir "LG";
	#	`/share/nas2/genome/bmksoft/tool/svg2xxx/v1.0/svg2xxx -t png -w $PaperWidth -h $PaperHeight`;
		print "Done!\n";
		chdir $dir;
	}
}else{
	my $read;
	my %marker_sexAver;
	my %marker_Chro;
	my $max_sexAver=0;
	my $max_Chro=0;
	if (!-d "$fOut") {
		mkdir "$fOut";
	}
	open In,$R_map || die $!;
		my $k=0;
		while ($read =<In>) {
			$read=~s/\r//g;
			chomp $read;
			next if ($read eq "" || $read =~ /^$/ || $read =~ /nloc/ || $read =~ /group/ || $read =~/^;/);
			my ($markerID,$posi)=split(/\s+/,$read);
			if ($posi<0) {
				if ($k ==0) {
					$k=$posi;
				}else{
					$k=$posi if ($posi < $k);
				}
			}
			$marker_sexAver{$markerID}=$posi+abs($k) if ($k != 0);
			$marker_sexAver{$markerID}=$posi;
			if ($max_sexAver < $posi) {
				$max_sexAver=$posi;
			}
		}
	close In;
	open In,$C_map || die $!;
		while ($read =<In>) {
			chomp $read;
			next if ($read eq "" || $read =~ /^$/ || $read =~ /^group/);
			my ($markerID,$chr,$posi,undef)=split(/\s+/,$read);
			next if (!exists $marker_sexAver{$markerID});
			$marker_Chro{$markerID}=$posi/1000;
			if ($max_Chro < $marker_Chro{$markerID}) {
				$max_Chro=$marker_Chro{$markerID};
			}
		}
	close In;
	my $Max=($max_Chro > $max_sexAver)?$max_Chro:$max_sexAver;
	my $Sum_sexAver=scalar keys %marker_sexAver;
	my $Sum_Chro=scalar keys %marker_Chro;
###########################################################################################
	my $LeftMargin=50;
	my $RightMargin=50;
	my $TopMargin=100;
	my $BottomMargin=300;

	my $LineWidth=2;
	my $LineColor="#6B8E23";

	my $TextColor="black";
	my $TextLineHeight=50;
	my $TilteSize="50";

	my $Space=500;
	my $ScaleCrossLine=3000;
	my $rulor_Chro=$ScaleCrossLine/$max_Chro;
	my $rulor_SexAver=$ScaleCrossLine/$max_sexAver;
	my $ChroWidth=100;

	my $MarkerTxtSpace=70;
	my $MarkerLineSpace=20;
	my $Marker_LineSpace=40;

############################################################################################
	my $ChroSpace=$ChroWidth*2+$ScaleCrossLine;
	my $PaperHeight=$TopMargin+$BottomMargin+$ScaleCrossLine;
	my $PaperWidth=$LeftMargin+$RightMargin+$Space*6+$ChroWidth*4;
	open (SVG,">","$fOut/$Key.svg") or die $!;
	print SVG &svg_paper($PaperWidth,$PaperHeight),"\n";
	print SVG &svg_txt($PaperWidth/2,$TopMargin,$TilteSize,$TextColor,"$Key",1);
#	print SVG &svg_txt($LeftMargin+$ChroWidth/2+$Space*2,$TopMargin+50,40,$TextColor,"Chrosome",1);
#	print SVG &svg_txt($LeftMargin+$ChroWidth/2+$Space*4,$TopMargin+50,40,$TextColor,"sexAver",1);
	print SVG &svg_txt($LeftMargin+$ChroWidth/2+$Space*2,$TopMargin+50,40,$TextColor,"Chr",1);
	print SVG &svg_txt($LeftMargin+$ChroWidth/2+$Space*4,$TopMargin+50,40,$TextColor,"Map",1);
	my $y=$TopMargin+100;
	print SVG &svg_linear("royalblue","skyblue","physical");
	print SVG &svg_circle($LeftMargin+$Space*2+$ChroWidth/2,$y+$ChroWidth/2,$ChroWidth/2,"black","physical");
	print SVG &svg_circle($LeftMargin+$Space*2+$ChroWidth/2,$y+$ChroWidth/2+$max_Chro*$rulor_Chro,$ChroWidth/2,"black","physical");
	print SVG &svg_rect($LeftMargin+$Space*2,$y+$ChroWidth/2,$ChroWidth,$max_Chro*$rulor_Chro,"black","physical");
	print SVG &svg_linear("#999900","rgb(247,251,209)","recombinant");
	print SVG &svg_circle($LeftMargin+$ChroWidth/2+$Space*4,$y+$ChroWidth/2,$ChroWidth/2,"black","recombinant");
	print SVG &svg_circle($LeftMargin+$ChroWidth/2+$Space*4,$y+$ChroWidth/2+$max_sexAver*$rulor_SexAver,$ChroWidth/2,"black","recombinant"); 
	print SVG &svg_rect($LeftMargin+$Space*4,$y+$ChroWidth/2,$ChroWidth,$max_sexAver*$rulor_SexAver,"black","recombinant");
    my $font_depth=$ScaleCrossLine/$Sum_sexAver;
	my $n=0;
	my @Marker_sexAver=sort {$marker_sexAver{$a}<=>$marker_sexAver{$b}} keys %marker_sexAver;
	my @Marker_Chro=sort {$marker_Chro{$a}<=>$marker_Chro{$b}} keys %marker_Chro;
	my $test=Order(\@Marker_Chro,\@Marker_sexAver);
	my %marker;
	if ($test == 2 ) {
		for (my $i=0;$i<@Marker_sexAver;$i++) {
			if (!defined $marker_sexAver{$Marker_sexAver[@Marker_sexAver-$i-1]} ) {
				print @Marker_sexAver-$i-1;
				die;
			}
			$marker{$Marker_sexAver[$i]}=$marker_sexAver{$Marker_sexAver[@Marker_sexAver-$i-1]};
		}
	}else{
		%marker=%marker_sexAver;
	}
	foreach my $key (sort {$marker{$a}<=>$marker{$b}} keys %marker) {
        next if (!exists $marker{$key});
        my $line="$key($marker{$key}cM)";
        print SVG &svg_txt($LeftMargin+$Space*5+10,$y+$ChroWidth/2+$font_depth*$n+15/2,20,$TextColor,$line);
        print SVG &svg_line($LeftMargin+$Space*4-$ChroWidth/2,$y+$ChroWidth/2+$marker{$key}*$rulor_SexAver,$LeftMargin+$Space*4+$ChroWidth/2*3,$y+$ChroWidth/2+$marker{$key}*$rulor_SexAver,$LineColor,$LineWidth);
        print SVG &svg_line($LeftMargin+$Space*5,$y+$ChroWidth/2+$font_depth*$n+15/2,$LeftMargin+$Space*4+$ChroWidth/2*3,$y+$ChroWidth/2+$marker{$key}*$rulor_SexAver,$LineColor,$LineWidth);
        $n++;
    }
    $font_depth=$ScaleCrossLine/$Sum_Chro;
	$n=0;
	foreach my $key (sort {$marker_Chro{$a}<=>$marker_Chro{$b}} keys %marker_Chro) {
        next if (!exists $marker_Chro{$key});
        my $line="$key($marker_Chro{$key}kb)";
        print SVG &svg_txt($LeftMargin+$Space*1,$y+$ChroWidth/2+$font_depth*$n+15/2,20,$TextColor,$line,2);
        print SVG &svg_line($LeftMargin+$Space*2-$ChroWidth/2,$y+$ChroWidth/2+$marker_Chro{$key}*$rulor_Chro,$LeftMargin+$Space*2+$ChroWidth/2*3,$y+$ChroWidth/2+$marker_Chro{$key}*$rulor_Chro,$LineColor,$LineWidth);
        print SVG &svg_line($LeftMargin+$Space*1,$y+$ChroWidth/2+$font_depth*$n+15/2,$LeftMargin+$Space*2-$ChroWidth/2,$y+$ChroWidth/2+$marker_Chro{$key}*$rulor_Chro,$LineColor,$LineWidth);
        $n++;
    }
	foreach my $key (keys %marker_Chro) {
		next if (!exists $marker_sexAver{$key});
		print SVG &svg_line($LeftMargin+$Space*2+$ChroWidth/2*3,$y+$ChroWidth/2+$marker_Chro{$key}*$rulor_Chro,$LeftMargin+$Space*4-$ChroWidth/2,$y+$ChroWidth/2+$marker{$key}*$rulor_SexAver,$LineColor,$LineWidth);
	}
	print SVG &svg_end();
	close (SVG);

	chdir "$fOut";
	`convert $Key.svg  $Key.png`;
	 `convert $Key.svg $Key.pdf`;#-w $PaperWidth -h $PaperHeight`;
}

#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################

# ------------------------------------------------------------------
# sub function
# ------------------------------------------------------------------
sub svg_paper (){#&svg_paper(width,height,[color])
	my $svg_drawer = "litc"."@"."biomarker\.com\.cn";
	chomp $svg_drawer;
	my @svg_x=@_;
	my $line="";
	$line.="<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>\n";
	$line.="<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 20001102//EN\" \"http://www.w3.org/TR/2000/CR-SVG-20001102/DTD/svg-20001102.dtd\">\n\n";
	$line.="<svg width=\"$svg_x[0]\" height=\"$svg_x[1]\">\n";
	$line.="<Drawer>$svg_drawer</Drawer>\n";
	$line.="<Date>".(localtime())."</Date>\n";
	if (defined $svg_x[2]) {
		$line.="<rect x=\"0\" y=\"0\" width=\"$svg_x[0]\" height=\"$svg_x[1]\" fill=\"$svg_x[2]\"/>\n";
	}
	return $line;
}
sub svg_end (){#
	return "</svg>\n";
}
sub svg_txt (){#&svg_txt(x,y,size,color,text,[vertical,0/1/2/3]);
	my @svg_x=@_;
	if (!defined $svg_x[6]) {
		$svg_x[6]=0;
	}
	my $svg_matrix='';
	if ($svg_x[6]==0) {
		$svg_matrix="1 0 0 1";
	}
	if ($svg_x[6]==1) {
		$svg_matrix="0 1 -1 0";
	}
	if ($svg_x[6]==2) {
		$svg_matrix="-1 0 0 -1";
	}
	if ($svg_x[6]==3) {
		$svg_matrix="0 -1 1 0";
	}
    if (!defined $svg_x[5] || $svg_x[5] == 0) {
	    my $line="<text fill=\"$svg_x[3]\"  transform=\"matrix($svg_matrix $svg_x[0] $svg_x[1])\" font-family=\"ArialNarrow-Bold\" font-size=\"$svg_x[2]\">$svg_x[4]</text>\n";
	    return $line;
    }else{
        my  $anchor="";
        if ($svg_x[5]==1) {
            $anchor="middle";
        }
        if ($svg_x[5]==2) {
            $anchor="end";
        }
    	my $line="<text fill=\"$svg_x[3]\" text-anchor=\"$anchor\" transform=\"matrix($svg_matrix $svg_x[0] $svg_x[1])\" font-family=\"ArialNarrow-Bold\" font-size=\"$svg_x[2]\">$svg_x[4]</text>\n";
	    return $line;
   }
}
sub svg_line (){#&svg_line(x1,y1,x2,y2,color,width,[opacity])
	my @svg_x=@_;
	my $line="<line fill=\"$svg_x[4]\" stroke=\"$svg_x[4]\" stroke-width=\"$svg_x[5]\" x1=\"$svg_x[0]\" y1=\"$svg_x[1]\" x2=\"$svg_x[2]\" y2=\"$svg_x[3]\"/>\n";
	if (defined $svg_x[6]) {
		$line="<line fill=\"$svg_x[4]\" stroke=\"$svg_x[4]\" stroke-width=\"$svg_x[5]\" opacity=\"$svg_x[6]\" x1=\"$svg_x[0]\" y1=\"$svg_x[1]\" x2=\"$svg_x[2]\" y2=\"$svg_x[3]\"/>\n";
	}
	return $line;
}
sub svg_polyline (){#colorfill,colorstroke,width,\@point
	my @svg_x=@_;
	my $svg_color=shift(@svg_x);
	my $svg_color2=shift(@svg_x);
	my $svg_width=shift(@svg_x);
	my $svg_points=join(" ",@{$svg_x[-1]});
	my $line="<polyline fill=\"$svg_color\" stroke=\"$svg_color2\" stroke-width=\"$svg_width\" points=\"$svg_points\"/>\n";

	#print "$line\n";
	return $line;

	#<polyline points="0,0 0,20 20,20 20,40 40,40 40,60" style="fill:white;stroke:red;stroke-width:2"/>
}
sub svg_rect () {#&svg_rect(id,x,y,width,height,color,[opacity])
	my @svg_x=@_;
	if (!defined $svg_x[6]) {
		$svg_x[6]=1;
	}
	my $line="<rect style=\"fill:url(#$svg_x[5])\" x=\"$svg_x[0]\" y=\"$svg_x[1]\" width=\"$svg_x[2]\" height=\"$svg_x[3]\" fill=\"$svg_x[4]\" opacity=\"$svg_x[6]\"/>\n";
	return $line;
}
sub svg_polygon () {#colorfill,colorstroke,coloropacity,point1,point2,...
	my @svg_x=@_;
	my $svg_color=shift(@svg_x);
	my $svg_color2=shift(@svg_x);
	my $svg_trans=shift(@svg_x);
	my $svg_points=join(" ",@svg_x);
	my $line="<polygon fill=\"$svg_color\" stroke=\"$svg_color2\" opacity=\"$svg_trans\" points=\"$svg_points\"/>\n";
	return $line;
}
sub svg_ellipse () {#&svg_ellipse(cx,cy,rx,ry,colorfill,colorstroke,width,[coloropacity])
	my @svg_x=@_;
	my $line= "<ellipse cx=\"$svg_x[0]\" cy=\"$svg_x[1]\" rx=\"$svg_x[2]\" ry=\"$svg_x[3]\" fill=\"$svg_x[4]\" stroke=\"$svg_x[5]\" stroke-width=\"$svg_x[6]\"/>\n";
	if (defined $svg_x[7]) {
		$line="<ellipse cx=\"$svg_x[0]\" cy=\"$svg_x[1]\" rx=\"$svg_x[2]\" ry=\"$svg_x[3]\" fill=\"$svg_x[4]\" stroke=\"$svg_x[5]\" stroke-width=\"$svg_x[6]\" opacity=\"$svg_x[7]\"/>\n";
	}
	return $line;
}
sub svg_circle () {#&svg_circle(cx,cy,r,color)
	my @svg_x=@_;
	my $line="<circle style=\"fill:url(#$svg_x[-1])\" cx=\"$svg_x[0]\" cy=\"$svg_x[1]\" r=\"$svg_x[2]\" stroke=\"$svg_x[3]\" stroke-width=\"0\" fill=\"$svg_x[3]\"/>";
	return $line;
}
sub svg_circle1 () {#&svg_circle(cx,cy,r,color)
	my @svg_x=@_;
	my $line="<circle cx=\"$svg_x[0]\" cy=\"$svg_x[1]\" r=\"$svg_x[2]\" stroke=\"$svg_x[3]\" stroke-width=\"0\" fill=\"$svg_x[3]\"/>";
	return $line;
}
sub svg_path () {#colorfill,colorstroke,strokewidth,coloropacity,$path
	my @svg_x=@_;
	my $svg_color=shift(@svg_x);
	my $svg_color2=shift(@svg_x);
	my $width=shift(@svg_x);
	my $svg_trans=shift(@svg_x);
	my $svg_path=shift(@svg_x);
	my $line="<path d= \"$svg_path\" fill=\"$svg_color\" stroke=\"$svg_color2\" stroke-width=\"$width\" opacity=\"$svg_trans\"/>\n";
	return $line;
}
sub svg_linear (){#startcolor #endcolor,
    my @svg_x=@_;
    my $svg_color1=shift(@svg_x);
    my $svg_color2=shift(@svg_x);
    my $line="<defs>\n<linearGradient id=\"$svg_x[0]\" x1=\"0%\" y1=\"0%\" x2=\"100%\" y2=\"0%\"> \n<stop offset=\"0%\" style=\"stop-color:$svg_color1;stop-opacity:1\"/>\n<stop offset=\"50%\" style=\"stop-color:$svg_color2;stop-opacity:2\"/>\n<stop offset=\"100%\" style=\"stop-color:$svg_color1;stop-opacity:1\"/>\n</linearGradient>\n</defs>";
    return $line
}
sub Order{
	my ($marker_1,$marker_2)=@_;
	my $match1=0;
	for (my $i=0;$i<@$marker_1;$i++) {
		if ($$marker_1[$i] eq $$marker_2[$i]) {
			$match1++;
		}
	}
	my @marker_3=reverse @$marker_2;
	my $match2=0;
	for (my $i=0;$i<@$marker_1;$i++) {
		if ($$marker_1[$i] eq $marker_3[$i]) {
			$match2++;
		}
	}
	if ($match2 >$match1) {
		return 2;
	}else{
		return 1;
	}
}
sub USAGE {#
	my $usage=<<"USAGE";
Program:$Script
Version:$version
Contact:Huang Long <huangl\@biomarker.com.cn> 

Usage:
  Options:
	-r		<file>  input file,sexAver.map
	-c		<file>  input chrosome map
	-k		<str>   output key of filename
	-o		<dir>	output file dir
	-All		draw all maps
	-h         Help

USAGE
	print $usage;
	exit;
}
