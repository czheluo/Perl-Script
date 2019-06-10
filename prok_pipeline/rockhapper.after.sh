/mnt/ilustre/users/bingxu.liu//workspace/RNA_Pipeline_v16/script/rockhopper2bed.pl  -t paulownia_phytoplasma_transcripts.txt -operon paulownia_phytoplasma_operons.txt -seq  paulownia_phytoplasma
Rscript /mnt/ilustre/users/bingxu.liu/workspace/RNA_Pipeline_v16/script/operons_plot.R operon.xls

bedtools getfasta -fi ../../ref/ref.fa -bed genome.feature.bed -s -name -fo genome.feature.fa
bedtools getfasta -fi ../../ref/ref.fa -bed genome.feature.bed -s -name -fo genome.feature.fa
bedtools getfasta -fi ../../ref/ref.fa -bed genome.feature.bed -s -name -fo genome.feature.fa
bedtools getfasta -fi ../../ref/ref.fa -bed genome.gene.bed -s -name -fo genome.gene.fa
bedtools getfasta -fi ../../ref/ref.fa -bed genome.predicted_RNA.bed -s -name -fo genome.predicted_RNA.fa
bedtools getfasta -fi ../../ref/ref.fa -bed UTR5.bed -s -name -fo UTR5.fa
bedtools getfasta -fi ../../ref/ref.fa -bed UTR3.bed -s -name -fo UTR3.fa
cat /mnt/ilustre/users/xuan.liu/FAQ/eurPro_ss/head genome.predicted_RNA.bed > genome.predicted_RNA.bed.xls
Rscript /mnt/ilustre/users/xuan.liu/FAQ/eurPro_ss/preRNA_Length.R

