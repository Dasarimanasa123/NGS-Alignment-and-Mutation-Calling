import vcf

# Function to calculate mutation burden
def calculate_mutation_burden(vcf_file, genome_size_mb):
    mutation_count = 0
    vcf_reader = vcf.Reader(open(vcf_file, 'r'))
    for record in vcf_reader:
        mutation_count += 1
    return mutation_count / genome_size_mb

# Function to extract VAF for each variant
def extract_vaf(vcf_file, output_file):
    vcf_reader = vcf.Reader(open(vcf_file, 'r'))
    with open(output_file, 'w') as output:
        output.write("CHROM\tPOS\tREF\tALT\tVAF\n")
        for record in vcf_reader:
            if 'AF' in record.INFO:  # Check if AF (allele frequency) is present
                vaf = record.INFO['AF'][0]
                output.write(f"{record.CHROM}\t{record.POS}\t{record.REF}\t{','.join(record.ALT)}\t{vaf:.4f}\n")

# Main execution
if __name__ == "__main__":
    # Input VCF file and genome size
    vcf_file = "PA220KH-lib09-P19-somatic_tumor_variants_mutect2.vcf"
    genome_size_mb = 3000  # Human genome size in megabases (e.g., hg38)

    # Mutation Burden Calculation
    mutation_burden = calculate_mutation_burden(vcf_file, genome_size_mb)
    print(f"Mutation burden: {mutation_burden:.2f} mutations per megabase")

    # VAF Extraction
    output_file = "vaf_results.txt"
    extract_vaf(vcf_file, output_file)
    print(f"VAF data saved to {output_file}")
