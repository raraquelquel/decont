#!/bin/bash

#Download all the files specified in data/filenames
for url in $( cat ./data/urls ) 
do
    bash scripts/download.sh $url data 
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes "small nuclear"

# Index the contaminants file
bash scripts/index.sh res/filtered_contaminants.fasta res/contaminants_idx


# Extract the IDs with a regular expression
IDS=$( ls data | grep -oE '^[A-Z0-9_]+' | uniq ) 

# Merge the samples into a single file
for sid in $IDS
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done


# Create a directory to save the trimmed files and the cutadapt log files
mkdir -p out/trimmed
mkdir -p log/cutadapt

echo "**  PIPELINE LOG FILE  **" > log/pipeline.log
# Merge the samples into a single file
for sid in $IDS
do
    # Define the log file name
    log_file="log/cutadapt/${sid}.log"

    # Check if cutadapt has been passed
    if [ -f "out/trimmed/${sid}.trimmed.fastq.gz" ]; then

        echo "The trimming of the sample: ${sid} has been done already"

    else
        echo "Running cutadapt with sample $sid"

        # Run cutadapt and create a log file
        cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
                -o "out/trimmed/${sid}.trimmed.fastq.gz" "out/merged/${sid}.fastq.gz" \
                > "$log_file" 2>&1
    fi
    
    echo "###########################################" >> log/pipeline.log
    echo "Cutadapt || Processed sample: ${sid}" >> log/pipeline.log
    echo "" >> log/pipeline.log
    cat "$log_file" | grep -E "(Reads with adapters|Total basepairs)" >> log/pipeline.log
    echo "" >> log/pipeline.log

done

for fname in out/trimmed/*.fastq.gz
do
    # Obtain the sample ID from the filename
    sid=$( basename $fname .trimmed.fastq.gz )
    mkdir -p out/star/$sid

    # Check if cutadapt has been passed
    if [ -f "out/star/$sid/${sid}_Log.final.out" ]; then

        echo "The alinment of the sample: ${sid} has been done already"

    else

    echo "Aligning file $fname to the contaminant database."

    STAR --runThreadN 4 --genomeDir res/contaminants_idx \
        --outReadsUnmapped Fastx --readFilesIn "${fname}" \
        --readFilesCommand gunzip -c --outFileNamePrefix "out/star/$sid/${sid}_"
    
    fi

    echo "###########################################" >> log/pipeline.log
    echo "STAR || Processed sample: ${sid}" >> log/pipeline.log
    echo "" >> log/pipeline.log
    cat "out/star/$sid/${sid}_Log.final.out" | grep -E "(Uniquely mapped reads %|% of reads mapped to multiple loci|% of reads mapped to too many loci)" >> log/pipeline.log
    echo "" >> log/pipeline.log
    
done 


echo "Guardar Ambiente"
mkdir -p envs
conda env export > envs/decont.yaml