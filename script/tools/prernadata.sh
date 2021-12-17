ls $4/$1/$1_$2_$3/$3_S*R1_001.fastq.gz |perl -ne 'chomp;@a=split/\//;$sample=(split(/\_S/,$a[-1]))[0];print$sample,"\t",$_,"\n";' >>fq.list
