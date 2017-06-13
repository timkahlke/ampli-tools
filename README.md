# ampli-tool
Collection of helper scripts for amplicon sequence analysis, e.g. as outlined in the workflow in the docs directory.

Note: to get a full list of possible parameters and a short description of each tool just call the script without parameters.


---
---

### docs/amplicon_pipeline.pdf

This pdf outlines the amplicon analysis workflow used and taught by c3 researchers.

---

### addSampleQualByFastq.pl
Script to add qualifier "sample" to fasta header to be able to use a fasta file with Qiime.

usage: addSamplQualByFasta -q FASTQ_DIR -f FASTA_FILE -o OUTPUT_FILE -m MAPPING_FILE

---

### batchCountFastqSeqs.pl
Script to count sequences of all fastq files in given directory. Prints out a list of "filename: SEQ_NUM" Additionally performs basic check of correct format, i.e., checks that number of line is a multiple of 4

usage: batchCountFastqSeqs.pl -d FASTQ_DIRECTORY

---

### batchRenameFiles.pl
Script to rename all files in a directory. It splits all files of given extension at a given separator and concatenates a given number of split segments to a new file name.

usage: batchRenameFiles.pl -d INPUT_FILE_DIRECTORY -f NUMBER_OF_SEGMETNS_TO_KEEP -e FILE_EXTENSION

---

### convert_to_qiime.pl
Script to convert the output of addSampleQualByFastq.pl to Qiime split_libraries output (e.g. for use with picrust).

usage: convert_to_qiime.pl -i INPUT_FASTA_FILE -o OUTPUT_FASTA_FILE

---

### demultiplex.pl
Simple demultiplexing script for dual barcode single-end reads of structure:

BARCODE (fw) - PRIMER (fw) - INSERT - PRIMER (rv) - BARCODE (rv) - ILLUMINA PRIMER

usage: demultiplex [-c -f] -i FASTQ -m MOTHUR_OLIGOS -o OUTPUT_DIR

---

### extract_seqs_from_aln.pl
Script to extract sequences in given un-aligned fasta file from aligned fasta file

usage: extract_seqs_from_aln.pl -i ALIGNED_INPUT_FASTA_FILE -o ALIGNED_OUTPUT_FASTA_FILE -f UNALIGNED_FASTA_FILE

---

### extract_seqs_from_fasta.pl
Script to extract sequences form a fasta file based on a given list.

usage: -i INPUT_FASTA_FILE -o OUTPUT_FASTA_FILE -l SEQUENCE_LIST

---
