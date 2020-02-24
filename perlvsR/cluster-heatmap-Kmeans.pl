#!/usr/bin/perl -w

use strict;
use warnings;
use Getopt::Long;
use Cwd 'abs_path';
use PBS::Queue;

my %opts;
my $VERSION = "2020-02-24";
GetOptions (\%opts,"i=s","log=i","k=i","w=f","h=f","cls=f","rls=f","go=s","ml=s","mr=s","clt=s");
my $usage = <<"USAGE";
Program : $0
Contact : $VERSION
Author : meng.luo\@majorbio.com
Description: ploting the heatmap and the subcluster line
Usage:perl $0 [options]	     
Options: 
         -i   *         STRING  matrix for heatmap plot
	                        ################################
			        # gene_id sample1 sample2 ...
                                # gene1 12 24
                                # gene2 45 7
                                # ...

         -log            INT    converted the input data matrix by log function (log2 or log10,default: ignore this step)		 
         -k              INT    number of subclusters(defaul: 8)  
         -w              FLOAT  plot width(defalt will be 12)                                                                      
         -h              FLOAT  plot height(defalt will be:16)
	 -cls            FLOAT  colum text size,default 1
         -rls            FLOAT  row text size,default 1
         -ml             FLOAT  low margin,default 12
         -mr             FLOAT  right margin,default 18
         -clt	         STRING  cluster type:both,row,colum or none (default,both)
		 -go			 STRING  go annotation file
USAGE
	 
die $usage if (!$opts{i});

open(EXP,"< $opts{i}");
my @file = <EXP>;
close EXP;
my $count = @file;
my $rowsize = 200/$count;
if ($rowsize < 0.1){
    $rowsize = 0.1;
}


#define defaults
$opts{i}=$opts{i}?abs_path($opts{i}):abs_path($opts{i});
$opts{log}=$opts{log}?$opts{log}:0;
$opts{k}=$opts{k}?$opts{k}:8;
$opts{w}=$opts{w}?$opts{w}:24;
$opts{h}=$opts{h}?$opts{h}:32;
$opts{cls}=$opts{cls}?$opts{cls}:2;
$opts{rls}=$opts{rls}?$opts{rls}:$rowsize;
$opts{ml}=$opts{ml}?$opts{ml}:18;
$opts{mr}=$opts{mr}?$opts{mr}:18;
$opts{clt}=$opts{clt}?$opts{clt}:"both";



my $script_dir = $0;
   $script_dir =~ s/[^\/]+$//;
   chop($script_dir);
   $script_dir = "./" unless ($script_dir);
#print "$script_dir\n";
 
open RCMD, ">$opts{i}.cmd.r";
print RCMD "
input_matrix<-\"$opts{i}\"
logNorm<-$opts{log}
subclustNum<-$opts{k}
width<-$opts{w}
height<-$opts{h}
clsize<-$opts{cls}
rlsize<-$opts{rls}
mlow<-$opts{ml}
mright<-$opts{mr}
cltype<-\"$opts{clt}\" #### both row column none

library(cluster)
library(gplots)
library(Biobase)
matrixFile<-unlist(strsplit(as.character(\"$opts{i}\"),\"/\",fix=T))
outfilename<-paste(getwd(),\"/\",matrixFile[length(matrixFile)],\"-heatmap-outdir\",sep=\"\")
dir.create(outfilename)
data = read.delim(input_matrix, header=T, check.names=F, sep=\"\t\")
rownames(data) = data[,1] # set rownames to gene identifiers
data = data[,2:length(data[1,])] # remove the gene column since its now the rowname value
data = as.matrix(data) # convert to matrix
myheatcol = redgreen(75)[75:1]

if(logNorm!=0){
data = log(data+1,base=logNorm)
centered_data = t(scale(t(data), scale=F)) # center rows, mean substracted
hc_genes = agnes(centered_data, diss=FALSE, metric=\"euclidean\") # cluster genes
hc_samples = hclust(as.dist(1-cor(centered_data, method=\"spearman\")), method=\"complete\") # cluster conditions
final_data<-centered_data
}
if(logNorm==0){
hc_genes = agnes(data,diss=FALSE, metric=\"euclidean\") # cluster genes
hc_samples = hclust(as.dist(1-cor(data, method=\"spearman\")), method=\"complete\") # cluster conditions
final_data<-data
}
if(cltype==\"both\"){Rowv=as.dendrogram(hc_genes);Colv=as.dendrogram(hc_samples)}
if(cltype==\"row\"){Rowv=as.dendrogram(hc_genes);Colv=NA}
if(cltype==\"column\"){Rowv=NV;Colv=as.dendrogram(hc_samples)}
if(cltype==\"none\"){Rowv=NA;Colv=NA}

gene_partition_assignments <- cutree(as.hclust(hc_genes), k=subclustNum);
partition_colors = rainbow(length(unique(gene_partition_assignments)), start=0.4, end=0.95)
gene_colors = partition_colors[gene_partition_assignments]
save(list=ls(all=TRUE), file=\"all.RData\")

### cexRow cexCol
#if(clsize==0){ clsize = 0.2 + 1/log10(nrow(final_data))}
#if(rlsize==0){ rlsize = 0.2 + 1/log10(ncol(final_data))}
### heatmap-plot
heatmap_filename<-paste(outfilename,\"/Heatmap_\",subclustNum,\"subclusters.pdf\",sep=\"\")
pdf(file=heatmap_filename, width=width,height=height, paper=\"special\")
heatmap.2(final_data, dendrogram=cltype,Rowv=Rowv,Colv=Colv,col=myheatcol, RowSideColors=gene_colors, scale=\"none\", density.info=\"none\", trace=\"none\",cexCol=clsize, cexRow=rlsize,lhei=c(0.3,2), lwid=c(2.5,4),margins=c(mlow,mright))
dev.off()


### kmeans-cluster
kmeans_clustering <- kmeans(final_data, centers=subclustNum, iter.max=1000, nstart=subclustNum)
cluster<-kmeans_clustering\$cluster
order_centered_data<-cbind(centered_data,cluster)
order_centered_data<-order_centered_data[order(order_centered_data[,\"cluster\"]),]

order_centered_data_cluster<-order_centered_data

partition_colors = rainbow(length(unique(gene_partition_assignments)), start=0.4, end=0.95)
gene_colors = partition_colors[order_centered_data[,\"cluster\"]]

order_centered_data<-order_centered_data[,1:ncol(order_centered_data)-1]


breaks<-rep(0,subclustNum-1)

rowsnow=0
for(i in 1:length(breaks)){
rowsnow=rowsnow+kmeans_clustering\$size[i]
breaks[i]=rowsnow
}

heatmap_filename<-paste(outfilename,\"/Heatmap_\",subclustNum,\"Kmeansclusters.pdf\",sep=\"\")

pdf(file=heatmap_filename, width=width,height=height, paper=\"special\")
heatmap.2(order_centered_data, dendrogram=\"none\",Rowv=NA,Colv=NA,col=myheatcol,RowSideColors=gene_colors, scale=\"none\", density.info=\"none\", trace=\"none\",cexCol=clsize, cexRow=rlsize,lhei=c(0.1,2),lwid=c(0.8,4),margins=c(mlow,mright))
dev.off()




### sub-cluster
subcluster_out = paste(outfilename,\"/subclusters_fixed_\",subclustNum,sep=\"\")
dir.create(subcluster_out)
gene_names = rownames(final_data)
num_cols = length(final_data[1,])
for (i in 1:subclustNum) {
    partition_i = (cluster == i)
    partition_centered_data = order_centered_data_cluster[order_centered_data_cluster[,\"cluster\"] == i,1:ncol(order_centered_data_cluster)-1]
    # if the partition involves only one row, then it returns a vector instead of a table
    if (sum(partition_i) == 1) {
          dim(partition_centered_data) = c(1,num_cols)
          colnames(partition_centered_data) = colnames(final_data)
          rownames(partition_centered_data) = gene_names[partition_i]
    }
    outfile = paste(subcluster_out, \"/subcluster_\", i, sep='')
    write.table(partition_centered_data, file=outfile, quote=F, sep=\"\t\")
}
files = list.files(subcluster_out)
ncols<-ceiling(length(files)/2)
pdf(file=paste(outfilename,\"/\",\"LineTendency_\",subclustNum,\"subclusters.pdf\",sep=\"\"))
par(mfrow=c(2,2))
par(cex=0.6)
par(mar=c(7,4,4,2))
for (i in 1:length(files)) {
    file = paste(\"subcluster_\",i,sep=\"\");
    data = read.delim(paste(subcluster_out,file,sep=\"/\"), header=T, row.names=1)
    ymin = min(data); ymax = max(data);
    plot_label = paste(file, ', ', length(data[,1]), \" genes\", sep='')
    plot(as.numeric(data[1,]), type='l', ylim=c(ymin,ymax), main=plot_label, col='lightgray', xaxt='n', xlab='', ylab='centered log2(fpkm+1)')
    axis(side=1, at=1:length(data[1,]), labels=colnames(data), las=2)
    for(r in 2:length(data[,1])) {
        points(as.numeric(data[r,]), type='l', col='lightgray')
    }
    points(as.numeric(colMeans(data)), type='o', col=partition_colors[i])
}
dev.off()

";

#system ("R --restore --no-save < $opts{i}.cmd.r");

if(exists $opts{go}){
	chdir $opts{i}."-heatmap-outdir/"."subclusters_fixed_$opts{k}/";

	# my $go_query = PBS::Queue->new({cluster_queue=>"blast2go",'pbs_queue_name'=>"PBS_kmeans"});
	# for(my $i=1; $i<=$opts{k};$i++){
		# $go_query->set_cluster_queue('blast2go');
		# $go_query->set_ppn(1);
		# $go_query->set_memory('2G');
		# my $file = "subcluster_$i";
		# my $cmd = "cut -f 1 $file >$file.list
			# tabletools_select.pl -i $file.list -t ../../$opts{go} -n 1 -head F > $file.GO.list
			# gene-ontology.pl -i $file.GO.list -l 2 -list $file.level2.list  > $file.level2.go.txt
		# ";
		
		# $go_query->addcommond($cmd);
		# $go_query->qsub();	
		
	# }
	# $go_query->wait();
	# $go_query->jointhreads();
	
	# print "joined !!!!!! \n";

	my %go_class;
	for(my $i=1; $i<=$opts{k};$i++){
		open(GO, "<subcluster_$i.level2.go.txt") || die "can't open file subcluster_$i.level2.go.txt";
		while(<GO>){
			my @line = split(/\t/,$_);
			if(! exists $line[4]){
				next;
			}
			if($line[4] =~/GO:[0-9]*/){
				$go_class{$line[0]}{$line[1]}{"subcluster_".$i}{num} = $line[2];
				$go_class{$line[0]}{$line[1]}{"subcluster_".$i}{percent} = $line[3];
				if(exists $go_class{$line[0]}{$line[1]}{avg}){
					$go_class{$line[0]}{$line[1]}{avg} += $go_class{$line[0]}{$line[1]}{"subcluster_".$i}{num}/$opts{k};
				}else{
					$go_class{$line[0]}{$line[1]}{avg} = $go_class{$line[0]}{$line[1]}{"subcluster_".$i}{num}/$opts{k};
				}
			}
		}
		close GO;
	}

	open(OUT, ">subcluster_level2.go.txt");
	print OUT "term_type\tterm";
	for(my $i=1; $i<=$opts{k};$i++){
		print OUT "\tsubcluster_$i";
	}
	print OUT "\n";

	foreach(keys %go_class){
		my $type = $_;
		my %go_sub_class = %{$go_class{$type}};
		foreach(keys %go_sub_class){
			my $gos = $_;
			if($go_class{$type}{$gos}{avg} > 100 || $go_class{$type}{$gos}{avg} <3){
				next;
			}
			print OUT $type."\t".$gos;
			for(my $i=1; $i<=$opts{k};$i++){
				if(exists $go_class{$type}{$gos}{"subcluster_".$i}{num}){
					print OUT "\t".$go_class{$type}{$gos}{"subcluster_".$i}{num};
				}else{
					print OUT "\t0";
				}
			}
			print OUT "\n";
		}
	}
	close OUT;

}


#`R --restore --no-save < cmd.r`;
# system ('rm cmd.r');
