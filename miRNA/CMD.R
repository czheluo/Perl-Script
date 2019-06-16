library("ggplot2")
setwd("C:\\Users\\meng.luo\\Desktop\\txt")
files<-list.files()

for (i in 1:length(files)){
  dat<-read.table(paste(as.character(files[i]),sep=""),header=T)
  #print(dat)
  dat$Chr<-factor(dat$Chr,levels<-unique(as.character(dat$Chr)))
  pdf (paste(strsplit(files[i],split="[.]")[[1]][1],".pdf",sep=""),w=10,h=6)
  p<-ggplot(data=dat,aes(x=Chr,y=Reads,fill=Strand))+
    geom_bar(stat="identity", position="identity")+
    ggtitle(paste(strsplit(files[i],split="[.]")[[1]][1]," mapping result",sep=""))+
    theme(axis.text.x = element_text(angle=90, hjust=1,vjust=.5))
  print(p)
  dev.off()
}

