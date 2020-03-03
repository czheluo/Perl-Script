#!/usr/bin/perl -w

use warnings;
use Getopt::Long;
use Time::Local;
my %opts;
GetOptions (\%opts,"bam=s","sam=s","ref=s","out=s","bed=s","type=s","h!");

my $usage = <<"USAGE";
        Program : $0
        Discription:DEG_satutation.pl
        Usage:perl $0 [options]
		-bam		aln.bam
		-sam		aln.sam
		-ref		target.fa			
		-bed		ref.fa only used when "type" is genome
		-type		CDS or genome
		-out 		output index
        example:perl $0
USAGE

die $usage if ( !($opts{bam} || $opts{sam}) || !$opts{type} || !$opts{out} );

my $outindex=$opts{out};

my $samfile;
my %gene_read;
my @freq=(5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100);
my @rpkm_bind=(0,0.3,0.6,3.5,15,60);
my %lib_size;
my %gene_rpkm;
my %gene_deviation;
my %gene_cluster;
my %gene_cluster_percent;

my %genome;

# get gene length

if($opts{type} eq "genome"){
	open (BED,"<$opts{bed}") || die "bed annot file needed for genome mapping\n";
	while(<BED>){
		chomp;
		my @line = split(/\t/,$_);
		my $name = $line[3];
		my $chr = $line[0];
		my $start;
		my $end;
		if($line[1] > $line[2]){
			$start = $line[2];
			$end = $line[1];
		}else{
			$start = $line[1];
			$end = $line[2];
		}
		
		$gene_read{$name}{length} = $end - $start +1;
		$gene_read{$name}{chr} = $chr;
		$gene_read{$name}{start} = $start;
		$gene_read{$name}{end} = $end;
		
	}
	
}else{
	&process_cmd("fastalength $opts{ref}> $outindex.length.temp");
	
	open (LEN,"<$outindex.length.temp") || die "Can not open length.temp\n";
	while(<LEN>){
		chomp;
		my @line=split(/\s/,$_);
		my $name=$line[1];
		my $length=$line[0];
		$gene_read{$name}{length} = $length;
	}
	close LEN;
}

#get gene read num
if($opts{bam}){
	&process_cmd("samtools view $opts{bam} >$outindex.sam.temp");
	$samfile="$outindex.sam.temp";
}else{
	$samfile=$opts{sam};
}
open (SAM,"<$samfile") || die "Can not open $samfile\n";
while(<SAM>){
	chomp;
	my @line=split(/\t/,$_);
	my $gene="";
	if($line[2] eq "*"){
		next;
	}else{
		if($opts{type} eq "CDS"){
			$gene=$line[2];
		}else{
			my $chr = $line[2];
			foreach (keys %gene_read){
				my $a=$_;
				if( $gene_read{$a}{chr} eq $chr && $line[3] + 100 > $gene_read{$a}{start} && $line[3] < $gene_read{$a}{end} ){
					$gene = $a;
					last;					
				}
			}
		}
	}
	if($gene eq ""){
		next;
	}
	my $rand=int(rand(100));
	foreach(@freq){
		if ($rand < $_){
			if (exists $gene_read{$gene}{$_}){
				$gene_read{$gene}{$_}+=1;
			}else{
				$gene_read{$gene}{$_}=1;				
			}
		}		
	}
}
close SAM;

#get  libsize
foreach(@freq){
	my $fre=$_;
	foreach(keys %gene_read){
		my $gene = $_;
		if(exists $gene_read{$gene}{$fre}){
		}else{
			$gene_read{$gene}{$fre}=0;
		}
		if(exists $lib_size{$fre}){
			$lib_size{$fre} += $gene_read{$gene}{$fre};
		}else{
			$lib_size{$fre} = $gene_read{$gene}{$fre};	
		}		
	}
}

#caculate rpkm
open (RPKM,">$outindex.rpkm.xls") || die "Can not open rpkm.xls\n";
foreach(keys %gene_read){
	my $gene = $_;
	print RPKM $gene;
	foreach(@freq){
		my $fre=$_;
		if($lib_size{$fre}==0){
			$lib_size{$fre}=1;
		}
		$gene_rpkm{$gene}{$fre}=($gene_read{$gene}{$fre}*1000000000)/($lib_size{$fre}*$gene_read{$gene}{length});
		print RPKM "\t".$gene_rpkm{$gene}{$fre};
	}
	print RPKM "\n";
}
close RPKM;

#caculate deviation
open (DEV,">$outindex.deviation.xls") ||die "Can not open deviation.xls\n";
foreach(keys %gene_rpkm){
	my $gene = $_;
	print DEV $gene;
	foreach(@freq){
		my $fre=$_;
		if ($gene_rpkm{$gene}{100} == 0){
			$gene_deviation{$gene}{$fre} = 1;
		}else{
			$gene_deviation{$gene}{$fre} = abs($gene_rpkm{$gene}{$fre} - $gene_rpkm{$gene}{100})/$gene_rpkm{$gene}{100};
		}
		print DEV "\t".$gene_deviation{$gene}{$fre};
	}
	print DEV "\n";
}
close DEV;

#cluster bindary
my $num=1;
foreach(@rpkm_bind){
	my $left=$_;	
	my $right="max";
	my $name="";
	my $des="";
	if (exists $rpkm_bind[$num]){
		$right=$rpkm_bind[$num];
		$name=$num;
		$des="[".$left."-".$right.")";
	}else{
		$name=$num;
		$des='>='.$left;
	}
	$gene_cluster{$name}{left}=$left;
	$gene_cluster{$name}{right}=$right;
	$gene_cluster{$name}{num}=0;
	$gene_cluster{$name}{des}=$des;

	$num++;	
}

#get cluster num
foreach(keys %gene_deviation){
	my $gene=$_;
	if ($gene_rpkm{$gene}{100}==0){
			next;
	}
	foreach(keys %gene_cluster){
		my $name=$_;		
		if($gene_cluster{$name}{right} eq "max" && $gene_rpkm{$gene}{100} >= $gene_cluster{$name}{left}){
			$gene_cluster{$name}{num}++;
			foreach(@freq){
				my $fre=$_;
				if ($gene_deviation{$gene}{$fre}<=0.15){
					if (exists $gene_cluster{$name}{$fre}){
						$gene_cluster{$name}{$fre} += 1;
					}else{
						$gene_cluster{$name}{$fre} = 1;
					}
				}
			}
		}elsif($gene_rpkm{$gene}{100} >= $gene_cluster{$name}{left} && $gene_rpkm{$gene}{100} < $gene_cluster{$name}{right}){
			$gene_cluster{$name}{num}++;
			foreach(@freq){
				my $fre=$_;
				if ($gene_deviation{$gene}{$fre}<=0.15){
					if (exists $gene_cluster{$name}{$fre}){
						$gene_cluster{$name}{$fre} += 1;
					}else{
						$gene_cluster{$name}{$fre} = 1;
					}
				}
			}
		}		
	}	
}

open (CLUSTER,">$outindex.cluster_percent.xls") ||die "Can not open cluster_percent.xls\n";

foreach(sort keys %gene_cluster){
	my $name=$_;
	print CLUSTER $gene_cluster{$name}{des};
	foreach(@freq){
		my $fre=$_;
		if($gene_cluster{$name}{num}==0){
			$gene_cluster_percent{$name}{$fre}=0;
		}else{
			if(!(exists $gene_cluster{$name}{$fre})){
				$gene_cluster{$name}{$fre}=0;
			}
			$gene_cluster_percent{$name}{$fre}=$gene_cluster{$name}{$fre}/$gene_cluster{$name}{num};
		}
		print CLUSTER "\t".$gene_cluster_percent{$name}{$fre};
	}
	print CLUSTER "\n";
}
close CLUSTER;

open (RSCRIPT,">$outindex.saturation.R") ||die "Can not open saturation.R\n";
print RSCRIPT 'x=c(5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100)'."\n";
print RSCRIPT 'col=rainbow(6)'."\n";
print RSCRIPT 'pdf(file="'.$outindex.'.saturation.pdf")'."\n";

my @legend;

foreach(sort keys %gene_cluster_percent){
	my $name=$_;
	my @per;
	my $leg='"'.$gene_cluster{$name}{des}."\tnum=".$gene_cluster{$name}{num}.'"';
	push(@legend,$leg);
	foreach(@freq){
		my $fre=$_;
		push(@per,$gene_cluster_percent{$name}{$fre});
	}
	print RSCRIPT 'y=c('.join(",",@per).')'."\n";
	if($name!=1){
		print RSCRIPT 'par(new=TRUE)'."\n";
		print RSCRIPT 'plot(x, y, axes=FALSE,ylim=c(0,1),xlim = c(0,110), xlab="", ylab="",pch=17,col=col['.$name.'])'."\n";
	}else{
		print RSCRIPT 'plot(x, y, pch=17,col=col['.$name.'],ylim=c(0,1),xlim = c(0,110),xlab="mapped reads(%)", ylab="genes rpkm deviation within 15% of final value")'."\n";
		print RSCRIPT 'grid(col = "gray")'."\n";
	}
	print RSCRIPT 'lines(x,y,col=col['.$name.'])'."\n";
}

print RSCRIPT 'legend(90, 0.12, legend=c('.join(",",@legend).'), cex=0.5, col=col,pch=17,lty=1)'."\n";
print RSCRIPT 'dev.off()'."\n";
close RSCRIPT;

process_cmd("R --no-save <  $outindex.saturation.R");


sub process_cmd {
    my ($cmd) = @_;
    print "CMD: $cmd\n";
    my $ret = system($cmd);
    if ($ret){
        die "Error, cmd: $cmd died with ret ($ret) ";
    }
    return;
}


