import vcf
import pandas as pd
import csv

# Open the VCF file
vcf_file = "normal_variants_mutact2.vcf"
reader = vcf.Reader(open(vcf_file, "r"))

# Extract relevant fields
data = []
for record in reader:
    chrom = record.CHROM
    pos = record.POS
    ref = record.REF
    alt = ",".join(str(a) for a in record.ALT)
    depth = record.INFO.get("DP", 0)
    tlod = record.INFO.get("TLOD", [0])[0] 
    

    
    sample_data = record.samples[0].data  
    af = getattr(sample_data, "AF", 0)  
    
    sample = record.samples[0]  
    genotype = sample['GT']  # Get genotype field from the sample

    # Determine genotype class based on GT value
    if genotype == '0/0':
        genotype_class = 'Homozygous Reference'
    elif genotype == '1/1':
        genotype_class = 'Homozygous Alternate'
    elif genotype == '0/1' or genotype == '1/0':
        genotype_class = 'Heterozygous'
    else:
        genotype_class = 'Unknown'

    
    if isinstance(af, list):
        af = af[0]

    data.append({
        "Chromosome": chrom,
        "Position": pos,
        "Reference": ref,
        "Alternate": alt,
        "Depth": depth,
        "Tumor Log Odds (TLOD)": tlod,
        "Allele Frequency (AF)": af,
        "Call": genotype_class
    })


df = pd.DataFrame(data)
print(df)


csv_file = 'somatic_Normal_variants.csv'  
with open(csv_file, 'w', newline='') as csvfile:
    fieldnames = ["Chromosome", "Position", "Reference", "Alternate", "Depth", "Tumor Log Odds (TLOD)", "Allele Frequency (AF)", "Call"]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()  
    for row in data:  
        writer.writerow(row)  

print(f"Data has been successfully written to {csv_file}.")
