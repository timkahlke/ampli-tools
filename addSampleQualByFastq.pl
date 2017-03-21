#!/usr/bin/perl

#   This script is used to add a sample qualifier to a fasta file
#   for further use use with vsearch
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
use Digest::MD5 qw(md5 md5_hex md5_base64);

eval{
    _main();
};

if($@){
    print $@;
}



sub _main{
    our %opts;
    getopts("m:q:f:o:",\%opts);

    my $fq = $opts{'q'};
    my $fasta_in = $opts{'f'};
    my $output = $opts{'o'};
    my $m = $opts{'m'};


    if(!$fq||!$output||!$fasta_in||!$m){
        _usage();
    }

    ## Check that either a fastq file or directory of fastq files was given
    my @files = ();
    if(-f $fq){
        @files = ($fq);
    }
    elsif(-d $fq){
        opendir(DIR,$fq);
        @files = map{"$fq/$_"}grep{($_=~/^.*_R1.*/)||($_=~/^.*forward.*/)}grep{(($_=~/^.*\.fq[\.gz]*/)||($_=~/^.*\.fastq[\.gz]*/))}readdir(DIR);
        if(!(scalar(@files))){
            warn "No files ending on .fq or .fastq found in directory $fq";
            _usage();
        }
    }
    else{
        warn "-q options is neither a file nor a directory!";
        _usage();
    }

    # read mapping file of fastq to sample_id
    print STDOUT "\n[STATUS]  Parsing mapping file\n";
    my $map = _readMap($m);
    print STDOUT "[STATUS]  Done parsing: ".scalar(keys(%$map))." samples/fastq files found in mapping file\n";

    # check that all files in the mapping file are in the given directory
    print STDOUT "\n[STATUS]  Checking mapping file and given input fastq files\n";
    _checkMap($map,\@files);
    print STDOUT "[STATUS]  Done\n";

    # make lookup table of reads
    print STDOUT "\n[STATUS] Parsing fastq files ...\n";
    my ($rl,$ml) = _getLookup(\@files,$map);
    print STDOUT "[STATUS] All fastq files parsed.\n";

    # read input file and add sample qualifiers
    open(my $ih,"<",$fasta_in) or die "Failed to open $fasta_in";
    open(my $oh,">",$output) or die "Failed to open $output";
    my $flag=0;
    while(my $line=<$ih>){
        if($line=~/^>.*$/){
            my @ls = grep{$_ ne ""}split(/[>\t\s\n\r]/,$line);
            my $key = $ls[0];
            $key=~s/_/:/g;
            if(exists($rl->{$key})){
                $flag=1;
                $line=">".$ls[0].";sample=".$rl->{$key}.";\n";
            }
            else{
                $flag=0;
            }
        }
        next unless $flag;
        print $oh $line;
    }
    close($ih);
    close($oh);
    print STDOUT "[STATUS] Done!\n";

}


sub _getLookup{
    my ($files,$map) = @_;

    my $ml = [];
    my $reads = {};
    foreach my $f(@$files){
        print STDOUT "[STATUS]\tParsing file $f\n"; 
        my $i = scalar(@$ml);
        my $fn = (split(/\//,$f))[-1];
        die "No sample_id found for file $fn" unless $map->{$fn};
        push @$ml, $map->{$fn};


        my $ih;
        if($f=~/^.*.gz$/){
            open($ih,"-|","gunzip","-c",$f) or die "Failed to open $f for reading.";
        }
        else{
            open($ih,"<",$f) or die "Failed to open $f for reading.";
        }
        while(my $line=<$ih>){
            if($.==1||!(($.-1)%4)){
                my @ls = grep{$_ ne ""}split(/[@\s\t\n\r]/,$line);
                $ls[0]=~s/_/:/g;
                if($ls[0]=~/^(.*)\/[12]$/){
                    $ls[0]=$1;
                }
                $reads->{$ls[0]} = $map->{$fn};
            }
        }
        close($ih);
    }
    print STDOUT "[STATUS] Number of reads total: ".scalar(keys(%$reads))."\n";
    return ($reads,$ml);
}


sub _readMap{
    my $file = shift;
    my $result = {};
    open(my $ih,"<",$file) or die "Failed to open $file";
    while(my $line=<$ih>){
        my @ls = grep{$_ ne ""}split(/[\s\t\n]/,$line);
        die "Unknown line format! More than two elements found in line $line!\nDoes your sample ID or fastq file include spaces or tabs?" unless
        scalar(@ls)==2;
        $result->{$ls[0]} = $ls[1];
    }
    close($ih);
    return $result;
}

sub _checkMap{
    my ($map,$files) = @_;

    # check that all fastq files in mapping file are found in directory
    foreach my $fm(keys(%$map)){
        my $check = 0;
        my $fns = [];
        foreach my $f(@$files){
            my $fn = (split(/\//,$f))[-1];
            push @$fns, $fn;
            next unless $fn eq $fm;
            $check = 1;
        }
        if(!$check){
            warn "\n\n[ERROR] Filename $fm in mapping file does not match any of the given fastq files\n\tFastq file names in mapping file:\n".join(",",keys(%$map))."\n\n\tNames of given fastq files:\n\t".join(",",@$fns)."\n\n";
            _usage();
        }
    }
}


sub _usage{
    print STDOUT "\n\nScript adds the sample qualifier to sequences based on the name of a given fastq file.\nSequences that can not be assigned a sample are removed from the output file.\n";
    print STDOUT "Parameter:\n";
    print STDOUT "q : directory of fastq files\n";
    print STDOUT "f : fasta file\n";
    print STDOUT "o : output file\n";
    print STDOUT "m : mapping file of fastq file name to sample_id.\n    One line per sample: first fastq file name then sample_id separated by tab or
    space.\n";
    print STDOUT "\n";
    exit;
}

