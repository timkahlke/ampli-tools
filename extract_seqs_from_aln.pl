#!/usr/bin/perl

use strict;
use Data::Dumper;
use Getopt::Std;


eval{
    main();
};


if($@){
    print $@;
}



sub main{
    our %opts;
    getopts("i:o:f:",\%opts);

    my $af = $opts{'i'};
    my $of = $opts{'o'};
    my $ff = $opts{'f'};

    if(!$af||!$of||!$ff){
        _usage();
    }

    my $seqs = _readFasta($ff);
    
    open(my $oh,">",$of) or die "[ERROR] Failed to open $of for writing";
    open(my $ih,"<",$af) or die "[ERROR] Failed to open $af for reading";
    my $print = 0;
    while(my $line=<$ih>){
        if($line=~/^>.*$/){
            my @ls = grep{$_ ne ""}split(/[\s\t\n\r]/,$line);
            $print=$seqs->{$ls[0]}?1:0;
        }
        next unless $print;
        print $oh $line;
    }
    close($oh);
    close($ih);

    print STDOUT "\n[STATUS] Done!\n\n";

}


# Read fasta file and retunr hash of sequence names.
sub _readFasta{
    my $file = shift;
    my $seqs = {};
    open(my $ih,"<",$file) or die "[ERROR] Failed to open $file for reading";
    while(my $line=<$ih>){
        if($line=~/^>.*/){
            my @ls = grep{$_ ne ""}split(/[\s\t\n\r]/,$line);
            $seqs->{$ls[0]} = 1;
        }
    }
    close($ih);
    return $seqs;
}

sub _usage{
    print STDOUT "\n\nScript to extract sequences in given un-aligned fasta file from aligned fasta file\n";
    print STDOUT "Parameter:\n";
    print STDOUT "i : input fasta file (aligned)\n";
    print STDOUT "o : output fasta file (aligned)\n";
    print STDOUT "f : fasta file of (unaligned) sequences to be extracted from aligned fasta file\n";
    print STDOUT "\n\n";
    exit;
}




