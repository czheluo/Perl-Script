ls $2/*$1_S*R1_001.fastq.gz |perl -ne 'chomp;@a=split/\//;$name=(split(/\_S/,$a[-1]))[0];$fq2=$_;$fq2=~s/\_R1\_001/\_R2\_001/s;print$name,"\t",$_,"\t",$fq2,"\n";' >>fq.list
