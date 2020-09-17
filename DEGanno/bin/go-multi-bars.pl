#!/usr/bin/perl -w

use strict;
use warnings;
use Getopt::Long;
my %opts;
GetOptions (\%opts,"i=s","u=s","d=s","w=i","h=i","tc=s","marble=s","nw=i","main=s","lgdh=i","lws=f","ylw=f","o=s","help!");

my $usage = <<"USAGE";
       Program : $0
       Version : 1.0
       Discription: plot bar chart
       Usage :perl $0 -i GO.list -u up-gene-list -d down-gene-list -w 20 -h 25
       input file:
                   -i        STRING   GO annotation file for all genes or isoforms( GO.list )
                   -o        STRING   output prefix for Rscript,default: gomultibars.r
                   -u        STRING   up-regulated gene or isoform name list
		   -d        STRING   up-regulated gene or isoform name list
       plot related:
                   -w        FLOAT    plot width   defalt:12
                   -h        FLOAT    plot height  defalt:12
		   -tc       STRING   colors for the two bars (default: red-blue)
		   -marble   STRING   marble in each side of barplot image(down-left-up-right),default:[6-6-6-6]
		   -nw       INT      white spaces numbers of the left xlab,default:60
		   -main     STRING   title of this barplot
		   -lgdh     INT      the height from legend up border to the whole barplot up border,default: 10
		   -lws      FLOAT    white spaces numbers of the left,default:20
		   -ylw      FLOAT    width of the ylab 6 line segments(between texts and arrows)
                   -help     Display this usage information
                 
USAGE
die $usage if ( !( $opts{i} && $opts{u} && $opts{d} ) || $opts{help} );

#define defaults
$opts{w}=$opts{w}?$opts{w}:12;
$opts{h}=$opts{h}?$opts{h}:10;
$opts{tc}=$opts{tc}?$opts{tc}:"red-blue";
$opts{marble}=defined $opts{marble}?$opts{marble}:"6-6-6-6";
$opts{nw}=$opts{nw}?$opts{nw}:60;
$opts{main}=$opts{main}?$opts{main}:"";
$opts{lgdh}=$opts{lgdh}?$opts{lgdh}:10;
$opts{lws}=$opts{lws}?$opts{lws}:20;
$opts{ylw}=$opts{ylw}?$opts{ylw}:0;
$opts{o}=$opts{o}?$opts{o}:"gomultibars";

my %gene2go;
my $allgos = $opts{i};
my $upgene = $opts{u};
my $downgene = $opts{d};
my $upgos=$opts{u}."GO.list";
my $downgos=$opts{d}."GO.list";
open (FIN, "< $allgos");
open (FIN1, "< $upgene");
open (FIN2, "< $downgene");
open (OUT1, "> $upgos");
open (OUT2, "> $downgos");

while(<FIN>){
	chomp;
	my $line = $_;
	if($_=~/^([^\t]*)\t([\s\S]*)$/){		
		$gene2go{$1} = $2;
		
	}else{
		# die "the $allgos format is wrong";				
	}		
}
close FIN;

while(<FIN1>){
	chomp $_;
	#if (exists $gene2go{$_}){print OUT1 $_."\t".$gene2go{$_}}else{next;}
        if ($gene2go{$_} ne ""){print OUT1 $_."\t".$gene2go{$_}."\n"}else{next;}
	
}
while(<FIN2>){
	chomp;
 	if ($gene2go{$_} ne ""){print OUT2 $_."\t".$gene2go{$_}."\n"}else{next;}
}
close FIN1;
close FIN2;
close OUT1;
close OUT2;
my $bins="/mnt/ilustre/centos7users/meng.luo/Pipeline/RNA/Pipeline/11.scRNA/songweiwen_MJ20200701041/07.DEG.enrich/script/";
#### get go class stat file
my $uplevel2=$upgos.'level2';
my $downlevel2=$downgos.'level2';
open (SH,">gene-ontology.$opts{u}.$opts{d}.sh");
#print SH '#PBS -N gene-ontology'."\n";
#print SH '#PBS -l nodes=1:ppn=1'."\n";
#print SH '#PBS -q DNA'."\n";
#print SH 'cd $PBS_O_WORKDIR'."\n";
#print SH 'sleep 3'."\n";
#print SH 'perl /share/apps/public_scripts/gene-ontology.pl -i '.$upgos.' -l 2 -list '.$uplevel2.' >'.$uplevel2.'.txt'."\n";
#print SH 'perl /share/apps/public_scripts/gene-ontology.pl -i '.$downgos.' -l 2 -list '.$downlevel2.' >'.$downlevel2.'.txt'."\n";
print SH 'perl /mnt/ilustre/centos7users/meng.luo/Pipeline/RNA/Pipeline/11.scRNA/songweiwen_MJ20200701041/07.DEG.enrich/script/gene-ontology.pl -i '.$upgos.' -l 2 -list '.$uplevel2.' > '.$uplevel2.'.txt'."\n";
print SH 'perl /mnt/ilustre/centos7users/meng.luo/Pipeline/RNA/Pipeline/11.scRNA/songweiwen_MJ20200701041/07.DEG.enrich/script/gene-ontology.pl -i '.$downgos.' -l 2 -list '.$downlevel2.' > '.$downlevel2.'.txt'."\n";
close SH;
#system("qsub -q rna gene-ontology.$opts{u}.$opts{d}.sh");
system("sh gene-ontology.$opts{u}.$opts{d}.sh");

while(!((-e $uplevel2.".txt") && (-e $downlevel2.".txt"))){
	system("sleep 120");
	#print("sleep 60s ...");
}

#### combine two go-class-stat files
open RCMD, ">$opts{u}.$opts{d}.r";
print RCMD "

marble<-as.numeric(unlist(strsplit(\"$opts{marble}\",\"-\",fix=T)))
md<-marble[1]
ml<-marble[2]
mu<-marble[3]
mr<-marble[4]
mycol_up_down<-unlist(strsplit(\"$opts{tc}\",\"-\",fix=T))
NWhite<-$opts{nw}
Titlename<-\"$opts{main}\"
lgdh<-$opts{lgdh}

#### combine two go-class-stat files
matrix1_path<-paste(\"$uplevel2\",\".txt\",sep=\"\")
matrix2_path<-paste(\"$downlevel2\",\".txt\",sep=\"\")
scan1<-scan(matrix1_path,what=character(),nlines=1)
scan2<-scan(matrix2_path,what=character(),nlines=1)
Num1<-as.numeric(scan1[length(scan1)])
Num2<-as.numeric(scan2[length(scan2)])
Matrix1<-read.delim(matrix1_path,header=T,check.names=F,skip=1)
Matrix2<-read.delim(matrix2_path,header=T,check.names=F,skip=1)

names(Matrix1)<-c(\"term_type_1\",\"term_1\",\"number_1\",\"percent_1\",\"GO\")
names(Matrix2)<-c(\"term_type_2\",\"term_2\",\"number_2\",\"percent_2\",\"GO\")
MergeMatrix<-unique(merge(Matrix1,Matrix2,by=\"GO\",all=T))

NA1_lines<-which(is.na(MergeMatrix[[\"term_1\"]])==TRUE)
NA2_lines<-which(is.na(MergeMatrix[[\"term_2\"]])==TRUE)

if(length(NA1_lines)==0 && length(NA2_lines)==0){nonNA_matrix<-MergeMatrix}
if(length(NA1_lines)!=0 && length(NA2_lines)!=0){nonNA_matrix<-MergeMatrix[-c(NA1_lines,NA2_lines),]}
if(length(NA1_lines)==0 && length(NA2_lines)!=0){nonNA_matrix<-MergeMatrix[-NA2_lines,]}
if(length(NA1_lines)!=0 && length(NA2_lines)==0){nonNA_matrix<-MergeMatrix[-NA1_lines,]}

NA1_matrix<-MergeMatrix[NA1_lines,]
NA2_matrix<-MergeMatrix[NA2_lines,]

NA1_matrix[,\"term_type_1\"]<-NA1_matrix[,\"term_type_2\"]
NA1_matrix[,\"term_1\"]<-NA1_matrix[,\"term_2\"]
NA1_matrix[,\"number_1\"]<-rep(0,nrow(NA1_matrix))
NA1_matrix[,\"percent_1\"]<-rep(0,nrow(NA1_matrix))

NA2_matrix[,\"term_type_2\"]<-NA2_matrix[,\"term_type_1\"]
NA2_matrix[,\"term_2\"]<-NA2_matrix[,\"term_1\"]
NA2_matrix[,\"number_2\"]<-rep(0,nrow(NA2_matrix))
NA2_matrix[,\"percent_2\"]<-rep(0,nrow(NA2_matrix))

Matrix<-rbind(nonNA_matrix,NA1_matrix,NA2_matrix)
Matrix_new<-Matrix[,c(\"term_1\",\"term_type_1\",\"number_1\",\"number_2\",\"percent_1\",\"percent_2\",\"GO\")]
names(Matrix_new)<-c(\"term\",\"term_type\",\"number_1\",\"number_2\",\"percent_1\",\"percent_2\",\"GO\")
Matrix_new_sort<-Matrix_new[order(Matrix_new[[\"term_type\"]],Matrix_new[[\"term\"]],decreasing=F),]

#### plot bars ####
mycol<-c(\"#6B8E23\",\"#7EC0EE\",\"#FF69B4\") 
x<-as.matrix(Matrix_new_sort[,c(\"term_type\",\"percent_1\",\"percent_2\",\"number_1\",\"number_2\")])
Height_1<-as.numeric(x[,\"number_1\"])
Height_2<-as.numeric(x[,\"number_2\"])
x_up<-as.numeric(x[,\"percent_1\"])*100
x_down<-as.numeric(x[,\"percent_2\"])*100
## 0.1
x_up[which(x_up<0.1)]<-0.1
x_down[which(x_down<0.1)]<-0.1
## log10
lpx_up <-log(x_up,base=10)+1
lpx_up <-10*lpx_up
lpx_down <-log(x_down,base=10)+1
lpx_down <-10*lpx_down
## barplot
barplot_matrix<-as.matrix(rbind(lpx_up,lpx_down))
MN<-max(barplot_matrix)
SpaceLength<-paste(rep(\"  \",NWhite),collapse=\"\")
pdfname <-paste(\"$uplevel2\",\"-\",\"$downlevel2\",\"-\",\"gobars.pdf\",sep=\"\")
par(mar = c(md,ml,mu,mr)+0.1)
pdf(file=pdfname,width=$opts{w},height=$opts{h})
Bars<- barplot(barplot_matrix[,ncol(barplot_matrix):1],beside=TRUE,horiz=T,col=mycol_up_down,axes=FALSE,asp=NA,border=NA,plot=TRUE,main=Titlename,xlim=c(-(2*MN)+$opts{lws},MN+round(MN/2)),xlab=paste(SpaceLength,\"Number of genes ( Up/Down )\",collapse=\"\"))
pos_Y<-Bars[1,]+0.5
text_Y<-as.character(Matrix_new_sort[[\"term\"]])[ncol(barplot_matrix):1]

### out
out_mat<-as.data.frame(cbind(cbind(text_Y[length(text_Y):1],Height_1),Height_2))
names(out_mat)<-c(\"GO term\",\"num of up gene\",\"num of down gene\")
write.table(out_mat,paste(\"$uplevel2\",\"-\",\"$downlevel2\",\"-\",\"gobars.mat\",sep=\"\"),sep=\"\t\",col.names=T,row.names=F,quote=F)
### out

GOtype<-as.character(Matrix_new_sort[[\"term_type\"]])[ncol(barplot_matrix):1]
GOtype[which(GOtype==\"biological_process\")]<-\"#6B8E23\"
GOtype[which(GOtype==\"cellular_component\")]<-\"#7EC0EE\"
GOtype[which(GOtype==\"molecular_function\")]<-\"#FF69B4\"
#text(rep(-MN/10,length(pos_Y)),pos_Y,labels=text_Y,srt=0,adj=1,xpd=T,cex=0.8,font=1,col=GOtype)
text(rep(-MN/10,length(pos_Y)),pos_Y,labels=text_Y,srt=0,adj=1,xpd=T,cex=0.8,font=1)
## axes: number of genes, percent of genes
y_position_percent<-c(0,10,20,30)
y_position_down<-y_position_percent-2.5
y_up_label<-c(0,as.integer(Num1/100),as.integer(Num1/10),as.integer(Num1))
y_down_label<-c(0,as.integer(Num2/100),as.integer(Num2/10),as.integer(Num2))
y_updown_label<-paste(y_up_label,y_down_label,sep=\"/\")
axis(side=3, at=y_position_percent,labels = c(\"0%\",\"1%\",\"10%\",\"100%\"),las=1,cex=0.8,pos=c(max(pos_Y)+3,max(pos_Y)+3),tcl=0.2)
axis(side=1, at=y_position_percent,labels = y_updown_label,las=1,cex=0.8,pos=c(0,0),tcl=0.2)
## 9lines
BP<-which(GOtype==\"#6B8E23\")
CC<-which(GOtype==\"#7EC0EE\")
MF<-which(GOtype==\"#FF69B4\")
width_gotype<--(strwidth(text_Y,units=\"user\"))+$opts{ylw}
pos_Y_t<-pos_Y[length(pos_Y):1]
x0<-c(width_gotype[BP[1]],width_gotype[BP[length(BP)]],width_gotype[CC[1]],width_gotype[CC[length(CC)]],width_gotype[MF[1]],width_gotype[MF[length(MF)]])-4

y0<-c(pos_Y[BP[1]],pos_Y[BP[length(BP)]],pos_Y[CC[1]],pos_Y[CC[length(CC)]],pos_Y[MF[1]],pos_Y[MF[length(MF)]])
x1<-rep(min(width_gotype)-2,6)
y1<-y0
segments(x0,y0,x1,y1)
X0<-x1[1:3]
Y0<-y0[c(1,3,5)]
X1<-X0
Y1<-y0[c(2,4,6)]
segments(X0,Y0,X1,Y1)
### text
XX<-X0-4
YY<-round((Y1+Y0)/2)
text(XX,YY,labels=c(\"Biological Process\",\"Cellular Component\",\"Molecular Function\"),srt=-90,adj=1,xpd=T,cex=0.8,font=1)
###
legend(list(x=(MN+round(MN/2))*4/5,y=max(pos_Y)-lgdh),bty=\"n\",legend=c(\"up\",\"down\"), pch=15,col=mycol_up_down,cex=1,text.font=1,text.col=\"black\")
## legend(\"topright\",bty=\"n\",legend=c(\"up\",\"down\"), pch=15,col=mycol_up_down,cex=1,text.font=1,text.col=\"black\")
##box()
dev.off()

";

#system ("R --restore --no-save < $opts{u}.$opts{d}.r");

