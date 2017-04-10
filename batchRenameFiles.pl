#!/usr/bin/perl


#   This script is used to rename all files in a directory at once 
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
#   Date: April 2017



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
    getopts("d:o:n:s:p:e:r",\%opts);
    my $id = $opts{'d'};
    my $n = $opts{'n'};
    my $sep=$opts{'s'}?$opts{'s'}:'.';
    if($sep=~/[\\.\*\$\^\|]/){
        $sep='\\'.$sep;
    }
    my $postfix = $opts{'p'}?".".$opts{'p'}:"";
    my $fe = $opts{'e'};

    if(!$fe||!$id||!$n){
        _usage();
    }

    # Read input directory
    print STDOUT "[STATUS] Reading input directory:\n";
    opendir(DIR,$id);
    my @files = grep{(-f "$id/$_")&&($_=~/^.*\.$fe/)}readdir(DIR);
    print STDOUT "\n[STATUS] ".scalar(@files)." $fe files found in given directory $id\n";

    # Rename files
    foreach my $f(@files){
        my @fs = split(/$sep/,$f);
        my $ext = pop(@fs);

        # Check that given n is <= file name split at $seq
        if(scalar(@fs)<$n){
            die "\n[ERROR] File name $f contains less elements than given with parameter \'n\' when split at $sep!\n";
        }

        my $nn = join("$sep",splice(@fs,0,$n)).$postfix.".$fe";
        $nn=~s/\\//g;


        # check that file does not exist already
        if(-f "$id/$nn"){
            die "\n[ERROR] Failed to rename file $f: file $id/$nn already exists!\n";
        }
        system("mv $id/$f $id/$nn");
    }
    print STDOUT "\n\n[STATUS] Done!\n\n";
}


sub _usage{
    print STDOUT "\n\nScript to batch rename files, e.g., shorten fastq files demultiplexed by mothur.\n";
    print STDOUT "Paramter:\n";
    print STDOUT "d : directory of files to be renamed\n";
    print STDOUT "s : separator input file names will be split at (default \'.\')\n";
    print STDOUT "n : After splitting the file name on separator \'n\' elements will be kept for new file name.\n";
    print STDOUT "    Example:\n";
    print STDOUT "    --------\n";
    print STDOUT "    Input file name: test.input.ABC.DEF.fastq\n";
    print STDOUT "    If parameter \'n\' = 2 the output file name will be \'test.file.fastq\'\n";
    print STDOUT "    If parameter \'n\' = 3 the output file name will be \'test.file.ABC.fastq\'\n";
    print STDOUT "p : postfix for file names (optional). Will be added before given file extension\n";
    print STDOUT "e : file extension, e.g. \'fastq\'\n";
    print STDOUT "\n\n";
    exit;
}



