# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).




# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_directory> <output_directory> <sample_id>"
    exit 1
fi

# Assigning command line arguments to variables
input_directory="$1"
output_directory="$2"
sample_id="$3"

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"


# Create the output file name
output_file="${output_directory}/${sample_id}.fastq.gz"

# Merge files from the given sample into a single file
cat "$input_directory"/"$sample_id"* > "$output_directory"/merged_"$sample_id".txt > "${output_file}"

echo "Merging files for sample $sample_id completed successfully."




