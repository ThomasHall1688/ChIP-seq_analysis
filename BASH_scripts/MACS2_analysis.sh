#######################################################################################################
##########################################MACS 2#######################################################
#######################################################################################################
#MACS 2 is the primary software I used to call the peaks 

#Example for regular peak calling:	macs2 callpeak -t ChIP.bam -c Control.bam -f BAM -g hs -n test -B -q 0.01
#Example for broad peak calling:		macs2 callpeak -t ChIP.bam -c Control.bam --broad -g hs --broad-cutoff 0.1


#There are seven major functions available in MACS serving as sub-commands.

#callpeak:	Main MACS2 Function to Call peaks from alignment results.
#bdgpeakcall:	Call peaks from bedGraph output.
#bdgbroadcall:	Call broad peaks from bedGraph output.
#bdgcmp:	Deduct noise by comparing two signal tracks in bedGraph.
#bdgdiff:	Differential peak detection based on paired four bedgraph files.
#filterdup:	Remove duplicate reads at the same position, then convert acceptable format to BED format.
#predictd:	Predict d or fragment size from alignment results.
#pileup:	Pileup aligned reads with a given extension size (fragment size or d in MACS language). Note there will be no step for duplicate reads filtering or sequencing depth scaling, so you may need to do certain post- processing.
#randsample:	Randomly sample number/percentage of total reads.
#refinepeak:	(Experimental) Take raw reads alignment, refine peak summits and give scores measuring balance of forward- backward tags. Inspired by SPP.

#macs2 callpeak arguements

#-t			 This is the only REQUIRED parameter for MACS. File can be in any supported format specified by --format option. Check --format for detail. If you have more than one alignment files, you can specify them as `-t A B C`. MACS will pool up all these files together.
#-c 		 The control or mock data file. Please follow the same direction as for -t/--treatment
#-n 		 The name string of the experiment. MACS will use this string NAME to create output files like 'NAME_peaks.xls', 'NAME_negative_peaks.xls', 'NAME_peaks.bed' , 'NAME_summits.bed', 'NAME_model.r' and so on. So please avoid any confliction between these filenames and your existing files.
#--outdir 	 MACS2 will save all output files into speficied folder for this option.
#-f 		 Format of tag file, can be "ELAND", "BED", "ELANDMULTI", "ELANDEXPORT", "ELANDMULTIPET" (for pair-end tags), "SAM", "BAM", "BOWTIE", "BAMPE" or "BEDPE". Default is "AUTO" which will allow MACS to decide the format automatically. "AUTO" is also usefule when you combine different formats of files. 
			 #Note that MACS can't detect "BAMPE" or "BEDPE" format with "AUTO", and you have to implicitly specify the format for "BAMPE" and "BEDPE".
#-g 		 It's the mappable genome size or effective genome size which is defined as the genome size which can be sequenced. Because of the repetitive features on the chromsomes, the actual mappable genome size will be smaller than the original size, about 90% or 70% of the genome size. 
			 #The default hs -- 2.7e9 is recommended for UCSC human hg18 assembly. hs is also fine for bovine. 		 
#-n			 The name string of the experiment. MACS will use this string NAME to create output files like 'NAME_peaks.xls', 'NAME_negative_peaks.xls', 'NAME_peaks.bed' , 'NAME_summits.bed', 'NAME_model.r' and so on. So please avoid any confliction between these filenames and your existing files.
#-q 		 The qvalue (minimum FDR) cutoff to call significant regions. Default is 0.05. For broad marks, you can try 0.05 as cutoff. Q-values are calculated from p-values using Benjamini-Hochberg procedure.

#Install MACS2 
pip install MACS2

#To get a uniform extension size for running callpeak, run predictd. These valuse are needed for the differential peak calling. Ideally they would be the same, but if A1-CTRL is 160 and A1-MB is 150, use 155 for both. 
 
#A1-CTRL-K4me3
macs2 predictd -i A1-CTRL-K4me3.sorted.BAM
#A1-CTRL-K27me3
macs2 predictd -i A1-CTRL-K27me3.sorted.BAM
#A1-CTRL-K27me3
macs2 predictd -i A1-CTRL-K27me3.sorted.BAM

#######################################################################################################################
############################################# Peak calling ############################################################
#######################################################################################################################

# * -B --SPMR asks MACS2 to generate pileup signal file of 'fragment pileup per million reads' in bedGraph format.
# extsize must be determined via the predictd function. This is important for track construction downstream. --nomodel allows for the ext size to be used. 
# In trying to figure out the best broad peak call cut off, I actually used WC on the peaklist to determine which had the fewer peaks. broad cutoff @ 0.05 for A1-CTRL-K27me3 had 180677 wheras 0.1 had 282706 and 0.01 had 76133, 0.005 had 74195 and 0.001 had 21451
# --tempdir is needed as if you run peak calls all at one on multiple terminals, which I do alot, then it will fill your /tmp directory in no time, which is very bad. with --tempdir I just direct it elsewhere and then clean it out. 

#A1-CTRL-K4me3
macs2 callpeak -t A1-CTRL-K4me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAMPE -g hs -n A1-CTRL-K4me3 -B -q 0.01 --nomodel --extsize 164 --SPMR --tempdir /home/workspace/thall/tmp #normal peak 

#A1-CTRL-K27me3
macs2 callpeak -t A1-CTRL-K27me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-CTRL-K27me3 -B --nomodel --broad --broad-cutoff 0.005 --extsize 171 --SPMR --tempdir /home/workspace/thall/tmp #broadpeak

#A1-CTRL-K27me3
macs2 callpeak -t A1-CTRL-K27me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-CTRL-K27me3 -B --nomodel --broad --broad-cutoff 0.005 --extsize 159 --SPMR --tempdir /home/workspace/thall/tmp #broadpeak

#######################################################################################################################
###################################### Differential peak calling ######################################################
#######################################################################################################################

# -l : this should be the middle ground between you condition 1 (control) and condition 2 (infection). i.e ext size for ctrl was 167 and infection was 171, so -l is 170.5 (I round up)
#Here, we want to name our ouput differently. This is because we cannot use --SPMR, as it does not work with bdgdiff and we need the files with SPMR for the track building. Here, I give the affix _diff

#A1-CTRL-K4me3
macs2 callpeak -t A1-CTRL-K4me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-CTRL-K4me3_diff -B -q 0.01 --nomodel --extsize 164 --SPMR --tempdir /home/workspace/thall/tmp #normal peak 

#A1-CTRL-K27me3
macs2 callpeak -t A1-CTRL-K27me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-CTRL-K27me3_diff -B --nomodel --broad --broad-cutoff 0.005 --extsize 171  --tempdir /home/workspace/thall/tmp #broad peak 

#A1-CTRL-K27me3
macs2 callpeak -t A1-CTRL-K27me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-CTRL-K27me3_diff -B --nomodel --broad --broad-cutoff 0.005 --extsize 159  --tempdir /home/workspace/thall/tmp #broad peak 

#The purpose of this step is to do a three ways comparisons to find out where in the genome has differential enrichment between two conditions. A basic requirement is that this region should be at least enriched in either condition.
#A log10 likelihood ratio cutoff (C) will be applied in this step. Three types of differential regions will be reported: 1. those having more enrichment in condition 1 over condition 2 ( cond1_ChIP > cond1_Control and cond1_ChIP > cond2_ChIP ); 
#																														 2. those having more enrichment in condition 2 over condition 1 ( cond2_ChIP > cond2_Control and cond2_ChIP > cond1_ChIP ); 
#																														 3. those having similar enrichment in both conditions ( cond1_ChIP > cond1_Control and cond2_ChIP > cond2_Control and cond1_ChIP ≈ cond1_ChIP 
#Your d1 and d2 are obtained by looking at your ouput from the peak call. In the manual, it states that the values here are tags after filtering in control. This is wrong for this. It should be Tags after filtering treatment.  

#A1-CTRL-K4me3
macs2 bdgdiff --t1 A1-CTRL-K4me3_treat_pileup.bdg --c1 A1-CTRL-K4me3_control_lambda.bdg --t2 A1-MB-K4me3_treat_pileup.bdg --c2 A1-MB-K4me3_control_lambda.bdg --d1 --d2 -l 164 --o-prefix diff_c1_vs_c2_A1

#A1-CTRL-K27me3
macs2 bdgdiff --t1 A2-CTRL-K27me3_treat_pileup.bdg --c1 A2-CTRL-K27me3_control_lambda.bdg --t2 A2-MB-K27me3_treat_pileup.bdg --c2 A2-MB-K27me3_control_lambda.bdg --d1 --d2 -l 166 --o-prefix diff_c1_vs_c2_A1

#A1-CTRL-K27me3
macs2 bdgdiff --t1 A1-CTRL-K27me3_treat_pileup.bdg --c1 A1-CTRL-K27me3_control_lambda.bdg --t2 A1-MB-K27me3_treat_pileup.bdg --c2 A1-MB-K27me3_control_lambda.bdg --d1 --d2  -l 159 --o-prefix diff_c1_vs_c2_A1

#######################################################################################################################
########################################Signal track building##########################################################
#######################################################################################################################

#MACS v2 main command 'macs2 callpeak' can generate signal tracks internally, for example p-value tracks if p-value is used as cutoff, or q-value track if q-value is used as cutoff, MACS v2 will only keep such signal tracks in memory 
#instead of harddisk in order to save time and disk space. To generate appropriate signal track to profile transcription factor or histone modification enrichment levels over whole genome, users need to use another command 
#'macs2 bdgcmp' on the bedGraph files generated by 'macs2 callpeak'. This will require the pileup and control lambda from the peak call. 
#Here we will build the fold enrichment and log liklehood ratio tracks for each animal for each condition.  

#A1-CTRL-K4me3
macs2 bdgcmp -t A1-CTRL-K4me3_treat_pileup.bdg -c A1-CTRL-K4me3_control_lambda.bdg -o A1-CTRL-K4me3_FE.bdg -m FE
macs2 bdgcmp -t A1-MB-K4me3_treat_pileup.bdg -c A1-MB-K4me3_control_lambda.bdg -o A2-MB-K4me3_logLR.bdg -m logLR -p 0.00001

#A1-CTRL-K4me3
macs2 bdgcmp -t A1-CTRL-K4me3_treat_pileup.bdg -c A1-CTRL-K4me3_control_lambda.bdg -o A1-CTRL-K4me3_FE.bdg -m FE
macs2 bdgcmp -t A1-MB-K4me3_treat_pileup.bdg -c A1-MB-K4me3_control_lambda.bdg -o A2-MB-K4me3_logLR.bdg -m logLR -p 0.00001

#A1-CTRL-K4me3
macs2 bdgcmp -t A1-CTRL-K4me3_treat_pileup.bdg -c A1-CTRL-K4me3_control_lambda.bdg -o A1-CTRL-K4me3_FE.bdg -m FE
macs2 bdgcmp -t A1-MB-K4me3_treat_pileup.bdg -c A1-MB-K4me3_control_lambda.bdg -o A2-MB-K4me3_logLR.bdg -m logLR -p 0.00001

#######IGV settings########

# K4 FE IGV settings. A1 CTRL = Green, A2 CTRL = Red, A1 MB = Yellow/Green, A2 MB = Blue 
IGV settings : 0 min
			   1.5 mid
			   3 max
FE line track 

run xming and x11 fowarding 
Load in FE tracks and overlay 
height to 300

#######################################################################################################################
############################################# Conversion ##############################################################
#######################################################################################################################


#Need to convert NC and AC numbers. Without this, IGV wont align the track to the genome. I beleive there is a better way to do this, but havent found it yet. 
#A1-CTRL-K4me3
awk '!/NW_/' A1-CTRL-K4me3_FE.bdg > A1-CTRL-K4me3_FE_NoN.bdg 
awk '!/NC/' A1-CTRL-K4me3_FE_NoN.bdg > A1-CTRL-K4me3_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-CTRL-K4me3_FE_NoN.bdg

awk '!/NW_/' A1-CTRL-K4me3_FE.bdg > A1-CTRL-K4me3_FE_NoN.bdg 
awk '!/NC/' A1-CTRL-K4me3_FE_NoN.bdg > A1-CTRL-K4me3_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-CTRL-K4me3_FE_NoN.bdg

#A1-CTRL-K27me3

#Convert BEDGRAPH to BIGWIG for IGV visualization. bedClip and bedGraphToBigWig must be in the same directory
bash bdg2bw A2-MB-K4me3_FE_chr.bdg chrominfo.len
bash bdg2bw A2-MB-K4me3_logLR_chr.bdg chrominfo.len

#the code for the bdg2bw is as follows:

#!/bin/bash

# check commands: slopBed, bedGraphToBigWig and bedClip

which bedtools &>/dev/null || { echo "bedtools not found! Download bedTools: <http://code.google.com/p/bedtools/>"; exit 1; }
which ./bedGraphToBigWig &>/dev/null || { echo "bedGraphToBigWig not found! Download: <http://hgdownload.cse.ucsc.edu/admin/exe/>"; exit 1; }
which ./bedClip &>/dev/null || { echo "bedClip not found! Download: <http://hgdownload.cse.ucsc.edu/admin/exe/>"; exit 1; }

# end of checking

if [ $# -lt 2 ];then
    echo "Need 2 parameters! <bedgraph> <chrom info>"
    exit
fi

F=$1
G=$2

bedtools slop -i ${F} -g ${G} -b 0 | ./bedClip stdin ${G} ${F}.clip

LC_COLLATE=C sort -k1,1 -k2,2n ${F}.clip > ${F}.sort.clip

./bedGraphToBigWig ${F}.sort.clip ${G} ${F/bdg/bw}

rm -f ${F}.clip ${F}.sort.clip


# K4 FE IGV settings. A1 CTRL = Green, A2 CTRL = Red, A1 MB = Yellow/Green, A2 MB = Blue 
IGV settings : 0 min
			   1.5 mid
			   3 max
FE line track 

run xming and x11 fowarding 
Load in FE tracks and overlay 
height to 300


#######################################################################################################################
############################################ code work ###############################################################
#######################################################################################################################
#This section includes the actual lines of code used for the pipeline. If I find a better way, I will list it. 

################################################################################
############################### K4 #############################################
################################################################################

#Rough chip seq K27 work. This was the line for line chunk of code used for calling K27
cd /home/workspace/thall/CHiP-seq/K4_work

#These numbers are used for the differential peak calling. Remember to use the average of the ext when calling the peaks. 
A1-CTRL-K4me3 - extsize 165
tags in treatment after filtering : 
A1-MB-K4me3 - extsize 166
tags in treatment after filtering : 
A2-CTRL-K4me3 - extsize 161
tags in treatment after filtering :
A2-MB-K4me3 - extsize 166
tags in treatment after filtering :

#To get a uniform extension size for running callpeak, run predictd. These valuse are needed for the differential peak calling. Ideally they would be the same, but if A1-CTRL is 160 and A1-MB is 150, use 155 for both. 
macs2 predictd -i A1-CTRL-K4me3.sorted.BAM
macs2 predictd -i A1-MB-K4me3.sorted.BAM
macs2 predictd -i A2-CTRL-K4me3.sorted.BAM
macs2 predictd -i A2-MB-K4me3.sorted.BAM

###########peak calling################## 

#A1-CTRL-K4me3
macs2 callpeak -t A1-CTRL-K4me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-CTRL-K4me3 -B -q 0.01 --nomodel --extsize 164 --SPMR --tempdir /home/workspace/thall/tmp 

#A1-MB-K4me3
macs2 callpeak -t A1-MB-K4me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-MB-K4me3 -B -q 0.01 --nomodel --extsize  --SPMR --tempdir /home/workspace/thall/tmp 

#A2-CTRL-K4me3
macs2 callpeak -t A2-CTRL-K4me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-CTRL-K4me3 -B -q 0.01 --nomodel --extsize  --SPMR --tempdir /home/workspace/thall/tmp

#A2-MB-K4me3
macs2 callpeak -t A2-MB-K4me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K4me3 -B -q 0.01 --nomodel --extsize  --SPMR --tempdir /home/workspace/thall/tmp 

#######differential peak calling#########

#A1-CTRL-K4me3
macs2 callpeak -t A1-CTRL-K4me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-CTRL-K4me3_diff -B --nomodel --extsize 164  --tempdir /home/workspace/thall/tmp

#A1-MB-K4me3
macs2 callpeak -t A1-MB-K4me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-MB-K4me3_diff -B --nomodel  --extsize   --tempdir /home/workspace/thall/tmp

#A2-CTRL-K4me3
macs2 callpeak -t A2-CTRL-K4me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-CTRL-K4me3_diff -B --nomodel --extsize  --tempdir /home/workspace/thall/tmp

#A2-MB-K4me3
macs2 callpeak -t A2-MB-K4me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K4me3_diff -B --nomodel --extsize   --tempdir /home/workspace/thall/tmp

#######peak comparison#################
#A1 
macs2 bdgdiff --t1 A1-CTRL-K27me3_treat_pileup.bdg --c1 A1-CTRL-K27me3_control_lambda.bdg --t2 A1-MB-K27me3_treat_pileup.bdg --c2 A1-MB-K27me3_control_lambda.bdg --d1 --d2  -l  --o-prefix diff_c1_vs_c2_A1

#A2
macs2 bdgdiff --t1 A2-CTRL-K27me3_treat_pileup.bdg --c1 A2-CTRL-K27me3_control_lambda.bdg --t2 A2-MB-K27me3_treat_pileup.bdg --c2 A2-MB-K27me3_control_lambda.bdg --d1 --d2  -l  --o-prefix diff_c1_vs_c2_A1

##############Track building#############

#A1-CTRL-K4me3
macs2 bdgcmp -t A1-CTRL-K4me3_treat_pileup.bdg -c A1-CTRL-K4me3_control_lambda.bdg -o A1-CTRL-K4me3_FE.bdg -m FE
macs2 bdgcmp -t A1-CTRL-K4me3_treat_pileup.bdg -c A1-CTRL-K4me3_control_lambda.bdg -o A1-CTRL-K4me3_logLR.bdg -m logLR -p 0.00001

#A1-MB-K4me3
macs2 bdgcmp -t A1-MB-K4me3_treat_pileup.bdg -c A1-MB-K4me3_control_lambda.bdg -o A1-MB-K4me3_FE.bdg -m FE
macs2 bdgcmp -t A1-MB-K4me3_treat_pileup.bdg -c A1-MB-K4me3_control_lambda.bdg -o A1-MB-K4me3_logLR.bdg -m logLR -p 0.00001

#A2-CTRL-K4me3
macs2 bdgcmp -t A2-CTRL-K4me3_treat_pileup.bdg -c A2-CTRL-K4me3_control_lambda.bdg -o A2-CTRL-K4me3_FE.bdg -m FE
macs2 bdgcmp -t A2-CTRL-K4me3_treat_pileup.bdg -c A2-CTRL-K4me3_control_lambda.bdg -o A2-CTRL-K4me3_logLR.bdg -m logLR -p 0.00001

#A2-MB-K4me3
macs2 bdgcmp -t A2-MB-K4me3_treat_pileup.bdg -c A2-MB-K4me3_control_lambda.bdg -o A2-MB-K4me3_FE.bdg -m FE
macs2 bdgcmp -t A2-MB-K4me3_treat_pileup.bdg -c A2-MB-K4me3_control_lambda.bdg -o A2-MB-K4me3_logLR.bdg -m logLR -p 0.00001


###############conversion############## 
#Convert FE ac's 
#A1-CTRL-K4me3
awk '!/NW_/' A1-CTRL-K4me3_FE.bdg > A1-CTRL-K4me3_FE_NoN.bdg 
awk '!/NC/' A1-CTRL-K4me3_FE_NoN.bdg > A1-CTRL-K4me3_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-CTRL-K4me3_FE_NoN.bdg

#A1-MB-K4me3
awk '!/NW_/' A1-MB-K4me3_FE.bdg > A1-MB-K4me3_FE_NoN.bdg 
awk '!/NC/' A1-MB-K4me3_FE_NoN.bdg > A1-MB-K4me3_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-MB-K4me3_FE_NoN.bdg

#A2-CTRL-K4me3
awk '!/NW_/' A2-CTRL-K4me3_FE.bdg > A2-CTRL-K4me3_FE_NoN.bdg 
awk '!/NC/' A2-CTRL-K4me3_FE_NoN.bdg > A2-CTRL-K4me3_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A2-CTRL-K4me3_FE_NoN.bdg

#A2-MB-K4me3
awk '!/NW_/' A2-MB-K4me3_FE.bdg > A2-MB-K4me3_FE_NoN.bdg 
awk '!/NC/' A2-MB-K4me3_FE_NoN.bdg > A2-MB-K4me3_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A2-MB-K4me3_FE_NoN.bdg

#convert logLR ac's
#A1-CTRL-K4me3
awk '!/NW_/' A1-CTRL-K4me3_logLR.bdg > A1-CTRL-K4me3_logLR_NoN.bdg 
awk '!/NC/' A1-CTRL-K4me3_logLR_NoN.bdg > A1-CTRL-K4me3_logLR_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-CTRL-K4me3_logLR_chr.bdg

#A1-MB-K4me3
awk '!/NW_/' A1-MB-K4me3_logLR.bdg > A1-MB-K4me3_logLR_NoN.bdg 
awk '!/NC/' A1-MB-K4me3_logLR_NoN.bdg > A1-MB-K4me3_logLR_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-MB-K4me3_logLR_chr.bdg

#A2-CTRL-K4me3
awk '!/NW_/' A2-CTRL-K4me3_logLR.bdg > A2-CTRL-K4me3_logLR_NoN.bdg 
awk '!/NC/' A2-CTRL-K4me3_logLR_NoN.bdg > A2-CTRL-K4me3_logLR_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A2-CTRL-K4me3_logLR_chr.bdg

#A2-MB-K4me3
awk '!/NW_/' A2-MB-K4me3_logLR.bdg > A2-MB-K4me3_logLR_NoN.bdg 
awk '!/NC/' A2-MB-K4me3_logLR_NoN.bdg > A2-MB-K4me3_logLR_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A2-MB-K4me3_logLR_chr.bdg

####Convert BEDGRAPH to BIGWIG for IGV visualization####

#A1-CTRL-K4me3
bash bdg2bw A1-CTRL-K4me3_FE_chr.bdg chrominfo.len
bash bdg2bw A1-CTRL-K4me3_logLR_chr.bdg chrominfo.len

#A1-MB-K4me3
bash bdg2bw A1-MB-K4me3_FE_chr.bdg chrominfo.len
bash bdg2bw A1-MB-K4me3_logLR_chr.bdg chrominfo.len

#A2-CTRL-K4me3
bash bdg2bw A2-CTRL-K4me3_FE_chr.bdg chrominfo.len
bash bdg2bw A2-CTRL-K4me3_logLR_chr.bdg chrominfo.len

#A2-MB-K4me3
bash bdg2bw A2-MB-K4me3_FE_chr.bdg chrominfo.len
bash bdg2bw A2-MB-K4me3_logLR_chr.bdg chrominfo.len


################################################################################
################################K27#############################################
################################################################################

#Rough chip seq K27 work. This was the line for line chunk of code used for calling K27
cd /home/workspace/thall/CHiP-seq/K27_work

#These numbers are used for the differential peak calling. Remember to use the average of the ext when calling the peaks. 
A1-CTRL-K27me3 - extsize 167
tags in treatment after filtering : 45054957
A1-MB-K27me3 - extsize 174
tags in treatment after filtering : 45552729
A2-CTRL-K27me3 - extsize 163
tags in treatment after filtering : 51570455
A2-MB-K27me3 - extsize 168
tags in treatment after filtering : 43798321

#To get a uniform extension size for running callpeak, run predictd. These valuse are needed for the differential peak calling. Ideally they would be the same, but if A1-CTRL is 160 and A1-MB is 150, use 155 for both. 
macs2 predictd -i A1-CTRL-K27me3.sorted.BAM
macs2 predictd -i A1-MB-K27me3.sorted.BAM
macs2 predictd -i A2-CTRL-K27me3.sorted.BAM
macs2 predictd -i A2-MB-K27me3.sorted.BAM

###########peak calling################## 

#A1-CTRL-K27me3
macs2 callpeak -t A1-CTRL-K27me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-CTRL-K27me3 -B --nomodel --broad --broad-cutoff 0.005 --extsize 171 --SPMR --tempdir /home/workspace/thall/tmp

#A1-MB-K27me3
macs2 callpeak -t A1-MB-K27me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-MB-K27me3 -B --nomodel --broad --broad-cutoff 0.005 --extsize 171 --SPMR --tempdir /home/workspace/thall/tmp

#A2-CTRL-K27me3
macs2 callpeak -t A2-CTRL-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-CTRL-K27me3 -B --nomodel --broad --broad-cutoff 0.005 --extsize 166 --SPMR --tempdir /home/workspace/thall/tmp

#A2-MB-K27me3
macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3 -B --nomodel --broad --broad-cutoff 0.005 --extsize 166 --SPMR --tempdir /home/workspace/thall/tmp

#######differential peak calling#########

#A1-CTRL-K27me3
macs2 callpeak -t A1-CTRL-K27me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-CTRL-K27me3_diff -B --nomodel --broad --broad-cutoff 0.005 --extsize 171  --tempdir /home/workspace/thall/tmp

#A1-MB-K27me3
macs2 callpeak -t A1-MB-K27me3.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-MB-K27me3_diff -B --nomodel --broad --broad-cutoff 0.005 --extsize 171  --tempdir /home/workspace/thall/tmp

#A2-CTRL-K27me3
macs2 callpeak -t A2-CTRL-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-CTRL-K27me3_diff -B --nomodel --broad --broad-cutoff 0.005 --extsize 166 --tempdir /home/workspace/thall/tmp

#A2-MB-K27me3
macs2 callpeak -t A2-MB-K27me3.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-K27me3_diff -B --nomodel --broad --broad-cutoff 0.005 --extsize 166  --tempdir /home/workspace/thall/tmp

#######peak comparison#################
#A1 
macs2 bdgdiff --t1 A1-CTRL-K27me3_diff_treat_pileup.bdg --c1 A1-CTRL-K27me3_diff_control_lambda.bdg --t2 A1-MB-K27me3_diff_treat_pileup.bdg --c2 A1-MB-K27me3_diff_control_lambda.bdg --d1 45054957 --d2 45552729 -l 171 --o-prefix diff_c1_vs_c2_A1

#A2
macs2 bdgdiff --t1 A2-CTRL-K27me3_diff_treat_pileup.bdg --c1 A2-CTRL-K27me3_diff_control_lambda.bdg --t2 A2-MB-K27me3_diff_treat_pileup.bdg --c2 A2-MB-K27me3_diff_control_lambda.bdg --d1 51570455 --d2 43798321 -l 166 --o-prefix diff_c1_vs_c2_A2

##############Track building#############

#A1-CTRL-K27me3
macs2 bdgcmp -t A1-CTRL-K27me3_treat_pileup.bdg -c A1-CTRL-K27me3_control_lambda.bdg -o A1-CTRL-K27me3_FE.bdg -m FE
macs2 bdgcmp -t A1-CTRL-K27me3_treat_pileup.bdg -c A1-CTRL-K27me3_control_lambda.bdg -o A1-CTRL-K27me3_logLR.bdg -m logLR -p 0.00001

#A1-MB-K27me3
macs2 bdgcmp -t A1-MB-K27me3_treat_pileup.bdg -c A1-MB-K27me3_control_lambda.bdg -o A1-MB-K27me3_FE.bdg -m FE
macs2 bdgcmp -t A1-MB-K27me3_treat_pileup.bdg -c A1-MB-K27me3_control_lambda.bdg -o A1-MB-K27me3_logLR.bdg -m logLR -p 0.00001

#A2-CTRL-K27me3
macs2 bdgcmp -t A2-CTRL-K27me3_treat_pileup.bdg -c A2-CTRL-K27me3_control_lambda.bdg -o A2-CTRL-K27me3_FE.bdg -m FE
macs2 bdgcmp -t A2-CTRL-K27me3_treat_pileup.bdg -c A2-CTRL-K27me3_control_lambda.bdg -o A2-CTRL-K27me3_logLR.bdg -m logLR -p 0.00001

#A2-MB-K27me3
macs2 bdgcmp -t A2-MB-K27me3_treat_pileup.bdg -c A2-MB-K27me3_control_lambda.bdg -o A2-MB-K27me3_FE.bdg -m FE
macs2 bdgcmp -t A2-MB-K27me3_treat_pileup.bdg -c A2-MB-K27me3_control_lambda.bdg -o A2-MB-K27me3_logLR.bdg -m logLR -p 0.00001


###############conversion############## 
#Convert FE ac's 
#A1-CTRL-K27me3
awk '!/NW_/' A1-CTRL-K27me3_FE.bdg > A1-CTRL-K27me3_FE_NoN.bdg 
awk '!/NC/' A1-CTRL-K27me3_FE_NoN.bdg > A1-CTRL-K27me3_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-CTRL-K27me3_FE_chr.bdg

#A1-MB-K27me3
awk '!/NW_/' A1-MB-K27me3_FE.bdg > A1-MB-K27me3_FE_NoN.bdg 
awk '!/NC/' A1-MB-K27me3_FE_NoN.bdg > A1-MB-K27me3_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-MB-K27me3_FE_chr.bdg

#A2-CTRL-K27me3
awk '!/NW_/' A2-CTRL-K27me3_FE.bdg > A2-CTRL-K27me3_FE_NoN.bdg 
awk '!/NC/' A2-CTRL-K27me3_FE_NoN.bdg > A2-CTRL-K27me3_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A2-CTRL-K27me3_FE_chr.bdg

#A2-MB-K27me3
awk '!/NW_/' A2-MB-K27me3_FE.bdg > A2-MB-K27me3_FE_NoN.bdg 
awk '!/NC/' A2-MB-K27me3_FE_NoN.bdg > A2-MB-K27me3_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A2-MB-K27me3_FE_chr.bdg

#convert logLR ac's
#A1-CTRL-K27me3
awk '!/NW_/' A1-CTRL-K27me3_logLR.bdg > A1-CTRL-K27me3_logLR_NoN.bdg 
awk '!/NC/' A1-CTRL-K27me3_logLR_NoN.bdg > A1-CTRL-K27me3_logLR_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-CTRL-K27me3_logLR_chr.bdg

#A1-MB-K27me3
awk '!/NW_/' A1-MB-K27me3_logLR.bdg > A1-MB-K27me3_logLR_NoN.bdg 
awk '!/NC/' A1-MB-K27me3_logLR_NoN.bdg > A1-MB-K27me3_logLR_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-MB-K27me3_logLR_chr.bdg

#A2-CTRL-K27me3
awk '!/NW_/' A2-CTRL-K27me3_logLR.bdg > A2-CTRL-K27me3_logLR_NoN.bdg 
awk '!/NC/' A2-CTRL-K27me3_logLR_NoN.bdg > A2-CTRL-K27me3_logLR_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A2-CTRL-K27me3_logLR_chr.bdg

#A2-MB-K27me3
awk '!/NW_/' A2-MB-K27me3_logLR.bdg > A2-MB-K27me3_logLR_NoN.bdg 
awk '!/NC/' A2-MB-K27me3_logLR_NoN.bdg > A2-MB-K27me3_logLR_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A2-MB-K27me3_logLR_chr.bdg

####Convert BEDGRAPH to BIGWIG for IGV visualization####

#A1-CTRL-K27me3
bash bdg2bw A1-CTRL-K27me3_FE_chr.bdg chrominfo.len
bash bdg2bw A1-CTRL-K27me3_logLR_chr.bdg chrominfo.len

#A1-MB-K27me3
bash bdg2bw A1-MB-K27me3_FE_chr.bdg chrominfo.len
bash bdg2bw A1-MB-K27me3_logLR_chr.bdg chrominfo.len

#A2-CTRL-K27me3
bash bdg2bw A2-CTRL-K27me3_FE_chr.bdg chrominfo.len
bash bdg2bw A2-CTRL-K27me3_logLR_chr.bdg chrominfo.len

#A2-MB-K27me3
bash bdg2bw A2-MB-K27me3_FE_chr.bdg chrominfo.len
bash bdg2bw A2-MB-K27me3_logLR_chr.bdg chrominfo.len


################################################################################
################################PolII###########################################
################################################################################

#Rough chip seq K27 work. This was the line for line chunk of code used for calling PolII
cd /home/workspace/thall/CHiP-seq/PolII_work

#These numbers are used for the differential peak calling. Remember to use the average of the ext when calling the peaks. 
A1-CTRL-PolII -  extsize 159
tags in treatment after filtering : 18820715
A1-MB-PolII - extsize 159
tags in treatment after filtering : 17202004
A2-CTRL-PolII - extsize 159
tags in treatment after filtering : 25199535
A2-MB-PolII - extsize 157
tags in treatment after filtering : 20855963

#Using 

macs2 predictd -i A1-CTRL-PolII.sorted.BAM
macs2 predictd -i A1-MB-PolII.sorted.BAM
macs2 predictd -i A2-CTRL-PolII.sorted.BAM
macs2 predictd -i A2-MB-PolII.sorted.BAM

###########peak calling################## 

#A1-CTRL-PolII
macs2 callpeak -t A1-CTRL-PolII.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-CTRL-PolII -B --nomodel --broad --broad-cutoff 0.005 --extsize 159 --SPMR --tempdir /home/workspace/thall/tmp

#A1-MB-PolII
macs2 callpeak -t A1-MB-PolII.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-MB-PolII -B --nomodel --broad --broad-cutoff 0.005 --extsize 159 --SPMR --tempdir /home/workspace/thall/tmp

#A2-CTRL-PolII
macs2 callpeak -t A2-CTRL-PolII.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-CTRL-PolII -B --nomodel --broad --broad-cutoff 0.005 --extsize 158 --SPMR --tempdir /home/workspace/thall/tmp

#A2-MB-PolII
macs2 callpeak -t A2-MB-PolII.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-PolII -B --nomodel --broad --broad-cutoff 0.005 --extsize 158 --SPMR --tempdir /home/workspace/thall/tmp

#######differential peak calling#########

#A1-CTRL-PolII
macs2 callpeak -t A1-CTRL-PolII.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-CTRL-PolII_diff -B --nomodel --broad --broad-cutoff 0.005 --extsize 159  --tempdir /home/workspace/thall/tmp

#A1-MB-PolII
macs2 callpeak -t A1-MB-PolII.sorted.BAM -c A1-CTRL-input.sorted.BAM -f BAM -g hs -n A1-MB-PolII_diff -B --nomodel --broad --broad-cutoff 0.005 --extsize 159 --tempdir /home/workspace/thall/tmp

#A2-CTRL-PolII
macs2 callpeak -t A2-CTRL-PolII.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-CTRL-PolII_diff -B --nomodel --broad --broad-cutoff 0.005 --extsize 158  --tempdir /home/workspace/thall/tmp

#A2-MB-PolII
macs2 callpeak -t A2-MB-PolII.sorted.BAM -c A2-CTRL-input.sorted.BAM -f BAM -g hs -n A2-MB-PolII_diff -B --nomodel --broad --broad-cutoff 0.005 --extsize 158  --tempdir /home/workspace/thall/tmp

#######peak comparison#################
#A1 
macs2 bdgdiff --t1 A1-CTRL-PolII_diff_treat_pileup.bdg --c1 A1-CTRL-PolII_diff_control_lambda.bdg --t2 A1-MB-PolII_diff_treat_pileup.bdg --c2 A1-MB-PolII_diff_control_lambda.bdg --d1 18820715 --d2 17202004  -l 159 --o-prefix diff_c1_vs_c2_A1

#A2
macs2 bdgdiff --t1 A2-CTRL-PolII_diff_treat_pileup.bdg --c1 A2-CTRL-PolII_diff_control_lambda.bdg --t2 A2-MB-PolII_diff_treat_pileup.bdg --c2 A2-MB-PolII_diff_control_lambda.bdg --d1 25199535 --d2 20855963 -l 158 --o-prefix diff_c1_vs_c2_A1

##############Track building#############

#We need the Fold Enrichment and Log liklehood ratio for the track building. 
#A1-CTRL-PolII
macs2 bdgcmp -t A1-CTRL-PolII_treat_pileup.bdg -c A1-CTRL-PolII_control_lambda.bdg -o A1-CTRL-PolII_FE.bdg -m FE
macs2 bdgcmp -t A1-CTRL-PolII_treat_pileup.bdg -c A1-CTRL-PolII_control_lambda.bdg -o A1-CTRL-PolII_logLR.bdg -m logLR -p 0.00001

#A1-MB-PolII
macs2 bdgcmp -t A1-MB-PolII_treat_pileup.bdg -c A1-MB-PolII_control_lambda.bdg -o A1-MB-PolII_FE.bdg -m FE
macs2 bdgcmp -t A1-MB-PolII_treat_pileup.bdg -c A1-MB-PolII_control_lambda.bdg -o A1-MB-PolII_logLR.bdg -m logLR -p 0.00001

#A2-CTRL-PolII
macs2 bdgcmp -t A2-CTRL-PolII_treat_pileup.bdg -c A2-CTRL-PolII_control_lambda.bdg -o A2-CTRL-PolII_FE.bdg -m FE
macs2 bdgcmp -t A2-CTRL-PolII_treat_pileup.bdg -c A2-CTRL-PolII_control_lambda.bdg -o A2-CTRL-PolII_logLR.bdg -m logLR -p 0.00001

#A2-MB-PolII
macs2 bdgcmp -t A2-MB-PolII_treat_pileup.bdg -c A2-MB-PolII_control_lambda.bdg -o A2-MB-PolII_FE.bdg -m FE
macs2 bdgcmp -t A2-MB-PolII_treat_pileup.bdg -c A2-MB-PolII_control_lambda.bdg -o A2-MB-PolII_logLR.bdg -m logLR -p 0.00001


###############conversion############## 

#A1-CTRL-PolII
awk '!/NW_/' A1-CTRL-PolII_FE.bdg > A1-CTRL-PolII_FE_NoN.bdg 
awk '!/NC/' A1-CTRL-PolII_FE_NoN.bdg > A1-CTRL-PolII_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-CTRL-PolII_FE_chr.bdg

#A1-MB-PolII
awk '!/NW_/' A1-MB-PolII_FE.bdg > A1-MB-PolII_FE_NoN.bdg 
awk '!/NC/' A1-MB-PolII_FE_NoN.bdg > A1-MB-PolII_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-MB-PolII_FE_chr.bdg

#A2-CTRL-PolII
awk '!/NW_/' A2-CTRL-PolII_FE.bdg > A2-CTRL-PolII_FE_NoN.bdg 
awk '!/NC/' A2-CTRL-PolII_FE_NoN.bdg > A2-CTRL-PolII_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A2-CTRL-PolII_FE_chr.bdg

#A2-MB-PolII
awk '!/NW_/' A2-MB-PolII_FE.bdg > A2-MB-PolII_FE_NoN.bdg 
awk '!/NC/' A2-MB-PolII_FE_NoN.bdg > A2-MB-PolII_FE_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A2-MB-PolII_FE_chr.bdg

#convert logLR ac's
#A1-CTRL-PolII
awk '!/NW_/' A1-CTRL-PolII_logLR.bdg > A1-CTRL-PolII_logLR_NoN.bdg 
awk '!/NC/' A1-CTRL-PolII_logLR_NoN.bdg > A1-CTRL-PolII_logLR_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-CTRL-PolII_logLR_chr.bdg

#A1-MB-PolII
awk '!/NW_/' A1-MB-PolII_logLR.bdg > A1-MB-PolII_logLR_NoN.bdg 
awk '!/NC/' A1-MB-PolII_logLR_NoN.bdg > A1-MB-PolII_logLR_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A1-MB-PolII_logLR_chr.bdg

#A2-CTRL-PolII
awk '!/NW_/' A2-CTRL-PolII_logLR.bdg > A2-CTRL-PolII_logLR_NoN.bdg 
awk '!/NC/' A2-CTRL-PolII_logLR_NoN.bdg > A2-CTRL-PolII_logLR_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A2-CTRL-PolII_logLR_chr.bdg

#A2-MB-PolII
awk '!/NW_/' A2-MB-PolII_logLR.bdg > A2-MB-PolII_logLR_NoN.bdg 
awk '!/NC/' A2-MB-PolII_logLR_NoN.bdg > A2-MB-PolII_logLR_chr.bdg
sed -i 's/AC_000158.1/chr1/g; s/AC_000159.1/chr2/g; s/AC_000160.1/chr3/g; s/AC_000161.1/chr4/g; s/AC_000162.1/chr5/g; s/AC_000163.1/chr6/g; s/AC_000164.1/chr7/g; s/AC_000165.1/chr8/g; s/AC_000166.1/chr9/g; s/AC_000167.1/chr10/g; s/AC_000168.1/chr11/g; s/AC_000169.1/chr12/g; s/AC_000170.1/chr13/g; s/AC_000171.1/chr14/g; s/AC_000172.1/chr15/g; s/AC_000173.1/chr16/g; s/AC_000174.1/chr17/g; s/AC_000175.1/chr18/g; s/AC_000176.1/chr19/g; s/AC_000177.1/chr20/g; s/AC_000178.1/chr21/g; s/AC_000179.1/chr22/g; s/AC_000180.1/chr23/g; s/AC_000181.1/chr24/g; s/AC_000182.1/chr25/g; s/AC_000183.1/chr26/g; s/AC_000184.1/chr27/g; s/AC_000185.1/chr28/g; s/AC_000186.1/chr29/g; s/AC_000187.1/chrX/g' A2-MB-PolII_logLR_chr.bdg

####Convert BEDGRAPH to BIGWIG for IGV visualization####

#A1-CTRL-PolII
bash bdg2bw A1-CTRL-PolII_FE_chr.bdg chrominfo.len
bash bdg2bw A1-CTRL-PolII_logLR_chr.bdg chrominfo.len

#A1-MB-PolII
bash bdg2bw A1-MB-PolII_FE_chr.bdg chrominfo.len
bash bdg2bw A1-MB-PolII_logLR_chr.bdg chrominfo.len

#A2-CTRL-PolII
bash bdg2bw A2-CTRL-PolII_FE_chr.bdg chrominfo.len
bash bdg2bw A2-CTRL-PolII_logLR_chr.bdg chrominfo.len

#A2-MB-PolII
bash bdg2bw A2-MB-PolII_FE_chr.bdg chrominfo.len
bash bdg2bw A2-MB-PolII_logLR_chr.bdg chrominfo.len
