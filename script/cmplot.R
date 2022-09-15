
for(i in 1:40){
	gene<-read.csv(list.files()[grep(".scan.csv",list.files())[i]],header=T,sep="\t")
	colnames(gene)[1] <-"SNP"
	colnames(gene)[4] <-strsplit(list.files()[grep(".scan.csv",list.files())[i]],"[.]")[[1]][1]
	gen<-gene[,c(1:4)]
	png(paste(strsplit(list.files()[grep(".scan.csv",list.files())[i]],"[.]")[[1]][1], ".png", sep = ""),
		width = 1500, height = 500)
	CMplot(gen, plot.type="m", LOG10=FALSE, ylim=NULL, threshold=NULL,
		amplify=TRUE,bin.size=5,ylab="LOD",
		chr.den.col=c("darkgreen", "yellow", "red"),signal.col=c("red","green"),signal.cex=c(1,1),
		signal.pch=c(19,19),memo="",dpi=300,file.output=F,verbose=TRUE,#file=".pdf",
		width=14,height=6)
	dev.off()
	pdf(paste(strsplit(list.files()[grep(".scan.csv",list.files())[i]],"[.]")[[1]][1], ".pdf", sep = ""),
		width = 15, height = 5)
	CMplot(gen, plot.type="m", LOG10=FALSE, ylim=NULL, threshold=NULL,
		amplify=TRUE,bin.size=5,ylab="LOD",
		chr.den.col=c("darkgreen", "yellow", "red"),signal.col=c("red","green"),signal.cex=c(1,1),
		signal.pch=c(19,19),memo="",dpi=300,file.output=F,verbose=TRUE,#file=".jpg",
		width=14,height=6)
	dev.off()

}

