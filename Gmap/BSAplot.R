library(ggplot2)
library(dplyr)
library(RColorBrewer)
color <- grDevices::colors()[grep("gr(a|e)y", grDevices::colors(), invert = T)]
rcolor <- color[sample(1:length(color), length(color))]

pos<-read.table("test.txt",head=TRUE,comment.char="")
#dfpos<-data.frame(CHR=pos$X.chr,BP=pos$pos,Delta=pos$delta,Slide=pos$slidingD,	tricubeDeltaSNP=pos$tricubeDeltaSNP)

dpos<-data.frame(CHR=pos$X.chr,BP=pos$pos,tricubeDeltaSNP=pos$delta,Delta=pos$DELTA,CI1=0.4995)	lev<-NULL
	lev<-NULL
	lev$CHR<-levels(as.factor(dfpos$CHR))
	lev$order<-gsub("chr","",lev$CHR)
	lev$order<-gsub("sca","1000",lev$order)
	lev$order=as.numeric(lev$order)
	dfpos=merge(dfpos,lev,by="CHR")
	dfpos=arrange(dfpos,order,BP)
	dpos <- dfpos %>% group_by(order) %>% summarise(chr_len=max(BP)) %>% mutate(tot=cumsum(chr_len)-chr_len) %>% select(-chr_len) %>%
	  left_join(dfpos, ., by=c("order"="order")) %>%
	  arrange(order, BP) %>%
	  mutate( BPcum=BP+tot)
	axisdf <- dpos %>% group_by(CHR) %>% summarize(center=( as.numeric(max(BPcum)) + as.numeric(min(BPcum)) ) / 2 )
		p1 <- ggplot(dpos) +
		    geom_point(aes(x=BPcum, y=Delta,color=as.factor(order))) +geom_line(mapping = aes(x=BPcum,y=tricubeDeltaSNP),color="black")+
		    #geom_line(mapping = aes(x=BPcum,y=CI),color="red")+
		   geom_line(mapping = aes(x=BPcum,y=CI1),color="red")+
		    scale_color_manual(values =rcolor[1:length(levels(as.factor(dpos$CHR)))])+#(values = rep(c("grey", "skyblue"), length(levels(dpos$CHR))))+
		    scale_x_continuous( label = axisdf$CHR, breaks= axisdf$center ) +
		    theme_bw() +xlab("chromosome")+ylab("delta-index")+
		    #theme( 
		     # legend.position="none",
		     # panel.border = element_blank(),
		     # panel.grid.major.x = element_blank(),
		     # panel.grid.minor.x = element_blank()
		    #)
		    theme(legend.position="none",
			axis.text = element_text(size = 16),
			axis.title = element_text(size = 16, face = "bold"),
			legend.title = element_blank(),
			legend.text = element_text(size = 16),
			panel.background = element_blank(),
			panel.border = element_rect(fill = NA),
			panel.grid.major = element_blank(),
			panel.grid.minor = element_blank(),
			strip.background = element_blank(),
			axis.text.x = element_text(colour = "black"),
			axis.text.y = element_text(colour = "black"),
			axis.ticks = element_line(colour = "black"),
			plot.margin = unit(c(1, 1, 1, 1), "line"),
			)
ggsave(file=paste("slide.index.png",sep="."),p1,device="png",dpi=300,height=9,width=16)
ggsave(file=paste("slide.index.pdf",sep="."),p1,device="pdf",dpi=300,height=9,width=16)



p1 <- ggplot(chr7) +
		    geom_point(aes(x=BPcum, y=Delta,color=as.factor(order))) +geom_line(mapping = aes(x=BPcum,y=tricubeDeltaSNP),color="black")+
		    #geom_line(mapping = aes(x=BPcum,y=CI),color="red")+
		   geom_line(mapping = aes(x=BPcum,y=CI1),color="red")+
		    scale_color_manual(values =rcolor[1:length(levels(as.factor(dpos$CHR)))])+#(values = rep(c("grey", "skyblue"), length(levels(dpos$CHR))))+
		    scale_x_continuous( label = axisdf$CHR, breaks= axisdf$center ) +
		    theme_bw() +xlab("chromosome")+ylab("delta-index")+
		    #theme( 
		     # legend.position="none",
		     # panel.border = element_blank(),
		     # panel.grid.major.x = element_blank(),
		     # panel.grid.minor.x = element_blank()
		    #)
		    theme(legend.position="none",
			axis.text = element_text(size = 16),
			axis.title = element_text(size = 16, face = "bold"),
			legend.title = element_blank(),
			legend.text = element_text(size = 16),
			panel.background = element_blank(),
			panel.border = element_rect(fill = NA),
			panel.grid.major = element_blank(),
			panel.grid.minor = element_blank(),
			strip.background = element_blank(),
			axis.text.x = element_text(colour = "black"),
			axis.text.y = element_text(colour = "black"),
			axis.ticks = element_line(colour = "black"),
			plot.margin = unit(c(1, 1, 1, 1), "line"),
			)
ggsave(file=paste("chr7.png",sep="."),p1,device="png",dpi=300,height=9,width=16)
ggsave(file=paste("chr7.pdf",sep="."),p1,device="pdf",dpi=300,height=9,width=16)
