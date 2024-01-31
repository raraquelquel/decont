#!/bin/bash

if [ $# -lt 2 ]; then

    echo "At least 2 arguments are needed"
    echo "Usage: $0 <genome_file_path> <out_directory> "
    exit 1
fi

GENOMEFILE=$1
DIRECTORY=$2


if [ -d $DIRECTORY ]; then
    echo "The index for $GENOMEFILE has been created already, skipping this step."


else
    
    # Create the index directory
    mkdir -p "$DIRECTORY"

    echo "Creating the index from $GENOMEFILE"
    
    # Run STAR to generate the genome index
    STAR --runThreadN 4 --runMode genomeGenerate --genomeDir "$DIRECTORY" \
        --genomeFastaFiles "$GENOMEFILE" --genomeSAindexNbases 9

fi