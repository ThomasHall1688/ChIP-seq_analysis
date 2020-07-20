#######################################################################################################
##################################### QC and filtering ################################################
#######################################################################################################


###################MD5 checksum###################
#Compare all raw .gz files with the md5 files to check file intergrity after download. This works with how EDgenomics orgainze their directories. The MD5 check will be the top half. 
#First make a dir in the parent directory of your raw reads i.e. if your read dirs are in /workspace/thall/RNA then put it here /workspace/thall/RNA/md5
mkdir md5/ 
#Check the raw zip files
md5sum *fastq.gz > md5_check
#Cat the results of the md5 and the existing md5 
cat md5_check *gz.md5 > md5_check_(file directory name)
#Check if it worked
head md5_check_(file directory name)
rm md5_check
cd ../
#When finished in each directory, bring all the md5 files into the md5 dir
cp **/*check_* md5/ 
cd md5/
#Merge all files into one
cat * > md5_check_all
#Check it 
nano md5_check_all
#Then open this file in excell and remove duplicates. If correct, there should be a single entry for all raw read files. 

################fastqc#####################

###############cutadapt##################### 

#installation 
pip install --user --upgrade cutadapt

~/.local/bin/cutadapt -a GATCGGAAGAGCACACGTCTGAACTCCAGTCACACAGTGATCTCGTATGCCGTCTTCTGCTTGAAAAAAAAAAAA -o output.fastq input.fastq

~/.local/bin/cutadapt -a GATCGGAAGAGCACACGTCTGAACTCCAGTCACACTTGAATCTCGTATGCCGTCTTCTGCTTGAAAAAAAAAAAA -o 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-005_2_cut.fastq.gz 170505_K00166_0212_BHJ77HBBXX_2_NB-TP-005_2.fastq.gz
