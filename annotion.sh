ref="references/HG38/hg38.fa"
Known_sites="references/HG38/hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf"
aligned_reads="align_reads/"
reads="Reads/pupil_bio"
results="results"
data="data"
deedup="deedup"
trimmed_data="trimmed_data"
mutect2="mutect2_files"


#gatk Funcotator \
    --variant ${results}/PA220KH-lib09-P19-somatic_tumor_variants_mutect2.vcf.gz \
    --reference ${ref} \
    --ref-version hg38 \
    --data-sources-path funcotator_dataSources.v1.8.hg38.20230908s \
    --output ${results}/somatic_tumor_functotated.vcf \
    --output-file-format MAF

gatk Funcotator \
    --variant ${results}/PA220KH-lib09-P19-somatic_Normal_variants_mutect2.vcf.gz \
    --reference ${ref} \
    --ref-version hg38 \
    --data-sources-path funcotator_dataSources.v1.8.hg38.20230908s \
    --output ${results}/somatic_Normal_functotated.vcf \
    --output-file-format MAF
