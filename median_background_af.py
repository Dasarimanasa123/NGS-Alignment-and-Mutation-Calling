import vcf
import pandas as pd

normal_vcf_path = "normal_variants_mutact2.vcf"

def extract_af_from_normal(vcf_path):
    af_values = []
    reader = vcf.Reader(filename=vcf_path)
    
    for record in reader:
        
        if "AF" in record.INFO:
            af_values.append(record.INFO["AF"][0])  
    
    return af_values

# Extract AF from the normal VCF
normal_af = extract_af_from_normal(normal_vcf_path)

# Calculate median background mutation level
median_background_af = pd.Series(normal_af).median()
print(f"Median Background Mutation Level: {median_background_af}")
