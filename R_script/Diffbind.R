########################################################################################
##########################           diffBind            #################################
########################################################################################

#DiffBind provides functions for processing ChIP-Seq data enriched for genomic loci where specific
#protein/DNA binding occurs, including peak sets identified by ChIP-Seq peak callers and
#aligned sequence read datasets.
#The primary emphasis of the package is on identifying sites that are differentially bound between two sample groups.
#It includes functions to support the processing of peak sets,
#including overlapping and merging peak sets, counting sequencing reads overlapping intervals
#in peak sets, and identifying statistically significantly differentially bound sites based on
#evidence of binding affinity (measured by differences in read densities).

#There are five steps to obtaining results from diffBind:
#1: Reading in peaksets
#2: Occupancy analysis
#3: Counting reads
#4: Differential binding affinity analysis
#5: Plotting and reporting

#diffBind is EXTREMELY sensitive to syntax, so get everything right, in the right format or it will take you ages. 

###############Reading in peaksets###############
#diffBind requires a metadata file to load in the peaksets. This worked for me, however it took multiple tries. 
#This was in .csv format. Alignment files were in .bam and peaksets in tab deliminated with the headers removed.

SampleID	Tissue	Factor 	Condition	Treatment 	Replicate 	bamReads	ControlID	bamControl	Peaks	PeakCaller
A1-CTRL-K4me3	MA	H3K3me3	control	ex_vivo	1	A1-CTRL-K4me3.sorted.bam	A1-CTRL-input	A1-CTRL-input.sorted.bam	A1-CTRL-K4me3_peaks.txt	MACS2
A2-CTRL-K4me3	MA	H3K3me3	control	ex_vivo	2	A2-CTRL-K4me3.sorted.bam	A2-CTRL-input	A2-CTRL-input.sorted.bam	A2-CTRL-K4me3_peaks.txt	MACS2
A1-MB-K4me3	MA	H3K3me3	infected	ex_vivo	1	A1-MB-K4me3.sorted.bam	A1-CTRL-input	A1-CTRL-input.sorted.bam	A1-MB-K4me3_peaks.txt	MACS2
A2-MB-K4me3	MA	H3K3me3	infected	ex_vivo	2	A2-MB-K4me3.sorted.bam	A2-CTRL-input	A2-CTRL-input.sorted.bam	A2-MB-K4me3_peaks.txt	MACS2

# load library 
library(DiffBind)

#read in metadataset
samples <- read.csv("Peakset.csv")
names(samples)

#read metadataset as a dba object. 
tamoxifen <- dba(sampleSheet="Peakset.csv", peakFormat = "bed")

#show object. This shows how many peaks are in each peakset, as well as (in the first line) the total number of unique peaks after merging overlapping ones (3795), and the dimensions of
#dba.plotPCA(default binding matrix of 11 samples by the 2845 sites that overlap in at least two of the samples.

tamoxifen

#plot tamoxifen as a correlation heatmap. Gives an initial clustering of the samples using the cross-correlations of each row of the binding matrix
plot(tamoxifen)

###############Counting reads###############
#The next step is to calculate a binding matrix with scores based on read counts for every sample (affinity scores), rather than confidence scores for only those peaks called in a specific
#sample (occupancy scores).  it is advisable to use the "summits" option to re-center each peak around the point of greatest enrichment. This keeps the peaks at a consistent width (in this case,
#with summits=250, the peaks will be 500bp, extending 250bp up- and down- stream of the summit)

tamoxifen <- dba.count(tamoxifen, summits=250)



#######################Differential binding affinity analysis###############

#Before running the differential analysis, we need to tell DiffBind which cell lines fall in which groups. This is done using the dba.contrast function, as follows:
#By default diffBind will not accept less than 3 coniditions, so for infected/control we need to set minMembers = 2
tamoxifen <- dba.contrast(tamoxifen, categories=DBA_CONDITION, minMembers = 2)

#This will run an DESeq2 analysis (see subsequent section discussing the technical details of the analysis) using the default binding matrix.
tamoxifen <- dba.analyze(tamoxifen)

#A correlation heatmap can be plotted, based on the result of the analysis
plot(tamoxifen, contrast=1) 

#######################Retrieving the differentially bound sites###############
#The final step is to retrieve the differentially bound sites
tamoxifen.DB <- dba.report(tamoxifen)
tamoxifen.DB

####################Plotting and reporting#####################
#plot a pca
dba.plotPCA(tamoxifen,DBA_CONDITION,minMembers = 2, contrast = 1)

#plot an MA
dba.plotMA(tamoxifen)

#Similar to MA plots, Volcano plots also highlight significantly differentially bound sites and
#show their fold changes. Here, however, the confidence statistic (FDR or p-value) is shown on a negative log scale.
dba.plotVolcano(tamoxifen)

#how are reads distributed amongst the different classes of differentially bound sites and
#sample groups? These data can be more clearly seen using a boxplot
pvals <- dba.plotBox(tamoxifen)
corvals <- dba.plotHeatmap(tamoxifen, contrast=1, correlations=FALSE)

#identifying sites unique to a sample group
dba.plotVenn(tamoxifen,tamoxifen$masks$Consensus)
