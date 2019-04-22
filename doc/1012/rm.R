

as.data.frame(matrix(NA,length(unique(par[,1])),2))
colnames(pid)<-c("ID","pairrate")

for (i in 1:length(uid)){
	if (length(length(par[which(par[,1] %in% uid[i]),1]))>1){
		p<-which(par[which(par[,1] %in% uid[i]),2] %in% max(par[which(par[,1] %in% uid[i]),2]))
		pid[i,]<-par[which(par[,1] %in% uid[i]),][p,]
	}else{
		pid[i,]<-par[which(par[,1] %in% uid[i]),]
	}
}






