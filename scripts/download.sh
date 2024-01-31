#!/bin/bash

# Check if at least 2 arguments are provided
if [ $# -lt 2 ]; then

    echo "At least 2 arguments are needed"
    echo "Usage: $0 <URL> <directory> [compress] [filter_word]"
    exit 1
fi

# Define the variables 
URL=$1
DIRECTORY=$2
COMPRESS=$3
FILTER_WORD=$4

# Download the file
wget --timestamping -P $DIRECTORY $URL


# Extract the local filename
FILE=$(basename $URL)

# Calculate the md5sum
md5_local=$(md5sum $DIRECTORY/$FILE  | awk '{print $1}')

# Fetch the online md5sum
md5_provided_val=$( curl -s "${URL}.md5" | awk '{print $1}')

# Check if compression is required
if [ "$COMPRESS" == "yes" ]; then
    
    gunzip -f $DIRECTORY/$FILE
fi

# Check if filtering is requested
if [ ! -z "$FILTER_WORD" ]; then

    # Remove lines matching the filter word and the next line
    awk -v word="$FILTER_WORD" '$1 ~ /^>/ && index($0, word) {getline; next} 1' $DIRECTORY/${FILE%.gz}  > $DIRECTORY/filtered_${FILE%.gz}
fi

# Check the md5sum 
if [ $md5_local != $md5_provided_val ]; then

    echo "MD5 checksum mismatch: $md5_local (local) vs $md5_provided_val (provided)"
    echo "** EXITING THE PIPELINE **"
    exit 1

else 

echo "MD5 checksum passed: $md5_local (local) vs $md5_provided_val (provided)"

fi
