# ampli-tool
Collection of helper scripts for amplicon sequence analysis


---


### addSampleQualByFastq.pl
Script to add qualifier "sample" to fasta header to be able to use a fasta file with Qiime.

usage: addSamplQualByFasta -q FASTQ_DIR -f FASTA_FILE -o OUTPUT_FILE -m MAPPING_FILE



### demultiplex.pl
Simple demultiplexing script for dual barcode single-end reads of structure:

BARCODE (fw) - PRIMER (fw) - INSERT - PRIMER (rv) - BARCODE (rv) - ILLUMINA PRIMER

usage: demultiplex [-c -f] -i FASTQ -m MOTHUR_OLIGOS -o OUTPUT_DIR



### getFractionPerSample.pl
Script takes a tab separates file of overal relative OTU abundance (rows) per replicate (cols), adds columns 'average count' and 'sum abundance' and removes OTUs below a given abundance 

usage: getFractionPerSample.pl -i INPUT_TABLE -o OUTPUT_TABLE -f FRACTION





