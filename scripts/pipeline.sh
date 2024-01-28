

#Downloading Files
wget -i data/urls -P data/


# Md5 checks
while read url; do
    file_name=$(basename "$url")
    local_file_path="data/${file_name}"
    md5_url="${url}.md5"

    if [ -e "$local_file_path" ]; then
        computed_md5=$(md5sum "$local_file_path" | awk '{print $1}')
        expected_md5=$(curl -sS "$md5_url" | awk '{print $1}')

        if [ "$computed_md5" == "$expected_md5" ]; then
            echo "MD5 checksum for $file_name is valid."
        else
            echo "MD5 checksum for $file_name is INVALID."
        fi
    else
        echo "File $file_name not found."
    fi
done < "data/urls"


# Downloading contaminant files:
contaminants_url="https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz"


#Downloading Contaminants and Filtering:
if [ ! -e "res/contaminants.fasta" ]; then
	bash scripts/download.sh "$contaminants_url" res yes
else
	echo "Skip filtering operation."
fi


#Indexing Contaminants:

if [ -n "$(ls -A res/contaminants_idx/ )" ]; then
    echo "Skip indexing operation"
else
	bash scripts/index.sh res/contaminants.fasta res/contaminants_idx
fi

# Check merged directory exists, if not, create it
if [ ! -d "out/merged" ]; then
    mkdir -p "out/merged"
fi


#Merging Data Files:

if [ -n "$(ls -A out/merged/ )" ]; then
    echo "Skip merging operation"
else
    for sid in $(ls data/*.fastq.gz | cut -d "." -f1 | sed 's:data/::' | sort | uniq); do
    	bash scripts/merge_fastqs.sh data out/merged $sid
	done

fi



#Trimming with Cutadapt:
if [ ! -d "out/trimmed" ]; then
    mkdir -p "out/trimmed"
fi

if [ ! -d "log/cutadapt" ]; then
    mkdir -p "log/cutadapt"
fi


# Trims adapters from merged files using Cutadapt.
if [ -n "$(ls -A log/cutadapt/ )" ]; then
    echo "Skip cutadapt operation"
else
	for file in out/merged/*.fastq.gz; do
	  file=$(basename "$file" .fastq.gz)
	  cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
		-o out/trimmed/"$file".trimmed.fastq.gz out/merged/"$file".fastq.gz > log/cutadapt/"$file".log
	done
fi


#Creates a directory for STAR output if it doesn't exist.
if [ ! -d "out/star" ]; then
    mkdir -p "out/star"
fi

#Runs STAR alignment on trimmed files, creating subdirectories for each sample.
if [ -n "$(ls -A out/star/ )" ]; then
    echo "Skip star operation"
else
	for fname in out/trimmed/*.fastq.gz; do
	  sampleid=$(basename "$fname" .trimmed.fastq.gz)
	  if [ ! -d "out/star/$sampleid" ]; then
		mkdir -p "out/star/$sampleid"
	  fi

	  STAR --runThreadN 4 --genomeDir res/contaminants_idx \
		--outReadsUnmapped Fastx --readFilesIn "$fname" \
		--readFilesCommand gunzip -c --outFileNamePrefix "out/star/$sampleid/"
	done
fi

 
# Pipeline Summary Log:
if [ -e "log/pipeline.log" ]; then
    echo "Skip pipeline.log operation."
else
    touch "log/pipeline.log"

	# Extract lines from files in log/cutadapt/
	for file in log/cutadapt/*; do
	    if [ -f "$file" ]; then
		echo "Archivo: $file" >> "log/pipeline.log"
		grep -E "Total basepairs processed|Reads with adapters" "$file" >> "log/pipeline.log"
		echo "----------------------------------------------------" >> "log/pipeline.log"
	    fi
	done

	# Extract lines from log.final.out file in out/star/ls/
	for dir in out/star/*; do
	    if [ -d "$dir" ]; then
		file="$dir/Log.final.out"
		if [ -f "$file" ]; then
		    echo "Archivo: $file" >> "log/pipeline.log"
		    grep -E "Uniquely mapped reads %|% of reads mapped to multiple loci|% of reads mapped to too many loci" "$file" >> "log/pipeline.log"
		    echo "----------------------------------------------------" >> "log/pipeline.log"
		fi
	    fi
	done
fi















