#! /usr/bin/perl -w

use strict;
use Getopt::Long;
my ($count,$min,$out,$help);
GetOptions(
       	"count:s"       => \$count,
	"min:i"		=> \$min,
	"o:s"		=> \$out,
	"h!"            => \$help,
);

if (!($count && $out) || $help){
	&usage;
	exit;
}
$min=($min)?$min:5;

#read count table and store expressed gene list
my (@title,%exp);
open COUNT,"<$count" || die "count table $!";
my $h=<COUNT>;
chomp $h;
@title=split /\s+/,$h;
while (<COUNT>){
	chomp;
	my @line=split;
	for (my $i=1;$i<=$#line;$i++){
		if ($line[$i]>=$min){
			$exp{$title[$i]}{$line[0]}=1;
		}
	}	
}
close COUNT;

#output list
shift @title;
for my $i (@title){
	open OUT,">$i\_$out\_exp.list" || die "$i\_$out\_exp.list $!";
	my $list= join "\n",(keys %{$exp{$i}});
	print OUT $list;
	print OUT "\n";
	close OUT;
}

#output image
open RS,">cmd_$out.r" || die $!;
print RS 
'options(warn=-100)
library("VennDiagram")
fillColor<-c("dodgerblue", "goldenrod1")
';
for (my $m=0;$m<$#title;$m++){
	for (my $n=1;$n<=$#title;$n++){
		open OUT,">$title[$m]_vs_$title[$n]_$out.xls" || die "$!";
		my %venn=venn($title[$m],$title[$n]);
		print OUT "miRNA_ID\t$title[$m]\t$title[$n]\n";
		for my $mir(sort keys %venn){
			print OUT $mir;
			if (exists $venn{$mir}{$title[$m]}){
				print OUT "\t1";
			}else{
				print OUT "\t0";
			}
			if (exists $venn{$mir}{$title[$n]}){
				print OUT "\t1";
			}else{
				print OUT "\t0";
			}
			print OUT "\n";
		}
		close OUT;
my $Rst=<<RL;
files<-unlist(strsplit("$title[$m]_$out\_exp.list,$title[$n]_$out\_exp.list",",",fix=T))
Lables<-unlist(strsplit("$title[$m],$title[$n]",",",fix=T))
InputList<-list()
for(i in 1:length(files)){
    genes<-scan(file=files[i],what=character())
    InputList[[i]]<-genes
}
names(InputList)<-Lables
outname<-paste(Lables,collapse="_vs_")
pdf(file = paste(outname,"$out","pdf",sep="."),width=10,height=10)
venn.plot<-venn.diagram(InputList,filename = NULL,col = "black",fill = fillColor,alpha = 0.50,cat.cex = 1,cat.fontface = "bold",margin = 0.15,cex=2,scale=TRUE)
grid.draw(venn.plot)
dev.off()
RL
		print RS "$Rst\n";
	}
}
close RS;
`Rscript cmd_$out.r`;

sub venn {
	my $A=shift;
	my $B=shift;
	my %new;
	for my $key (keys %{$exp{$A}}){
		$new{$key}{$A}=1;
	}
	for my $key (keys %{$exp{$B}}){
		$new{$key}{$B}=1;
	}
	return %new;
}


sub usage {
	die
	" Usage: perl $0 [options]
	This program is used for common and specific analysis.
	Author: yuntao.guo
	Last updata:2016-9-9
Options:
	-count	count table,known/novel_miR_count.xls
	-min	NUM  the cutoff of min count
	-o	out prefix
	-help	this information
";
}
