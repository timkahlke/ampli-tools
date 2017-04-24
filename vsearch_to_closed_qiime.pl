#!/usr/bin/perl

#   This script takes a the output of addSampleQualByFastq.pl 
#   and remanes each sequences to sample_ID_SequenceID
#
#
#   COPYRIGHT DISCALIMER:
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
#
#   Author: Tim Kahlke, tim.kahlke@uts.edu.au
#   Date: January 2017


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


    open(my $ih,"<",$if) or die "\n[Error] Failed to open $if for reading.\n";
    open(my $oh,">",$of) or die "\n[Error] Failed to open $of for writing\n";

    while(my $line=<$ih>){
        if($line=~/^>([^;]+);sample=([^;]+);.*$/){
            my $seqid = $1;
            my $sampleid = $2;
            print $oh ">$sampleid"."_"."$seqid\n";
        }
        else{
            print $oh $line;
        }
    }
    close($ih);
    close($oh);
}



sub _usage{
    print STDOUT "\n\nScript takes a fasta file including a sample qualifier and renames all sequences to sampleID_SequenceID.\n";
    print STDOUT "Parameter:\n";
    print STDOUT "i : input fasta file\n";
    print STDOUT "o : output fasta file\n";
    print STDOUT "\n\n";
    exit;
}

