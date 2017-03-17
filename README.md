# ampli-tool
Collection of helper scripts for amplicon sequence analysis


---


### addSampleQualByFastq.pl
Script to add qualifier "sample" to fasta header to be able to use a fasta file with Qiime.

usage: perl addSamplQualByFasta -q FASTQ_DIR -f FASTA_FILE -o OUTPUT_FILE -m MAPPING_FILE



### demultiplex.pl
Simple demultiplexing script for dual barcode single-end reads of structure:

BARCODE (fw) - PRIMER (fw) - INSERT - PRIMER (rv) - BARCODE (rv) - ILLUMINA PRIMER





