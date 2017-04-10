#!/usr/bin/perl

#   Script for basic format check (line number = multiple of 4) and count
#   of sequences of all fastq files in given directory.
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
#   Date: April 2017



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

    # Get all fastq files in directory
    opendir(DIR,$id);
    my @files=grep{(-f "$id/$_")&&(($_=~/^.*\.fastq$/)||($_=~/^.*\.fq$/))}readdir(DIR);
    closedir(DIR);

    print STDOUT "\n[STATUS] # of fastq files found in $id: ".scalar(@files)."\n";


    print STDOUT "\n[STATUS] Reading fastq files ....\n";
    my $seqs = {};
    foreach my $f (sort(@files)){
        print STDOUT "[STATUS] ... reading $f\n";

        # get lines in file
        my $lines = `wc -l $id/$f`;

        # check that it's a multiple of 4
        if($lines % 4){
            print STDOUT "\t[WARNING] Odd number of lines in file $f! Possibly corrupted fastq file!\n";
            $lines = $lines-($lines%4);
        }
        $seqs->{$f}=($lines/4);
    }
    print STDOUT "\n[STATUS] Done parsing!\n";
    print STDOUT "\n## Sequence numbers:\n";

    # print counts
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

