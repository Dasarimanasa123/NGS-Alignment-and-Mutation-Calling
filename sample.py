import pandas as pd

file_path = 'somatic_Normal_variants.csv'  
df = pd.read_csv(file_path)

af_values = df['Allele Frequency (AF)']

median_af = af_values.median()

print(f"Median Background Mutation Level (AF): {median_af}")
