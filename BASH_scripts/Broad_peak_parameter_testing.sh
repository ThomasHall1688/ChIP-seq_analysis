############################################################
############parameter testing for broad peaks###############
############################################################
#It was hard to tell wich was the best cut offs to use to call the broad peaks for K27me3 and K27, so I used the below commands to decide which had the greatest clustering power. 
#I would call the peaks, then count the peaks (first entry for wc gives row count, which gives the amound of peaks). Went from 280k to ~20k
macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3 -B --nomodel --broad --broad-cutoff 0.05 --extsize 166 --SPMR --tempdir /home/workspace/thall/tmp
wc A2-MB-K27me3_peaks.xls
macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3 -B --nomodel --broad --broad-cutoff 0.05 --extsize 166 --SPMR --tempdir /home/workspace/thall/tmp
wc A2-MB-K27me3_peaks.xls
macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3 -B --nomodel --broad --broad-cutoff 0.005 --extsize 166 --SPMR --tempdir /home/workspace/thall/tmp
wc A2-MB-K27me3_peaks.xls
macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3 -B --nomodel --broad --broad-cutoff 0.005 --extsize 166 --SPMR --tempdir /home/workspace/thall/tmp
wc A2-MB-K27me3_peaks.xls
macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3.sorted.BAM -B -q 0.05 --nomodel --extsize 164 --SPMR --tempdir /home/workspace/thall/tmp
wc A2-MB-K27me3_peaks.xls
macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3.sorted.BAM -B -q 0.05 --nomodel --extsize 164 --SPMR --tempdir /home/workspace/thall/tmp
wc A2-MB-K27me3_peaks.xls

macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3 -B --nomodel --broad --broad-cutoff 0.05 --extsize 166 --SPMR --tempdir /home/workspace/thall/tmp
wc A2-MB-K27me3_peaks.xls
macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3 -B --nomodel --broad --broad-cutoff 0.05 --extsize 166 --SPMR --tempdir /home/workspace/thall/tmp
wc A2-MB-K27me3_peaks.xls
macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3 -B --nomodel --broad --broad-cutoff 0.005 --extsize 166 --SPMR --tempdir /home/workspace/thall/tmp
wc A2-MB-K27me3_peaks.xls
macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3 -B --nomodel --broad --broad-cutoff 0.005 --extsize 166 --SPMR --tempdir /home/workspace/thall/tmp
wc A2-MB-K27me3_peaks.xls
macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3.sorted.BAM -B -q 0.05 --nomodel --extsize 164 --SPMR --tempdir /home/workspace/thall/tmp
wc A2-MB-K27me3_peaks.xls
macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3.sorted.BAM -B -q 0.05 --nomodel --extsize 164 --SPMR --tempdir /home/workspace/thall/tmp
wc A2-MB-K27me3_peaks.xls
