##################easeq#################
#easeq is a windows based visualization package for ChIP-seq data (https://easeq.net/)
#In order to make it work, data must be submitted in the right format. 
#I am sure there are other formats that work, but this is what worked for me. 
#First take your binary files, which were the .sam files converted to binary format. 
#Then convert them to bed files 

bedtools bamtobed  -i A1-CTRL-input_sorted.bam > A1-CTRL-input_sorted.bed
bedtools bamtobed  -i A2-CTRL-input_sorted.bam > A2-CTRL-input_sorted.bed
bedtools bamtobed  -i A1-CTRL-K4me3_sorted.bam  > A1-CTRL-K4me3_sorted.bed 
bedtools bamtobed  -i A2-CTRL-K4me3_sorted.bam  > A2-CTRL-K4me3_sorted.bed 
bedtools bamtobed  -i A1-CTRL-K27me3_sorted.bam > A1-CTRL-K27me3_sorted.bed
bedtools bamtobed  -i A2-CTRL-K27me3_sorted.bam > A2-CTRL-K27me3_sorted.bed
bedtools bamtobed  -i A1-CTRL-PolII_sorted.bam > A1-CTRL-PolII_sorted.bed
bedtools bamtobed  -i A2-CTRL-PolII_sorted.bam > A2-CTRL-PolII_sorted.bed
bedtools bamtobed  -i A1-MB-K4me3_sorted.bam  > A1-MB-K4me3_sorted.bed 
bedtools bamtobed  -i A2-MB-K4me3_sorted.bam  > A2-MB-K4me3_sorted.bed 
bedtools bamtobed  -i A1-MB-K27me3_sorted.bam > A1-MB-K27me3_sorted.bed
bedtools bamtobed  -i A2-MB-K27me3_sorted.bam > A2-MB-K27me3_sorted.bed
bedtools bamtobed  -i A1-MB-PolII_sorted.bam > A1-MB-PolII_sorted.bed
bedtools bamtobed  -i A2-MB-PolII_sorted.bam > A2-MB-PolII_sorted.bed

#Then convert AC's to chromosomes. Note: you can do this in easeq, but this is much faster 

sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' *.bed
for file in *test*; do sort > "${file/%ext/sorted}"; done
