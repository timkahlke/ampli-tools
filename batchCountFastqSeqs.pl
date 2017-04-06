#!/usr/bin/perl

use strict;
use Data::Dumper;
use Getopt::Std;


eval{
    _main();
};

if($@){
    print $@;
}


sub _main{
    our %opts;
    getopts("d:",\%opts);
    my $id=$opts{'d'};

    if(!$id){
        _usage();
    }

    opendir(DIR,$id);
    my @files=grep{(-f "$id/$_")&&(($_=~/^.*\.fastq$/)||($_=~/^.*\.fq$/))}readdir(DIR);
    closedir(DIR);

    print STDOUT "\n[STATUS] # of fastq files found in $id: ".scalar(@files)."\n";


    print STDOUT "\n[STATUS] Reading fastq files ....\n";
    my $seqs = {};
    foreach my $f (sort(@files)){
        print STDOUT "[STATUS] ... reading $f\n";
        my $lines = `wc -l $id/$f`;
        if($lines % 4){
            print STDOUT "\t[WARNING] Odd number of lines in file $f! Possibly corrupted fastq file!\n";
            $lines = $lines-($lines%4);
        }
        $seqs->{$f}=($lines/4);
    }
    print STDOUT "\n[STATUS] Done parsing!\n";
    print STDOUT "\n## Sequence numbers:\n";

    foreach my $f(sort(keys(%$seqs))){
        print STDOUT "$f = ".$seqs->{$f}."\n";
    }
}


sub _usage{
    print STDOUT "\n\Script for counting sequences in all fastq files of given directory\n";
    print STDOUT "Parameter:\n";
    print STDOUT "d : directory of fastq files\n";
    print STDOUT "\n\n";
    exit;
}



my $test = `paste - - - - </shared/c3/projects/coral_metatranscriptome/data/metatranscriptomics/data/raw/raw_demultiplexed_fastq/control.raw.1.fastq| wc -l`;
die $test;

