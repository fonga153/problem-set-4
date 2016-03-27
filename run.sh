#! /usr/bin/env bash

datasets='/Users/test/GitHub/ProblemSet1/problem-set-1/problem-set-4/data'
chr1fa="$datasets/hg19.chr1.fa"
factorxchr1fq="$datasets/factorx.chr1.fq"
chromsizes="$datasets/hg19.chrom.sizes"

bowtie2-build $chr1fa $chromsizes  

bowtie2 -x $chromsizes -U $factorxchr1fq | samtools sort > factorx.chr1_sort.bam

bedtools genomecov -ibam factorx.chr1_sort.bam -g $chromsizes -bg > factorx.chr1_sort.bg 

bedGraphToBigWig factorx.chr1_sort.bg $chromsizes factorx.chr1_sort.bw 

macs2 callpeak -t factorx.chr1_sort.bam -f BAM -n factorx 

cat factorx_peaks.narrowPeak \
    | awk 'BEGIN{OFS="\t"} {halfwidth=int(($3-$2)/2); print$1, $2+halfwidth, $2+halfwidth+1}' > factorx_halfwidth.bed 

bedtools slop -b 50 -i factorx_halfwidth.bed -g $chromsizes > factorx50bp.bed

bedtools getfasta -fi $chr1fa -bed factorx50bp.bed -fo factorx50bp.fa



#samtools view factorx.chr1_sort.bam | less

#samtools view -H factorx.chr1_sort.bam


meme -minw 8 -maxw 20 -dna -nmotifs 1 factorx50bp.fa -maxsize 10000000

###make url with *.bw file to view onto genome.ucsc.edu website
#track type=bigWig bigDataUrl="http://fonga153.github.io/webstuff/factorx.chr1_sort.bw" color=255,0,0 visibility=full name='factor.chr1_sort.bw' description="factor.chr1"
###took many hours to finish...i started during the morning and didn't finish till the next morning

###i then went to the TOMTOM website and uploaded the meme.txt file from the meme-out folder and got the motif
###matches to NAME:MA0139.1(CTCF)
###Database:JASPAR CORE 2014 vertebrates
###p-value: 6.05e-10
###E-value: 8.67e-07
###q-value: 1,71e-06
###Overlap:19
###Offset: 0
###Orientation:Reverse Complement

##could try another way to identify motif
##go to TOMTOM website and enter in the consensus sequence
##you can use the meme-get-motif to extract the 1st motif from the file

#cp meme.txt meme2.txt
#meme-get-motif -id 1 < meme2.txt


