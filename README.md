# ampli-tool
Collection of helper scripts for amplicon sequence analysis

Note: to get a full list of possible parameters and a short description of each tool just call the script without parameters.


---


### addSampleQualByFastq.pl
Script to add qualifier "sample" to fasta header to be able to use a fasta file with Qiime.

usage: addSamplQualByFasta -q FASTQ_DIR -f FASTA_FILE -o OUTPUT_FILE -m MAPPING_FILE



### demultiplex.pl
Simple demultiplexing script for dual barcode single-end reads of structure:

BARCODE (fw) - PRIMER (fw) - INSERT - PRIMER (rv) - BARCODE (rv) - ILLUMINA PRIMER

usage: demultiplex [-c -f] -i FASTQ -m MOTHUR_OLIGOS -o OUTPUT_DIR



### filter_otu_by_replicate_fraction.pl
Script takes a tab separates file of OTU abundances (rows) per replicate (cols), adds columns "row average", "sum" and "adjusted abundance" and removes those OTUs where the row average is below a given threshold.

usage: getFractionPerSample.pl -i INPUT_TABLE -o OUTPUT_TABLE -f FRACTION



### filter_otu_by_sample_fraction.pl
Script to filter OTU table (tab separated) by per-sample fraction: keeps all OTUs that represent at least given fraction of reads/abundance of any sample.

usage: filter_otu_by_sample_fraction.pl -i INPUT_OTU -o OUTPUT_OTU -f FRACTION



### batchCountFastq.pl
Script to count sequences of all fastq files in given directory. Prints out a list of "filename: SEQ_NUM" Additionally performs basic check of correct format, i.e., checks that number of line is a multiple of 4

usage: batchCountFastq.pl -d FASTQ_DIRECTORY



### batchRenameFiles.pl
Script to rename all files in a directory. It splits all files of given extension at a given separator and concatenates a given number of split segments to a new file name.

usage: batchRenameFiles.pl -d INPUT_FILE_DIRECTORY -f NUMBER_OF_SEGMETNS_TO_KEEP -e FILE_EXTENSION


