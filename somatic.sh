ref="references/HG38/hg38.fa"
Known_sites="references/HG38/hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf"
aligned_reads="align_reads/"
reads="Reads/pupil_bio"
results="results"
data="data"
deedup="deedup"
trimmed_data="trimmed_data"
mutect2="mutect2_files"



#gatk Mutect2 \
   -R ${ref} \
   -I ${aligned_reads}/Normal_S2_Sorted_dedup_bqsr.bam \
   --normal-sample Normal_S2 \
   -O Normal_variants.vcf


#gatk Mutect2 -R ${ref} \
     -I ${aligned_reads}/Tumor_S2_Sorted_dedup_bqsr.bam \
     -I ${aligned_reads}/Normal_S2_Sorted_dedup_bqsr.bam \
     -tumor Tumor_S2 \
     -normal Normal_S2 \
     --germline-resource ${mutect2}/af-only-gnomad.hg38.vcf.gz \
     --panel-of-normals ${mutect2}/1000g_pon.hg38.vcf.gz \
     -O ${results}/PA220KH-lib09-P19-somatic_variants_mutect2.vcf.gz \
     --f1r2-tar-gz ${results}/PA220KH-lib09-P19_f1r2.tar.gz \

#gatk FuncotatorDataSourceDownloader\
   --somatic\
   --validate-integrity\
   --extract-after-download \
   --hg38 \

#gatk Funcotator \
    --variant ${results}/PA220KH-lib09-P19-somatic_tumor_variants_mutect2.vcf.gz \
    --reference ${ref} \
    --ref-version hg38 \
    --data-sources-path funcotator_dataSources.v1.8.hg38.20230908s\ \
    --output ${results}/somatic_tumor_functotated.vcf \
    --output-file-format VCF


#gatk Funcotator \
    --variant ${results}/PA220KH-lib09-P19-somatic_Normal_variants_mutect2.vcf.gz \
    --reference ${ref} \
    --ref-version hg38 \
    --data-sources-path funcotator_dataSources.v1.8.hg38.20230908s \
    --output ${results}/somatic_Normal_functotated.vcf \
    --output-file-format VCF


#gatk Funcotator \
    --variant ${results}/PA220KH-lib09-P19-somatic_variants_mutect2.vcf.gz \
    --reference ${ref} \
    --ref-version hg38 \
    --data-sources-path /funcotator_dataSources.v1.8.hg38.20230908s \
    --output ${results}/cancer_combines_functotated.vcf \
    --output-file-format VCF

#gatk HaplotypeCaller \
  -R ${ref} \
  -I ${aligned_reads}/Normal_S2_Sorted_dedup_bqsr.bam \
  -O Normal_variants.vcf

gatk Mutect2 \
   -R ${ref} \
   -I ${aligned_reads}/Normal_S2_Sorted_dedup_bqsr.bam \
   -O normal_variants_mutact2.vcf



   




