#!/usr/bin/perl
#
#   demultiplex.pl
#
#   Simple demultiplexing script for demultiplexing reads of structure:
#   BARCODE (fw) - PRIMER (fw) - INSERT - PRIMER (rv) - BARCODE (rv) - ILLUMINA PRIMER
#   
#   The script demultiplexes by 
#   1. concatenating the forward and reverse barcode-primer 
#   2. Search for reads that start with forward concatenated sequence (100% match)
#   3. Look for 100% match of reverse concatenated sequrnce.
#   NOTE: Reverse sequence match can be ANYWHERE IN THE SEQUENCE! No positional
#         information taken into account!
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
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

#   Author: Tim Kahlke, tim.kahlke@uts.edu.au
#   Date: January 2017

use strict;
use Getopt::Std;
use Data::Dumper;
use warnings;

eval{
    _main();
};

if($@){
    print $@;
}


sub _main{
    our %opts;
    getopts("i:o:m:cf",\%opts);
    my $in = $opts{'i'};
    my $m = $opts{'m'};
    my $od = $opts{'o'};
    my $clip = $opts{'c'};
    my $fasta = $opts{'f'};

    if(!$in||!$m||!$od){
        _usage();
    }

    my $oligos = _readOligos($m);
    my $ms = _getMatchSeqs($oligos);
    _demux($od,$ms,$clip,$in,$fasta);

    print STDOUT "\n\nDone. Output written to $od.\n\n";
}
        

sub _getFHs{
    my ($ms,$od,$fasta) = @_;
    my $fhs = {};
   
    foreach my $s(keys(%$ms)){
        open(my $fh,">","$od/$s.fastq") or die "Failed to open $od/$s.fastq for writing";
        $fhs->{'fastq'}->{$s} = $fh;
        if($fasta){
            open(my $fh,">","$od/$s.fasta") or die "Failed to open $od/$s.fasta for writing.";
            $fhs->{'fasta'}->{$s} = $fh;
        }
    }
    return $fhs;
}


sub _close{
    my $fhs = shift;
    foreach my $k(keys(%$fhs)){
        foreach(keys(%{$fhs->{$k}})){
            close($fhs->{$k}->{$_});
        }
    }
}


sub _demux{
    my ($od,$ms,$clip,$in,$fasta) = @_;

    my $fhs = _getFHs($ms,$od,$fasta);

    my $ih;
    if($in=~/.*\.gz$/){
        open($ih,"-|","gunzip","-c",$in) or die "Failed to open $in for reading.";
    }
    else{
        open($ih,"<",$in) or die "Failed to open file $in for reading.";
    }

    print STDOUT "\n[STATUS] Parsing file $in\n";
    while(!(eof $ih)){
        my $sid = readline($ih);
        my $seq = readline($ih);
        my $plus = readline($ih);
        my $qual = readline($ih)."\n";
        $qual=~s/\n\n/\n/;

        if(!(($./4)%10000)){
            print STDOUT "\t$. lines parsed\n";
        }

        foreach my $s(keys(%$ms)){
            my $f = $ms->{$s}->{'forward'};
            my $r = $ms->{$s}->{'reverse'};

            if($seq=~/^$f(.*)$r(.*)$/){
                my $insert = $1;
                next unless length($insert);
                my $suffix = $2;
                if($clip){
                    $seq=$insert."\n";
                    $qual = substr($qual,length($f),length($insert))."\n";
                }
                my $oh = $fhs->{'fastq'}->{$s};
                print $oh "$sid$seq$plus$qual";
                if($fasta){
                    my $fh = $fhs->{'fasta'}->{$s};
                    $sid=~s/@//;
                    print $fh ">$sid$seq";
                }
                last;
            }
        }
    }
    close($ih);
    _close($fhs);
}


sub _getMatchSeqs{
    my $oligos = shift;
    my $ms = {};

    my $p3 = $oligos->{'p3'}?$oligos->{'p3'}:"";
    warn "[WARNING] No P3 Illumina primer found! Using empty string instead!" unless $p3;

    my $fp = $oligos->{'primer'}->{'forward'}?$oligos->{'primer'}->{'forward'}:"";
    warn "[WARNING] No forward primer found! Using empty string instead" unless $fp;

    my $rp = $oligos->{'primer'}->{'reverse'}?$oligos->{'primer'}->{'reverse'}:"";
    warn "[WARNING] No reverse primer found! Using empty string instead" unless $rp;

    foreach my $k(keys(%{$oligos->{'barcode'}})){
        $ms->{$k}->{'forward'} = $oligos->{'barcode'}->{$k}->{'forward'}.$fp;
        $ms->{$k}->{'reverse'} = $rp.$oligos->{'barcode'}->{$k}->{'reverse'}.$p3;
    }
    return $ms;
}



sub _readOligos{
    my $file = shift;

    my $oligos = {};
    open(my $ih,"<",$file) or die "Failed to open $file for reading";
    while(my $line=<$ih>){
        my @ls = grep{$_ ne ""}split(/[\s\t\n\r]/,$line);
        if($line=~/^primer.*$/){
            $oligos->{'primer'} = {forward=>$ls[1],reverse=>$ls[2]};
        }
        elsif($line=~/^barcode.*$/){
            $oligos->{'barcode'}->{$ls[-1]} = {forward=>$ls[1],reverse=>$ls[2]};
        }
        elsif($line=~/^p3.*$/){
            $oligos->{'p3'} = $ls[1];
        }
        else{
            warn "Unknown foramt of line! Ignoring line $line";
        }
    }
    close($ih);
    return $oligos;
}


sub _usage{
    print STDOUT "\n\nBasic demultiplexing tool using exact matches on dual-barcode single-end files.\n";
    print STDOUT "Parameter:\n";
    print STDOUT "i : input fastq file\n";
    print STDOUT "m : mothur oligos file for primer and barcode\n";
    print STDOUT "    Format of mapping file:\n";
    print STDOUT "    primer FORWARD BACKWARD\n";
    print STDOUT "    p3 additional primer, e.g. p3_ILLUMINA_PRIMER\n";
    print STDOUT "    barcode FORWARD BACKWARD\n";
    print STDOUT "    ...\n\n";
    print STDOUT "o : directory for output files\n";
    print STDOUT "c : if set primer and barcodes will be clipped from reads\n";
    print STDOUT "f : if set fasta files will be written out, too.\n";
    print STDOUT "\n\n";
    exit;
}





