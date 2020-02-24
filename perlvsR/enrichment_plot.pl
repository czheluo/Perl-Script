#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
my %opts;
GetOptions (\%opts,"t=s","i=s","fdr=f","p=f","N=i","w=i","h=i","lcex=f","rcex=f","ncol=i");
##
my $usage = <<"USAGE";
Usage:        perl enrichment2barplot.pl [options]
Description:  This program is used for ploting GO enrichment or KEGG enrichment analysis results.
              enrichment file name format:
	      KEGG: *kegg_enrichment.xls
	      GO  : *enrichment.detail.xls
Contact:      meng.luo\@majorbio.com  Time: 2020.02.24
Version:      1.0
Options:
       input file related:
   	 -i             FILE     GO or KEGG enrichment result table[required]
                                 (must be obtained from find_enrichment.py or exact_goatools.pl)
         -t             STRING   enrichment type: GO or KEGG

         -fdr 	         FLOAT    only display the terms which the p_fdr <= this argument,default:0.05
         -p 	         FLOAT    only display the terms which the p_value <= this argument,default:0.05
	 -N              INT      only display the top N terms (sorted by p_value),default: 30
       plot related:
         -w              INT      plot width ,defalt: 16
	 -h              INT      plot width ,defalt: 10
         -lcex           FLOAT    cex of the left main plot
         -rcex           FLOAT    cex of the right legend plot
         -ncol	         INT       the number of columns in which to set the legend items

USAGE

die $usage if ( !defined $opts{i});
die $usage if ( !defined $opts{t});

#define defaults
$opts{w}=defined$opts{w}?$opts{w}:16;
$opts{h}=defined$opts{h}?$opts{h}:10;
$opts{fdr}=defined$opts{fdr}?$opts{fdr}:0.05;
$opts{p}=defined$opts{p}?$opts{p}:0.05;
$opts{N}=defined$opts{N}?$opts{N}:30;
$opts{inset}=defined $opts{inset}?$opts{inset}:0.15;
$opts{lcex}=defined$opts{lcex}?$opts{lcex}:1;
$opts{rcex}=defined$opts{rcex}?$opts{rcex}:0.8;
$opts{ncol}=defined$opts{ncol}?$opts{ncol}:2;

if(lc($opts{t}) eq "go")
{
	open GO, $opts{i} or die $!;
	open GOO, ">$opts{i}.go" or die $!;
	while(<GO>)
	{
		chomp;
		my @tmp = split /\t/;
		if(/^id/)
		{
			print GOO "description\tratio\tp_bonferroni\ttype\tpvalue\n";
		}else{
			my $fenzi = (split /\//, $tmp[3])[0];
			my $fenmu = (split /\//, $tmp[4])[0];
			my $ratio = $fenzi / $fenmu;
			next if($tmp[1] =~  /p/);
#			my @num = split / /, $tmp[2];
#			my $name = $tmp[2];
#			if(@num > 5)
#			{
#				$name = join " ", @num[0..4], "\b...";
#			}else{
#				
#			}
			print GOO "$tmp[2]\t$ratio\t$tmp[6]\t$tmp[7]\t$tmp[5]\n";
		}
	}
	close GO;
	close GOO;
}elsif(lc($opts{t}) eq "kegg"){
	open EN, $opts{i} or die $!;
	open PWP, ">$opts{i}.pathway" or die $!;
	open PWD, ">$opts{i}.disease" or die $!;
	$/ = "\n#";
	<EN>;<EN>;<EN>;
	my $p = <EN>;
	my @lines = split /\n/, $p;
	print PWP "#Term\tratio\tCorrected P-Value\tpvalue\n";
	for(my $i = 1; $i < @lines; $i ++)
	{
		next if($lines[$i] !~ /^\w+/);
		my @tmp = split /\t/, $lines[$i];
		my $ratio = $tmp[3] / $tmp[4];
#		my @num = split / /, $tmp[0];
#		my $name = $tmp[0];
#		if(@num > 5)
#		{
#			$name = join " ", @num[0..4], "\b...";
#		}else{
#			
#		}
		print PWP "$tmp[0]\t$ratio\t$tmp[6]\t$tmp[5]\n";
	}
	my $d = <EN>;
	my @line = split /\n/, $d;
	print PWD "#Term\tratio\tCorrected P-Value\tpvalue\n";
	for(my $i = 1; $i < @line; $i ++)
	{
		next if($line[$i] !~ /^\w+/);
		my @tmp = split /\t/, $line[$i];
		my $ratio = $tmp[3] / $tmp[4];
#		my @num = split / /, $tmp[0];
#		my $name = $tmp[0];
#		if(@num > 5)
#		{
#			$name = join " ", @num[0..4], "\b...";
###		}
		print PWD "$tmp[0]\t$ratio\t$tmp[6]\t$tmp[5]\n";
	}
	close EN;
	close PWP;
	close PWD;
}else{
	die "please choose correct type: GO or KEGG, case-insensitive!!!";
}

open RCMD, ">$opts{i}.r";
print RCMD "
options(warn=-1)
w<-$opts{w}
h<-$opts{h}
type<-\"$opts{t}\"
fdr<-$opts{fdr}
p<-$opts{p}
topN<-50
mycol <-c(119,132,147,454,89,404,123,529,463,104,552,28,54,84,256,100,558,43,652,31,610,477,588,99,81)
if(type==\"KEGG\"){
        ## PATHWAY
        PATHWAY_enrichraw<-read.delim(\"$opts{i}.pathway\",header=T,sep=\"\\t\",check.names=F)
	if(nrow(PATHWAY_enrichraw)==0){
	        print(\"There is no enriched KEGG Pathways,please check your input file!\")
	}else{
                PATHWAY_enrich<-PATHWAY_enrichraw[order(as.numeric(PATHWAY_enrichraw[,3]),-as.numeric(PATHWAY_enrichraw[,2]),as.numeric(PATHWAY_enrichraw[,4])),]
                RichFactor<-round(PATHWAY_enrich[,2],2)
                log10P1<-as.data.frame(-log10(0.000000000000001+as.numeric(PATHWAY_enrich[,3])))
                log10P2<-vector()
                for(i in 1:nrow(log10P1)){
                        if(log10P1[i,1]==Inf){log10P2[i]<-400}else{log10P2[i]<-log10P1[i,1]}
                }
                log10P<-as.data.frame(log10P2)
                rownames(log10P)<-as.character(PATHWAY_enrich[,1])
                colnames(log10P)<-\"-log10(Qvalue)\"
                log10Qvalue<-as.numeric(t(as.matrix(log10P)))
		
		#########  plot  #########
		pdfname <-\"$opts{i}.pathway.pdf\"
		pdf(file=pdfname,width=w,height=h)
		par(fig=c(0,0.65,0,1),new=F,mar = c(6,6,6,0.1)+0.1)
		pches<-rep(0:9,25)
		colors <-rep(colors()[mycol],each=10)
		if(max(RichFactor)+0.2>=1){
		       XLIM<-seq(0,1,by=0.2)
		}else{
	               XLIM<-seq(0,(max(RichFactor)+0.2),by=0.2)
		}
		ylims<-max(log10Qvalue)+0.5
		if(ylims<2){
		       ylims<-2
		}
		a<-plot(RichFactor,log10Qvalue,xlim=c(-0.01,XLIM[length(XLIM)]+XLIM[length(XLIM)]/5),ylim=c(-0.2,ylims),pch=pches[1:length(RichFactor)],col=colors[1:length(RichFactor)],main=\"Statistics of KEGG Pathway Enrichment\",cex=$opts{lcex},xaxs=\"i\",yaxs=\"i\",xaxt=\"s\",yaxt=\"n\",ylab=\"-1*log10(Qvalue)\")
		YLIM<-seq(0,ceiling(ylims),by=0.5)
		axis(2,YLIM,as.character(YLIM))
		axis(2,1.3,\"1.3\")
		segments(0,1.3,XLIM[length(XLIM)]+XLIM[length(XLIM)]/5,1.3,lwd=1,lty=2,col=\"darkgrey\")
		grid(,NA,lty=2,lwd=1)
		par(fig=c(0.65,1,0,1),new=TRUE,mar = c(6,0.5,6,1)+0.1)
		plot(0:1,0:1,xlab=\"\",ylab=\"\",axes=F,type=\"n\")
		if(length(RichFactor)>topN){
                        legend(\"center\",legend=paste(\"(\",RichFactor[1:topN],\",\",round(log10Qvalue[1:topN],2),\") \",rownames(log10P)[1:topN],sep=\"\"),ncol=1,pch=pches[1:topN],col=colors[1:topN],cex=0.7,bty=\"n\")
                }else{
		        legend(\"center\",legend=paste(\"(\",RichFactor,\",\",round(log10Qvalue,2),\") \",rownames(log10P),sep=\"\"),ncol=1,pch=pches,col=colors,cex=0.7,bty=\"n\")
		}
		dev.off()
	}
	## Pathway Plot End ##
	## Disease
	DISEASE_enrichraw<-read.delim(\"$opts{i}.disease\",header=T,sep=\"\\t\",check.names=F)
	if(nrow(DISEASE_enrichraw)==0){
	        print(\"There is no enriched KEGG Disease,please check your input file!\")
	}else{
	        DISEASE_enrich<-DISEASE_enrichraw[order(DISEASE_enrichraw[,3],-DISEASE_enrichraw[,2],DISEASE_enrichraw[,4],decreasing=F),]
		RichFactor<-round(DISEASE_enrich[,2],2)
		log10P1<-as.data.frame(-log10(0.000000000000001+as.numeric(DISEASE_enrich[,3])))
		log10P2<-vector()
		for(i in 1:nrow(log10P1)){
		        if(log10P1[i,1]==Inf){log10P2[i]<-400}else{log10P2[i]<-log10P1[i,1]}
		}
		log10P<-as.data.frame(log10P2)
		rownames(log10P)<-as.character(DISEASE_enrich[,1])
		colnames(log10P)<-\"-log10(Qvalue)\"
		log10Qvalue<-as.numeric(t(as.matrix(log10P)))
		#########  plot  #########
		pdfname <-\"$opts{i}.disease.pdf\"
		pdf(file=pdfname,width=w,height=h)
		par(fig=c(0,0.65,0,1),new=F,mar = c(6,6,6,0.1)+0.1)
		pches<-rep(0:9,25)
		colors <-rep(colors()[mycol],each=10)
		if(max(RichFactor)+0.2>=1){
		       XLIM<-seq(0,1,by=0.2)
		}else{
		        XLIM<-seq(0,(max(RichFactor)+0.2),by=0.2)
		}
		ylims<-max(log10Qvalue)+0.5
		if(ylims<2){ylims<-2}
		a<-plot(RichFactor,log10Qvalue,xlim=c(-0.01,XLIM[length(XLIM)]+XLIM[length(XLIM)]/5),ylim=c(-0.2,ylims),pch=pches[1:length(RichFactor)],col=colors[1:length(RichFactor)],main=\"Statistics of KEGG Disease Enrichment\",cex=$opts{lcex},xaxs=\"i\",yaxs=\"i\",xaxt=\"s\",yaxt=\"n\",ylab=\"-1*log10(Qvalue)\")
		YLIM<-seq(0,ceiling(ylims),by=0.5)
		axis(2,YLIM,as.character(YLIM))
		axis(2,1.3,\"1.3\")
		segments(0,1.3,XLIM[length(XLIM)]+XLIM[length(XLIM)]/5,1.3,lwd=1,lty=2,col=\"darkgrey\")
		grid(,NA,lty=2,lwd=1)
		par(fig=c(0.65,1,0,1),new=TRUE,mar = c(6,0.5,6,1)+0.1)
		plot(0:1,0:1,xlab=\"\",ylab=\"\",axes=F,type=\"n\")
		if(length(RichFactor)>topN){
		        legend(\"center\",legend=paste(\"(\",RichFactor[1:topN],\",\",round(log10Qvalue[1:topN],2),\") \",rownames(log10P)[1:topN],sep=\"\"),ncol=1,pch=pches[1:topN],col=colors[1:topN],cex=0.7,bty=\"n\")
		}else{
		        legend(\"center\",legend=paste(\"(\",RichFactor,\",\",round(log10Qvalue,2),\") \",rownames(log10P),sep=\"\"),ncol=1,pch=pches,col=colors,cex=0.7,bty=\"n\")
		}
		dev.off()
	}
	## Disease Plot End ##
}
if(type==\"GO\"){
        GO_enrichraw<-read.delim(\"$opts{i}.go\",header=T,sep=\"\\t\",check.names=F)
	if(nrow(GO_enrichraw)==0){
	        print(\"There is no enriched GO Term,please check your input file!\")
	}else{
                GO_enrich<-GO_enrichraw[order(GO_enrichraw[,4],GO_enrichraw[,3],-GO_enrichraw[,2],GO_enrichraw[,5],decreasing=F),]
		RichFactor<-round(GO_enrich[,2],2)
		log10P1<-as.data.frame(-log10(0.000000000000001+as.numeric(GO_enrich[,3])))
		log10P2<-vector()
		for(i in 1:nrow(log10P1)){
		        if(log10P1[i,1]==Inf){log10P2[i]<-400}else{log10P2[i]<-log10P1[i,1]}
		}
		log10P<-as.data.frame(log10P2)
		rownames(log10P)<-as.character(GO_enrich[,1])
		colnames(log10P)<-\"-log10(Qvalue)\"
		log10Qvalue<-as.numeric(t(as.matrix(log10P)))
		#########  plot  #########
		pdfname <-\"$opts{i}.go.pdf\"
		pdf(file=pdfname,width=w,height=h)
		par(fig=c(0,0.65,0,1),new=F,mar = c(6,6,6,0.1)+0.1)
		pches<-rep(0:18,25)
		colors <-rep(colors()[mycol],each=19)
		if(max(RichFactor)+0.2>=1){
		        XLIM<-seq(0,1,by=0.2)
		}else{
		       XLIM<-seq(0,(max(RichFactor)+0.2),by=0.2)
		}
		ylims<-max(log10Qvalue)+0.5
		if(ylims<2){ylims<-2}
		a<-plot(RichFactor,log10Qvalue,xlim=c(-0.01,XLIM[length(XLIM)]+XLIM[length(XLIM)]/5),ylim=c(-0.2,ylims),pch=pches[1:length(RichFactor)],col=colors[1:length(RichFactor)],main=\"Statistics of GO Enrichment\",cex=$opts{lcex},xaxs=\"i\",yaxs=\"i\",xaxt=\"s\",yaxt=\"n\",ylab=\"-1*log10(Qvalue)\")
		YLIM<-seq(0,ceiling(ylims),by=0.5)
		axis(2,YLIM,as.character(YLIM))
		axis(2,1.3,\"1.3\")
		segments(0,1.3,XLIM[length(XLIM)]+XLIM[length(XLIM)]/5,1.3,lwd=1,lty=2,col=\"darkgrey\")
		grid(,NA,lty=2,lwd=1)
		par(fig=c(0.65,1,0,1),new=TRUE,mar = c(6,0.5,6,1)+0.1)
		plot(0:1,0:1,xlab=\"\",ylab=\"\",axes=F,type=\"n\")
		#### legend for 3 classes
		bpline<-which(GO_enrich[,4]==\"biological_process\")
		ccline<-which(GO_enrich[,4]==\"cellular_component\")
		mfline<-which(GO_enrich[,4]==\"molecular_function\")
		if(length(bpline)>15){bptop10line<-bpline[1:15]}else{bptop10line<-bpline}
		if(length(ccline)>15){cctop10line<-ccline[1:15]}else{cctop10line<-ccline}
		if(length(mfline)>15){mftop10line<-mfline[1:15]}else{mftop10line<-mfline}		
		bplgd<-c(\"Biological Process:\",paste(\"(\",RichFactor[bptop10line],\",\",round(log10Qvalue[bptop10line],2),\") \",rownames(log10P)[bptop10line],sep=\"\"))
		cclgd<-c(\"Cellular Component:\",paste(\"(\",RichFactor[cctop10line],\",\",round(log10Qvalue[cctop10line],2),\") \",rownames(log10P)[cctop10line],sep=\"\"))
		mflgd<-c(\"Molecular Function:\",paste(\"(\",RichFactor[mftop10line],\",\",round(log10Qvalue[mftop10line],2),\") \",rownames(log10P)[mftop10line],sep=\"\"))
		fonts<-c(2,rep(1,length(bptop10line)),2,rep(1,length(cctop10line)),2,rep(1,length(mftop10line)))
		legend(\"topleft\",legend=c(bplgd,cclgd,mflgd),ncol=1,pch=c(0,pches[bptop10line],0,pches[cctop10line],0,pches[mftop10line]),col=c(\"white\",colors[bptop10line],\"white\",colors[cctop10line],\"white\",colors[mftop10line]),cex=0.8,bty=\"n\",text.font=fonts,inset=0.1)
		dev.off()
	}
	## GO Plot End ##
}

";

#system ("R --restore --no-save < $opts{i}.r");
`R --restore --no-save < $opts{i}.r`;
# system ('rm *.r');
#if(-e "$opts{i}.go"){system("rm $opts{i}.go")};
#if(-e "$opts{i}.pathway"){system("rm $opts{i}.pathway")};
#if(-e "$opts{i}.disease"){system("rm $opts{i}.disease")};



