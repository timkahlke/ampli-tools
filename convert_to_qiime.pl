#!/usr/bin/env perl

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
    getopts("i:o:",\%opts);

    my $if = $opts{'i'};
    my $of = $opts{'o'};

    if(!$if||!$of){
        _usage();
    }

    my $bcs = {};

    open(my $oh,">",$of) or die "Failed to open $of";
    open(my $ih,"<",$if) or die "Failed to open $if";
    while(my $line=<$ih>){
        if($line=~/^>(.*);sample=([^;]+);\n$/){
            my $seq = $1;
            my $sam = $2;
            if(!($bcs->{$sam})){
                my $bc = _getBC($bcs);
                $bcs->{$sam} = $bc;
            }
            $line=">$sam $seq orig_bc=".$bcs->{$sam}." new_bc=".$bcs->{$sam}." bc_diff=0\n";
        }
        print $oh $line;
    }
    close($oh);
    close($ih);
}



sub _getBC{
    my $h = shift;

    my $list = {};
    foreach(keys(%$h)){
        $list->{$h->{$_}} = 1;
    }

    my $bc = _generate();
    while($list->{$bc}){
        $bc = _generate();
    }
    return $bc;
}

sub _generate{
    my $nucs = ["A","C","T","G"];

    my $bc = "";
    while(length($bc)<8){
        $bc.=$nucs->[int(rand(4))];
    }
    return $bc;
}


sub _usage{
    print STDOUT "\n\nScript to convert the output fasta of addSampleQualByFastq.pl to Qiime demultiplexed_libraries\nformat, i.e. the sequence header will be changed to\n\t>SampleID\tsequenceID\torig_bc=XXXX\tnew_bc=XXXX\tbc_diff=0\nwhere XXXXX will be a random 8 nucleotide barcode generated for each sample.\n";
    print STDOUT "Parameter:\n";
    print STDOUT "i : input fasta file\n";
    print STDOUT "o : output fasta file\n";
    print STDOUT "\n\n";
    exit;
}




