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
    getopts("xi:o:l:",\%opts);

    my $af = $opts{'i'};
    my $of = $opts{'o'};
    my $ff = $opts{'l'};
    my $inverse = $opts{'x'};

    if(!$af||!$of||!$ff){
        _usage();
    }

    my $seqs = _readFasta($ff);
    print STDOUT "\n\nSequences found in list file: ".scalar(keys(%$seqs))."\n\n";

    open(my $oh,">",$of) or die "[ERROR] Failed to open $of for writing";
    open(my $ih,"<",$af) or die "[ERROR] Failed to open $af for reading";
    my $print = 0;
    while(my $line=<$ih>){
        if($line=~/^>.*$/){
            my @ls = grep{$_ ne ""}split(/[\s\t\n\r>]/,$line);
            if($inverse){
                $print=$seqs->{$ls[0]}?0:1;
            }
            else{
                $print=$seqs->{$ls[0]}?1:0;
            }
        }
        next unless $print;
        print $oh $line;
    }
    close($oh);
    close($ih);

    print STDOUT "\n[STATUS] Done!\n\n";

}


# Read fasta file and return hash of sequence names.
sub _readFasta{
    my $file = shift;
    my $seqs = {};
    open(my $ih,"<",$file) or die "[ERROR] Failed to open $file for reading";
    while(my $line=<$ih>){
        my @ls = grep{$_ ne ""}split(/[\s\t\n\r]/,$line);
        $seqs->{$ls[0]} = 1;
    }
    close($ih);
    return $seqs;
}

sub _usage{
    print STDOUT "\n\nScript to extract sequences form a fasta file based on a given list.\n";
    print STDOUT "Parameter:\n";
    print STDOUT "i : input fasta file\n";
    print STDOUT "o : output fasta file\n";
    print STDOUT "l : list of sequence IDs to be extracted from fasta file (one per line)\n";
    print STDOUT "x : if set only sequences NOT in the list are extracted from fasta file\n";
    print STDOUT "\n\n";
    exit;
}




