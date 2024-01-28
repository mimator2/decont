# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output


# Arguments sent from pipeline.sh
download_url="$1"
output_directory="$2"
gunzip_option=$3="$3"

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

# Download the file
wget "$download_url" -P "$output_directory"

# Extract the file if gunzip option is "yes"
if [ "$gunzip_option" = "yes" ]; then
    # Obtain filename
    filename=$(basename "$url")

    # Unzip the file with gunzip
    if [ "${filename##*.}" = "gz" ]; then
        gunzip -k "$output_directory/$filename"

        # Filtering and removing snRNA sequences with seqkit
        seqkit grep -v -n -r -p "small nuclear" "$output_directory/${filename%.*}" | seqkit grep -v -n -r -p "snRNA" > "$output_directory/${filename%.*}_filtered.fasta"
        
        # Replace the original file with the filtered file
        mv "$output_directory/${filename%.*}_filtered.fasta" "$output_directory/${filename%.*}"
    else
        echo "Error: Format not supported for decompression."
    fi
fi


echo "Process completed successfully."







