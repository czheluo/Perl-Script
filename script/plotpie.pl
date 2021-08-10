#!/usr/bin/perl
use strict;
use warnings;

#plot MC and MR
die "perl $0 <name>" unless (@ARGV==1);

my $name = shift;
my $dir = shift;

my $R =<< "END";
#------------------------------
library(ggplot2)
library(reshape2)
require(ggrepel)
require(ggsci)

a <- read.delim("$name",header=T,sep=" ")

values=as.numeric(a\$num)

coordinate=c(values[1]/2,values[1]+values[2]/2,values[1]+values[2]+values[3]/2)
#-----
if(a[2,] == 0){
        values=c(a[1,],a[3,])
        coordinate=c(values[1]/2,values[1]+values[2]/2)
        regions=factor(c("exon","intergenic_region"),levels=c("intergenic_region","exon"))
}
if(a[3,] == 0){
        values=c(a[1,],a[2,])
        coordinate=c(values[1]/2,values[1]+values[2]/2)
        regions=c("exon","intron")
}
if(a[1,] == 0){
        values=c(a[3,],a[2,])
        coordinate=c(values[1]/2,values[1]+values[2]/2)
        regions=c("intergenic_region","intron")
}
if(a[2,] == 0 && a[3,] == 0){
        values=c(a[1,])
        coordinate=c(values[1]/2)
        regions=c("exon")
}
if(a[1,] == 0 && a[2,] == 0){
        values=c(a[3,])
        coordinate=c(values[1]/2)
        regions=c("intergenic_region")
}
if(a[1,] == 0 && a[3,] == 0){
        values=c(a[2,])
        coordinate=c(values[1]/2)
        regions=c("intron")
}
#-----

df<- read.table("$name",header=T)
df\$type <- factor(df\$type, levels = df\$type)
p<-ggplot(df,aes(x=factor(0),y = values, fill = type)) +
		geom_col(width = 1,color=1) +
		scale_y_continuous(breaks = coordinate) +
		coord_polar(theta = "y") +
		geom_text_repel(data = df,
                   aes(y = values-5, label = paste0(values)),
					nudge_x = .7,
					box.padding = 0.5,
					nudge_y = 1,
					point.padding = 0, # additional padding around each point
					min.segment.length = 0, # draw all line segments
					#segment.curvature = -0.1,
					segment.ncp = 1,
					#segment.angle = 20,
					#min.segment.length = -0.1,
					# arrow = arrow(length = unit(0.02, "npc"))
				)+
		guides(fill = guide_legend(title = " ")) +
		theme_void()+
		labs(title = 'cirRNA_class',x = '', y = '')+
		theme(plot.title = element_text(size = 12, color = 'black', hjust = 0.5),
			text=element_text(family="Times", size=12,color = 'black'))+
		scale_fill_npg()+
		theme(axis.ticks = element_blank(),axis.text.y = element_blank(),panel.grid.minor = element_blank())+
		theme(legend.position = "right",legend.direction = "vertical")+
		theme(panel.background =element_rect(fill="white",colour="white"))
#scale_y_continuous(breaks = coordinate,labels=label)
#p <- p + theme(
#        panel.background = element_rect(fill = "transparent",colour =NA),
#        panel.grid.minor = element_blank(),
#        panel.grid.major = element_line(color='grey83'),
#        plot.background = element_rect(fill  = "transparent",colour =NA)
#)
ggsave(filename="$name.MR.pdf", plot=p)
ggsave(filename="$name.MR.png",type="cairo-png", plot=p)

#---------------------------------
END
open R,"|/mnt/ilustre/users/dna/.env/bin/R  --vanilla --slave" or die $!;
print R $R;
#open Out,">pieplots.R";
#print Out "$R";
#close Out;
close R;
