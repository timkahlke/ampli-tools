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



### filter_otu_by_replicate_fraction.pl
Script takes a tab separates file of OTU abundances (rows) per replicate (cols), adds columns "row average", "sum abundance" and "adjusted abundance" and removes those OTUs where the row average is below a given threshold.

usage: getFractionPerSample.pl -i INPUT_TABLE -o OUTPUT_TABLE -f FRACTION



### filter_otu_by_sample_fraction.pl
Script to filter OTU table (tab separated) by per-sample fraction: keeps all OTUs that represent at least given fraction of reads/abundance of any sample.

usage: filterOTU.pl -i INPUT_OTU -o OUTPUT_OTU -f FRACTION

