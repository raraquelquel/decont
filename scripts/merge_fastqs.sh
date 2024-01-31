#!/bin/bash

if [ $# -lt 3 ]; then

    echo "At least 3 arguments are needed"
    echo "Usage: $0 <Sample_id> <out_directory> <samples_directory>"
    exit 1
fi


SAMPLES_DIR=$1
OUT_DIR=$2
SAMPLE_ID=$3

mkdir -p $OUT_DIR

SAMPLES=$( find ./data -type f| grep $SAMPLE_ID )

if [ -f "$OUT_DIR/${SAMPLE_ID}.fastq.gz" ]; then

    echo "Files merged already"

    else

        echo "Merging files $SAMPLES"

        cat $SAMPLES > "$OUT_DIR/${SAMPLE_ID}.fastq.gz"

fi