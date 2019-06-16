#! /usr/bin/perl -w

use strict;
use Getopt::Long;
use Config::IniFiles;
my ($cfg,$fa,$help,$min,$max);
GetOptions(
    	"cfg:s"         => \$cfg,
	"fa:s"          => \$fa,
	"min:i"		=> \$min,
	"max:i"		=> \$max,
	"h!"            => \$help,
);
$min=($min)?$min:18;
$max=($max)?$max:32;

if (!( $cfg && $fa) || $help) {
	&usage;
	exit;
}

my (%loc,%length,%realname,$sample,$abs,$num,$seq);

## store sample names--3 letters names into %realname
my $config = Config::IniFiles->new(-file => $cfg);
my @names=$config->Parameters("FASTA");
for my $n (@names){
	if($config->SectionExists("NAME")&& $config->val('NAME',$n)){
		$sample=$config->val('NAME',$n);
		$realname{$n}=$sample;
	}else{
		$sample=$n;
		$realname{$n}=$sample;
	}
}

## read fa file and store base infor
open (IN,"< $fa") || die $!;
while (<IN>){
	chomp;
	if (/^>(\w+)_\d+_x(\d+)$/){
		$abs=$1;
		$num=$2;
	}else{
		$seq=$_;
		my @seque=split //,$seq;
	#	print $seque[0];exit;
		$length{$realname{$abs}}{scalar @seque}{$seque[0]}+=$num;
		for (my $i=0;$i<scalar @seque;$i++){
			$loc{$realname{$abs}}{$i+1}{$seque[$i]}+=$num;
		}
	}
}

## out first bias
my @orders=("A","G","C","T");
for my $f (keys %length){
	open OUT,">$f\_first_bias.xls" || die $!;
	print OUT "length\tA\tG\tC\tU\n";
	for (my $m=$min;$m<=$max;$m++){
		print OUT $m;
		for my $o(@orders){
			if (exists $length{$f}{$m}{$o}){
				print OUT "\t$length{$f}{$m}{$o}";
			}else{
				print OUT "\t0";
			}
		}
		print OUT "\n";
	}
	close OUT;
}

## out loc bias
for my $f (keys %loc){
	open OUT,">$f\_loc_bias.xls" || die $!;
	print OUT "loc\tA\tG\tC\tU\n";
	for (my $m=1;$m<=$max;$m++){
		print OUT $m;
		for my $o(@orders){
			if (exists $loc{$f}{$m}{$o}){
				print OUT "\t$loc{$f}{$m}{$o}";
			}else{
				print OUT "\t0";
			}
		}
		print OUT "\n";
	}
	close OUT;
}

## print Rscript
open RS,">bias.r" || die $!;
print RS 
"PER<-function(x){
sumx<-sum(x)
y<-x/sumx
return(y)
}
";
for my $f (keys %loc){
	my $Rlocs=<<RL;
loc<-read.table("$f\_loc_bias.xls",sep="\\t",header=T)
data<-as.data.frame(loc[,2:5])
p<-apply(data,1,PER)
p[is.na(p)]<-0
colnames(p)<-c(1:$max)
write.table(t(p),"$f\_loc_bias_per.xls",sep="\\t",row.names=T,col.names=NA,quote=F)
pdf("$f\_loc_bias.pdf",10,6)
par(pin=c(5,1.8),fig=c(0,0.95,0,1),xpd=T,cex.axis=0.8)
barplot(p,col=c("blue","yellow","red","purple"),yaxt="n",ann=FALSE)
title(main="miRNA nucleotide bias at each position")
axis(2,at=seq(0,1,0.25),labels=seq(0,100,25))
legend($max+6,1,c("A","G","C","U"),col=c("blue","yellow","red","purple"),pch=c(15),bty="n",cex=0.7)
mtext("Percent(%)",side=2,las=0,cex.lab=0.7,line=2)
mtext("Position",side=1,las=0,cex.lab=0.7,line=2)
segments(-1.5,0,$max+5,0)
dev.off()
RL

	my $Rbias=<<BIAS;
bias<-read.table("$f\_first_bias.xls",sep="\\t",header=T)
data<-as.data.frame(bias[,2:5])
p<-apply(data,1,PER)
p[is.na(p)]<-0
colnames(p)<-c($min:$max)
write.table(t(p),"$f\_first_bias_per.xls",sep="\\t",row.names=T,col.names=NA,quote=F)
pdf("$f\_first_bias.pdf")
par(pin=c(5,1.8),fig=c(0,0.95,0,1),xpd=T,cex.axis=0.8)
barplot(p,col=c("blue","yellow","red","purple"),yaxt="n",ann=FALSE)
title(main="miRNA first nucleotide bias")
axis(2,at=seq(0,1,0.25),labels=seq(0,100,25))
legend($max-$min+4,1,c("A","G","C","U"),col=c("blue","yellow","red","purple"),pch=c(15),bty="n",cex=0.7)
mtext("Percent(%)",side=2,las=0,cex.lab=0.7,line=2)
mtext("Length",side=1,las=0,cex.lab=0.7,line=2)
segments(-1,0,$max-$min+4,0)
dev.off()
BIAS
	print RS "$Rlocs\n$Rbias\n";	

}
close RS;

`Rscript bias.r`;

sub usage {
	die
	"Usage: perl $0 [options]
	This program is used for miRNA base bias analysis.
	-cfg	FILE Config file for uniq
	-fa	FILE merge.uniq.fa
	-min	NUM  the shortest length
	-max    NUM  the longest length
	-help	this information
";
}
