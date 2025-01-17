# Example input and output directories
input_dir="trimmed_data"
output_dir="deedup"

# Loop over each pair of FASTQ files
for input_file1 in "$input_dir"/*R1_trimmed.fastq.gz
do
    input_file2="${input_file1/_R1_trimmed.fastq.gz/_R2_trimmed.fastq.gz}"
    
    base_name=$(basename "$input_file1" "_R1_trimmed.fastq.gz")

    # Define output file names for deduplicated files
    output_file1="$output_dir/${base_name}_R1_dedup.fastq.gz"
    output_file2="$output_dir/${base_name}_R2_dedup.fastq.gz"
    

    # Run fastp for paired-end data
    fastp -i "$input_file1" -I "$input_file2" -o "$output_file1" -O "$output_file2" --dedup --overrepresentation_analysis --thread 4

    echo "Processed paired files: $input_file1 and $input_file2"
done

