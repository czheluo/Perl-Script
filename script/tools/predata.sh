ls $3/$1/*$2*/*_R1_001.fastq.gz |perl -ne 'chomp;@a=split/\//;$lib=(split(/\_/,$a[-2]))[1];$fq2=$_;$fq2=~s/\_R1\_001/\_R2\_001/s;print$a[-3],"\t",$lib,"\t",$_,"\t",$fq2,"\n";' >>fq.list
