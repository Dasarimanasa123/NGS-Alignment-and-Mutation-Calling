#!/Bin/Bash

echo "Run prep files..."

### prep files ( generated only once)#################

## downlode the reference file####

# wget -p /home/manasa/BAM Files/wes/references/ https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz

#gunzip /references/hg38.fa.gz

# index reference file - .fai file for haplotype caller

#samtools faidx references/HG38/hg38.fa

# ref dict  - .dict file before running haplotype caller

#gatk CreateSequenceDictionary -R references/HG38/hg38.fa -O references/HG38/hg38.dict

## download known sites files for BQSR from GATK Resource bundle

#wget -p references/HG38/ https://console.cloud.google.com/storage/browser/gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.gz
#wget -p references/HG38/ https://console.cloud.google.com/storage/browser/gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.idx

###### Varient calling Steps ######

# directores ##

ref="references/HG38/hg38.fa"
Known_sites="references/HG38/hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf"
aligned_reads="align_reads/"
reads="Reads/pupil_bio"
results="results"
data="data"
deedup="deedup"
trimmed_data="trimmed_data"
mutect2="mutect2_files"

#------
# step 1 : QC - Run fastqc 
#------
if false
then

echo "STEP 1 :QC - RUN FASTQC"

fastqc $reads/*.gz -0 ${reads}/


#-----
echo "trimming"

sh trim_paired_end.sh

sh deedup_2.sh



#------
# step 2 : map to reference using BWA-MEM 
#-----

echo "step 2 : map to reserence using BWA-MEM"

# BWA Index reference

#bwa index ${ref}

# bma alignment


bwa mem -t 4 -R "@RG\tID:Tumor_S2\tPL:ILLUMINA\tSM:Tumor_S2" ${ref} ${trimmed_data}/PA220KH-lib09-P19-Tumor_S2_L001_R1_trimmed.fastq.gz ${trimmed_data}/PA220KH-lib09-P19-Tumor_S2_L001_R2_trimmed.fastq.gz > ${aligned_reads}/Tumor_S2.paired.sam

samtools flagstat Tumor_S2.paired.sam



bwa mem -t 4 -R "@RG\tID:Normal_S2\tPL:ILLUMINA\tSM:Normal_S2" ${ref} ${trimmed_data}/PA221MH-lib09-P19-Norm_S1_L001_R1_trimmed.fastq.gz ${trimmed_data}/PA221MH-lib09-P19-Norm_S1_L001_R2_trimmed.fastq.gz > ${aligned_reads}/Normal_S2.paired.sam

samtools flagstat Normal_S2.paired.sam


## step :3 Mark Duplicates and sort - GATK

echo "STEP 3 : Mark Duplicates and sort - GATK"

samtools view -S -b ${aligned_reads}/Tumor_S2.paired.sam > ${aligned_reads}/Tumor_S2.paired.bam

samtools view -S -b ${aligned_reads}/Normal_S2.paired.sam > ${aligned_reads}/Normal_S2.paired.bam


# Sort the BAM file
samtools sort -o ${aligned_reads}/Tumor_S2_paired_Sorted.bam ${aligned_reads}/Tumor_S2.paired.bam

samtools sort -o ${aligned_reads}/Normal_S2_paired_Sorted.bam ${aligned_reads}/Normal_S2.paired.bam

# Index the BAM file (optional)

samtools index ${aligned_reads}/Tumor_S2_paired_Sorted.bam

samtools index ${aligned_reads}/Normal_S2_paired_Sorted.bam



picard SortSam I=${aligned_reads}/Tumor_S2.paired.bam O=${aligned_reads}/Tumor_S2_Sorted.bam SORT_ORDER=coordinate

picard SortSam I=${aligned_reads}/Normal_S2.paired.bam O=${aligned_reads}/Normal_S2_Sorted.bam SORT_ORDER=coordinate



gatk MarkDuplicates -I ${aligned_reads}/Tumor_S2_Sorted.bam -O ${aligned_reads}/Tumor_S2_Sorted_dedup.bam -M ${aligned_reads}/metrics.txt

gatk MarkDuplicates -I ${aligned_reads}/Normal_S2_Sorted.bam -O ${aligned_reads}/Normal_S2_Sorted_dedup.bam -M ${aligned_reads}/metrics.txt


#gatk MarkDuplicatesSpark -I ${aligned_reads}/HARNITTAN.sam --output ${aligned_reads}/HARNITTAN_Sorted_dedup_reads.bam -M duplication_metrics.txt

#-----------------------------
#STEP 4 : Base quality recalibration
#-----------------------------

echo "step 4 : base quality recalibration"

# 1.. build the model

gatk BaseRecalibrator -I ${aligned_reads}/Tumor_S2_Sorted_dedup.bam -R ${ref} --known-sites ${Known_sites} -O ${data}/recal_data_Tumor.table

gatk BaseRecalibrator -I ${aligned_reads}/Normal_S2_Sorted_dedup.bam -R ${ref} --known-sites ${Known_sites} -O ${data}/recal_data_Normal.table

#  apply the model to adjust the base quality score

gatk ApplyBQSR -I ${aligned_reads}/Tumor_S2_Sorted_dedup.bam -R ${ref} --bqsr-recal-file ${data}/recal_data_Tumor.table -O ${aligned_reads}/Tumor_S2_Sorted_dedup_bqsr.bam

gatk ApplyBQSR -I ${aligned_reads}/Normal_S2_Sorted_dedup.bam -R ${ref} --bqsr-recal-file ${data}/recal_data_Normal.table -O ${aligned_reads}/Normal_S2_Sorted_dedup_bqsr.bam


#-----------------------------
#STEEP 5 : Collect Alignment & insert size 
# ---------------------------

echo "step 5 : Collect Alignment & insert size"

gatk CollectAlignmentSummaryMetrics -R ${ref} -I ${aligned_reads}/Normal_S2_Sorted_dedup_bqsr.bam -O ${aligned_reads}/Alignment_metricx_Normal.txt

gatk CollectAlignmentSummaryMetrics -R ${ref} -I ${aligned_reads}/Tumor_S2_Sorted_dedup_bqsr.bam -O ${aligned_reads}/Alignment_metricx_Tumor.txt

gatk CollectInsertSizeMetrics -I ${aligned_reads}/Tumor_S2_Sorted_dedup_bqsr.bam -O ${aligned_reads}/insert_size_metrics_Tumor.txt -H ${aligned_reads}/insert_size_histogram_Tumor.pdf

gatk CollectInsertSizeMetrics -I ${aligned_reads}/Normal_S2_Sorted_dedup_bqsr.bam -O ${aligned_reads}/insert_size_metrics_normal.txt -H ${aligned_reads}/insert_size_histogram_Normal.pdf

fi

##----------------------------------
# step 6 : call varients - gatk halotype caller 
##------------------------------------

echo "step 6 : call varients - gatk mutect2 caller"

gatk Mutect2 -R ${ref} \
     -I ${aligned_reads}/Tumor_S2_Sorted_dedup_bqsr.bam \
     -I ${aligned_reads}/Normal_S2_Sorted_dedup_bqsr.bam \
     -tumor Tumor_S2 \
     -normal Normal_S2 \
     --germline-resource ${mutect2}/af-only-gnomad.hg38.vcf.gz \
     --panel-of-normals ${mutect2}/1000g_pon.hg38.vcf.gz \
     -O ${results}/PA220KH-lib09-P19-somatic_variants_mutect2.vcf.gz \
     --f1r2-tar-gz ${results}/PA220KH-lib09-P19_f1r2.tar.gz \








