xt, n) {
	  strsplit(text, paste0("(?<=.{",n,"})"), perl=TRUE)
  }

  ssrrev<-NULL

  revString <- function(text){
	    paste(rev(unlist(strsplit(text,NULL))),collapse="")
	}


	for (i in 1:148){

		h<-fixed_split(revString(paste(ssr[i,3])),1)

		for (j in 1: length(h[[1]])) {
			if (h[[1]][j]=="A") { 
				h[[1]][j]="T"
			} else if (h[[1]][j]=="T" ) {
				h[[1]][j]="A"
			} else if ( h[[1]][j]=="G" ) {
				h[[1]][j]="C"
			} else if (h[[1]][j]=="C") {
				h[[1]][j]="G"
			}
		}
		ssrrev[i]<-h
	}



