#!/usr/bin/perl

#   This script is used to filter an OTU table based on per sample abundance 
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
#   Date: March 2017


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
    getopts("i:o:f:",\%opts);
    
    my $if = $opts{'i'};
    my $of = $opts{'o'};
    my $frac = $opts{'f'};

    if(!$if||!$of||!$frac){
        _usage();
    }

    print STDOUT "\n[STATUS] Parsing OTU file...\n";
    my ($ch,$m) = _readOTU($if);
    print STDOUT "... Done.\n";

    print STDOUT "\n[STATUS] Filtering OTUs ...\n";
    my $keep = _filterM($m,$frac,scalar(@$ch)-1);
    print STDOUT "... Done.\n";

    print STDOUT "\n[STATUS] Writing output file ...\n";
    open(my $oh,">",$of) or die "Failed to open $of";
    print $oh join("\t",@$ch);
    foreach my $otu(sort(@$keep)){
        print $oh $otu."\t".join("\t",@{$m->{$otu}})."\n";
    }
    close($oh);
    print STDOUT "... Done.\n\n\n";
}


# Get name of OTUs to keep
# sn = number of samples in matrix
sub _filterM{
    my ($m,$frac,$sn) = @_;

    my $kh = {};
    for(my $i = 0;$i<$sn;$i++){
        my $sum = _getSampleSum($i,$m);
        foreach(keys(%$m)){
            if(($m->{$_}->[$i]/$sum)>=$frac){
                $kh->{$_} = 1;
            }
        }
    }
    my @keep = keys(%$kh);
    return \@keep;
}

# Get abundance sum of sample
sub _getSampleSum{
    my ($i,$m) = @_;
    my $sum = 0;
    foreach(keys(%$m)){
        $sum+=$m->{$_}->[$i];
    }
    return $sum;
}

# return hash of OTU->[sample_abundance]
# and array of column header 
sub _readOTU{
    my $file = shift;
    my $m = {};
    open(my $ih,"<",$file) or die "Failed to open $file";
    my @ch = split(/\t/,readline($ih));
    while(my $line=<$ih>){
        $line=~s/[\r\n]//g;
        my @ls = split(/\t/,$line);
        my $otu = shift(@ls);
        $m->{$otu} = \@ls;
    }
    close($ih);
    return(\@ch,$m);
}


sub _usage{
    print STDOUT "\n\n\Script to filter OTU table by per sample fraction\n";
    print STDOUT "Parameter:\n";
    print STDOUT "i : input OTU table:\n\tRows = OTUs\n\tColumns = Samples\n\tFirst row and column = headers\n";
    print STDOUT "o : output file\n";
    print STDOUT "f : minimum percentage of OTUs to keep (0.1 = 10%)\n";
    print STDOUT "\n\n";
    exit;
}




