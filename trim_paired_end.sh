#!/bin/bash

# Define input and output directories
input_dir="Reads/pupil_bio"
output_dir="trimmed_data"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop over each pair of FASTQ files in the input directory
for input_file1 in "$input_dir"/*R1_001.fastq.gz
do
    # Determine the corresponding R2 file by replacing _1 with _2
    input_file2="${input_file1/_R1_001/_R2_001}"

    # Get the base name for the files by removing _1.fastq.gz
    base_name_1=$(basename "$input_file1" "_R1_001")
    base_name_2=$(basename "$input_file2" "_R2_001")

    # Define output file names
    
    output_file1="$output_dir/${base_name_1}_R1_trimmed.fastq.gz"
    output_file2="$output_dir/${base_name_2}_R2_trimmed.fastq.gz"
    unpaired_file1="$output_dir/${base_name_1}_R1_unpaired.fastq.gz"
    unpaired_file2="$output_dir/${base_name_2}_R2_unpaired.fastq.gz"

    # Check if the corresponding R2 file exists
    if [[ -f "$input_file2" ]]; then
        # Run Trimmomatic for each pair of files
        trimmomatic PE -threads 4 -phred33 \
        "$input_file1" "$input_file2" \
        "$output_file1" "$unpaired_file1" \
        "$output_file2" "$unpaired_file2" \
        ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
        LEADING:3 TRAILING:3 HEADCROP:6 MINLEN:36 SLIDINGWINDOW:4:15

        echo "Finished trimming $input_file1 and $input_file2 -> $output_file1, $output_file2"
    else
        echo "Warning: Corresponding reverse file not found for $input_file1. Skipping..."
    fi
done

echo "All files processed."

