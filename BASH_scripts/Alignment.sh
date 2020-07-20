#######################################################################################################
######################################### Bowtie2 #####################################################
#######################################################################################################

#Bowtie 2 is an ultrafast and memory-efficient tool for aligning sequencing reads to long reference sequences. It is particularly good at aligning reads of about 50 up to 100s or 1,000s of characters to relatively long (e.g. mammalian) genomes.

#######genome indexing#######
#All genomes have been indexed and are contained in  the public folder /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index. However these are the commands

#-f						The reference input files (specified as <reference_in>) are FASTA files (usually having extension .fa, .mfa, .fna or similar).
#-c						The reference sequences are given on the command line. I.e. <reference_in> is a comma-separated list of sequences rather than a list of FASTA files.
#-o/--offrate <int>		To map alignments back to positions on the reference sequences, it’s necessary to annotate (“mark”) some or all of the Burrows-Wheeler rows with their corresponding location on the genome. 
#						-o/--offrate governs how many rows get marked: the indexer will mark every 2^<int> rows. 
#						Marking more rows makes reference-position lookups faster, but requires more memory to hold the annotations at runtime. The default is 5 (every 32nd row is marked; for human genome, annotations occupy about 340 megabytes).
				
#bowtie2-build  /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/source_file/GCF_000003055.6_Bos_taurus_UMD_3.1.1_genomic.fna  bostaurus_index

#New build for motif discovery analysis 
bowtie2-build  /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/source_file/GCF_002263795.1_ARS-UCD1.2_genomic.fna  bostaurus_index 
#############alignment#################

#The main command format for bowtie2 is as follows:

bowtie [options]* <ebwt> {-1 <m1> -2 <m2> | --12 <r> | <s>} [<hit>]

#Main arguments
#-x <bt2-idx> 	The basename of the index for the reference genome. The basename is the name of any of the index files up to but not including the final .1.bt2 / .rev.1.bt2 / etc. bowtie2 looks for the specified index first in the current directory, then in the directory specified in the BOWTIE2_INDEXES environment variable.
#-1 <m1>		Comma-separated list of files containing mate 1s (filename usually includes _1), e.g. -1 flyA_1.fq,flyB_1.fq. Sequences specified with this option must correspond file-for-file and read-for-read with those specified in <m2>. Reads may be a mix of different lengths. If - is specified, bowtie2 will read the mate 1s from the “standard in” or “stdin” filehandle.
#-2 <m2>		Comma-separated list of files containing mate 2s (filename usually includes _2), e.g. -2 flyA_2.fq,flyB_2.fq. Sequences specified with this option must correspond file-for-file and read-for-read with those specified in <m1>. Reads may be a mix of different lengths. If - is specified, bowtie2 will read the mate 2s from the “standard in” or “stdin” filehandle.
#-U <r>			Comma-separated list of files containing unpaired reads to be aligned, e.g. lane1.fq,lane2.fq,lane3.fq,lane4.fq. Reads may be a mix of different lengths. If - is specified, bowtie2 gets the reads from the “standard in” or “stdin” filehandle.
#-S <sam>		File to write SAM alignments to. By default, alignments are written to the “standard out” or “stdout” filehandle (i.e. the console).
#-N <int>		Sets the number of mismatches to allowed in a seed alignment during multiseed alignment. Can be set to 0 or 1. Setting this higher makes alignment slower (often much slower) but increases sensitivity. Default: 0.
#-L <int>		Sets the length of the seed substrings to align during multiseed alignment. Smaller values make alignment slower but more sensitive. Default: the --sensitive preset is used by default, which sets -L to 20 both in --end-to-end mode and in --local mode.
#-i <func>		Sets a function governing the interval between seed substrings to use during multiseed alignment.
#-t/--time		Print the wall-clock time required to load the index files and align the reads. This is printed to the “standard error” (“stderr”) filehandle. Default: off.
#-p 			for multithreading (using more than one processor). 


# Create symbolic links to FASTQ files:
for file in \
`ls /home/workspace/thall/Raw_data/GEO_submission/tjhall1688/ChIP-seq/raw_reads/*.fastq`; \
do ln -s \
$file /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/raw_read_links/`basename $file`; \
done

#each command for aligning each of the files 
#bowtie2 -p35 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-001_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-001_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-001_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-001_2.fastq -S A1-CTRL-PolII
#bowtie2 -p35 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-002_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-002_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-002_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-002_2.fastq -S A1-CTRL-K4me3
#bowtie2 -p35 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-003_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-003_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-003_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-003_2.fastq -S A1-CTRL-K27me3
#bowtie2 -p30 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-004_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-004_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-004_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-004_2.fastq -S A1-CTRL-input
#bowtie2 -p35 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-005_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-005_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-005_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-005_2.fastq -S A1-MB-PolII
#bowtie2 -p35 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-006_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-006_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-006_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-006_2.fastq -S A1-MB-K4me3
#bowtie2 -p35 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-007_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-007_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-007_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-007_2.fastq -S A1-MB-K27me3
#bowtie2 -p35 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-008_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-008_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-008_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-008_2.fastq -S A2-CTRL-PolII
#bowtie2 -p35 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-009_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-009_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-009_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-009_2.fastq -S A2-CTRL-K4me3
#bowtie2 -p35 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-010_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-010_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-010_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-010_2.fastq -S A2-CTRL-K27me3
#bowtie2 -p35 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-011_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-011_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-011_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-011_2.fastq -S A2-CTRL-input
#bowtie2 -p35 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-012_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-012_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-012_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-012_2.fastq -S A2-MB-PolII
#bowtie2 -p35 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-013_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-013_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-013_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-013_2.fastq -S A2-MB-K4me3
#bowtie2 -p35 -x /home/workspace/genomes/bostaurus/UMD3.1.1_NCBI/Bowtie2-2.3.2_index/bostaurus_index -1 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-014_1.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-014_1.fastq -2 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-014_2.fastq,170505_K00166_0212_BHJ77HBBXX_3_NB-TP-014_2.fastq -S A2-MB-K27me3

#New set of commands for new build 
#each command for aligning each of the files. Use from within the read directory otherwise list a directory for each pair. 
bowtie2 -p35 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A1-CTRL-PolII_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-001_1.fastq,A1-CTRL-PolII_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-001_1.fastq -2 A1-CTRL-PolII_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-001_2.fastq,A1-CTRL-PolII_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-001_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A1-CTRL-PolII
bowtie2 -p35 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A1-CTRL-K4me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-002_1.fastq,A1-CTRL-K4me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-002_1.fastq -2 A1-CTRL-K4me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-002_2.fastq,A1-CTRL-K4me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-002_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A1-CTRL-K4me3
bowtie2 -p35 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A1-CTRL-K27me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-003_1.fastq,A1-CTRL-K27me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-003_1.fastq -2 A1-CTRL-K27me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-003_2.fastq,A1-CTRL-K27me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-003_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A1-CTRL-K27me3
bowtie2 -p30 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A1-CTRL-input_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-004_1.fastq,A1-CTRL-input_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-004_1.fastq -2 A1-CTRL-input_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-004_2.fastq,A1-CTRL-input_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-004_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A1-CTRL-input
bowtie2 -p35 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A1-MB-PolII_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-005_1.fastq,A1-MB-PolII_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-005_1.fastq -2 A1-MB-PolII_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-005_2.fastq,A1-MB-PolII_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-005_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A1-MB-PolII
bowtie2 -p35 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A1-MB-K4me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-006_1.fastq,A1-MB-K4me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-006_1.fastq -2 A1-MB-K4me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-006_2.fastq,A1-MB-K4me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-006_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A1-MB-K4me3
bowtie2 -p35 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A1-MB-K27me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-007_1.fastq,A1-MB-K27me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-007_1.fastq -2 A1-MB-K27me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-007_2.fastq,A1-MB-K27me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-007_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A1-MB-K27me3
bowtie2 -p35 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A2-CTRL-PolII_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-008_1.fastq,A2-CTRL-PolII_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-008_1.fastq -2 A2-CTRL-PolII_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-008_2.fastq,A2-CTRL-PolII_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-008_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A2-CTRL-PolII
bowtie2 -p35 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A2-CTRL-K4me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-009_1.fastq,A2-CTRL-K4me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-009_1.fastq -2 A2-CTRL-K4me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-009_2.fastq,A2-CTRL-K4me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-009_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A2-CTRL-K4me3
bowtie2 -p35 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A2-CTRL-K27me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-010_1.fastq,A2-CTRL-K27me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-010_1.fastq -2 A2-CTRL-K27me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-010_2.fastq,A2-CTRL-K27me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-010_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A2-CTRL-K27me3
bowtie2 -p35 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A2-CTRL-input_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-011_1.fastq,A2-CTRL-input_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-011_1.fastq -2 A2-CTRL-input_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-011_2.fastq,A2-CTRL-input_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-011_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A2-CTRL-input
bowtie2 -p35 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A2-MB-PolII_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-012_1.fastq,A2-MB-PolII_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-012_1.fastq -2 A2-MB-PolII_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-012_2.fastq,A2-MB-PolII_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-012_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A2-MB-PolII
bowtie2 -p35 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A2-MB-K4me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-013_1.fastq,A2-MB-K4me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-013_1.fastq -2 A2-MB-K4me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-013_2.fastq,A2-MB-K4me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-013_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A2-MB-K4me3
bowtie2 -p35 -x /home/workspace/genomes/bostaurus/ARS_UCD1.2_NCBI/Bowtie-2.3.4.3_index/bostaurus_index -1 A2-MB-K27me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-014_1.fastq,A2-MB-K27me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-014_1.fastq -2 A2-MB-K27me3_170505_K00166_0212_BHJ77HBBXX_2_NB-TP-014_2.fastq,A2-MB-K27me3_170505_K00166_0212_BHJ77HBBXX_3_NB-TP-014_2.fastq -S /home/workspace/thall/Analysis/CHiP-seq/Motif_discovery/alignment/A2-MB-K27me3

java -Xmx2000m -jar igv.jar
 
################### Conversion #####################
#Need to convert the alignment file to binary format for use in MACS2 

#samtools sort test.bam test_sorted
samtools sort A1-CTRL-input > A1-CTRL-input_sorted.sam
samtools sort A2-CTRL-input > A2-CTRL-input_sorted.sam
samtools sort A1-CTRL-PolII > A1-CTRL-PolII_sorted.sam
samtools sort A1-CTRL-K4me3 > A1-CTRL-K4me3_sorted.sam
samtools sort A1-CTRL-K27me3 > A1-CTRL-K27me3_sorted.sam
samtools sort A1-MB-PolII > A1-MB-PolII_sorted.sam
samtools sort A1-MB-K4me3 > A1-MB-K4me3_sorted.sam
samtools sort A1-MB-K27me3 > A1-MB-K27me3_sorted.sam
samtools sort A2-CTRL-PolII > A2-CTRL-PolII_sorted.sam
samtools sort A2-CTRL-K4me3 > A2-CTRL-K4me3_sorted.sam
samtools sort A2-CTRL-K27me3 > A2-CTRL-K27me3_sorted.sam
samtools sort A2-MB-PolII > A2-MB-PolII_sorted.sam
samtools sort A2-MB-K4me3 > A2-MB-K4me3_sorted.sam
samtools sort A2-MB-K27me3 > A2-MB-K27me3_sorted.sam

#samtools view -bS test.sam > test.bam
samtools view -bS A1-CTRL-input_sorted.sam > A1-CTRL-input_sorted.bam
samtools view -bS A2-CTRL-input_sorted.sam > A2-CTRL-input_sorted.bam
samtools view -bS A1-CTRL-PolII_sorted.sam > A1-CTRL-PolII_sorted.bam
samtools view -bS A1-CTRL-K4me3_sorted.sam > A1-CTRL-K4me3_sorted.bam
samtools view -bS A1-CTRL-K27me3_sorted.sam > A1-CTRL-K27me3_sorted.bam
samtools view -bS A1-MB-PolII_sorted.sam > A1-MB-PolII_sorted.bam
samtools view -bS A1-MB-K4me3_sorted.sam > A1-MB-K4me3_sorted.bam
samtools view -bS A1-MB-K27me3_sorted.sam > A1-MB-K27me3_sorted.bam
samtools view -bS A2-CTRL-PolII_sorted.sam > A2-CTRL-PolII_sorted.bam
samtools view -bS A2-CTRL-K4me3_sorted.sam > A2-CTRL-K4me3_sorted.bam
samtools view -bS A2-CTRL-K27me3_sorted.sam > A2-CTRL-K27me3_sorted.bam
samtools view -bS A2-MB-PolII_sorted.sam > A2-MB-PolII_sorted.bam
samtools view -bS A2-MB-K4me3_sorted.sam > A2-MB-K4me3_sorted.bam
samtools view -bS A2-MB-K27me3_sorted.sam > A2-MB-K27me3_sorted.bam

#determine insert size for each .bam  via picard 
java -jar picard.jar CollectInsertSizeMetrics I={outfile}.bam O={outfile}_insert_size_metrics.txt H={outfile}_insert_size_histogram.pdf M=0.5
  
for file in `ls *.bam`; \
do outfile=`basename $file | perl -p -e 's/\.bam//'`; \
echo "java -jar /usr/local/src/picard-2.8.3/picard.jar CollectInsertSizeMetrics I=${outfile}.bam O=${outfile}_insert_size_metrics.txt H=${outfile}_insert_size_histogram.pdf M=0.5" \
>> insert_size.sh; \
done

#samtools index test_sorted.bam test_sorted.bai
samtools index A1-CTRL-input_sorted.bam > A1-CTRL-input_sorted_indexed.bam
samtools index A2-CTRL-input_sorted.bam > A1-CTRL-input_sorted_indexed.bam
samtools index A1-CTRL-PolII_sorted.bam > A1-CTRL-PolII_sorted_indexed.bam
samtools index A1-CTRL-K4me3_sorted.bam > A1-CTRL-K4me3_sorted_indexed.bam
samtools index A1-CTRL-K27me3_sorted.bam > A1-CTRL-K27me3_sorted_indexed.bam
samtools index A1-MB-PolII_sorted.bam > A1-MB-PolII_sorted_indexed.bam
samtools index A1-MB-K4me3_sorted.bam > A1-MB-K4me3_sorted_indexed.bam
samtools index A1-MB-K27me3_sorted.bam > A1-MB-K27me3_sorted_indexed.bam
samtools index A2-CTRL-PolII_sorted.bam > A2-CTRL-PolII_sorted_indexed.bam
samtools index A2-CTRL-K4me3_sorted.bam > A2-CTRL-K4me3_sorted_indexed.bam
samtools index A2-CTRL-K27me3_sorted.bam > A2-CTRL-K27me3_sorted_indexed.bam
samtools index A2-MB-PolII_sorted.bam > A2-MB-PolII_sorted_indexed.bam
samtools index A2-MB-K4me3_sorted.bam > A2-MB-K4me3_sorted_indexed.bam
samtools index A2-MB-K27me3_sorted.bam > A2-MB-K27me3_sorted_indexed.bam
