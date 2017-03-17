#!/usr/bin/perl

#   This script is used to filter tab separated files of relative OTU abundance (rows)
#   and replicates (columns) by a given fraction threshold.
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
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
    getopts("i:f:o:",\%opts);
    my $in_file = $opts{'i'};
    my $out_file = $opts{'o'};
    my $frac = $opts{'f'};

    if(!$in_file||!$out_file||!$frac){
        _usage();
    }

    # get rows of abundances
    my $m = _getM($in_file);


    open(my $oh,">",$out_file) or die "failed to open output file $out_file for writing.";

    #print header of output file
    print $oh "#OTU\t";
    for(my $x = 1;$x<(scalar(@{$m->[0]})-3);$x++){
        print $oh "Replicate_".$x."\t"; 
    }
    print $oh "average\ttotal averages\trelative average\n";

    # filter and print output
    foreach my $line(@$m){
        next unless $line->[-1]>=$frac;
        print $oh join("\t",@$line)."\n";
    }
    close($oh);
}

# Read tab separated file with OTUs in rows and replicates in columns
sub _getM{
    my ($file,$rc) = @_;

    my $result = [];

    # Total sum of relative OTU abundance (should always be ~1)
    my $sum_total = 0;

    open(my $ih,"<",$file) or die "Failed to open input file $file for reading";
    while(my $line=<$ih>){

        # Ignore comments
        next if $line=~/^#.*$/;

        my @ls = split(/[\s\n\r\t]/,$line);

        # Sum of relative OTU abundance (row) in all replicates
        my $sum = 0;
        for(my $i = 1;$i<scalar(@ls);$i++){
            $sum+=$ls[$i];
        }

        # add row sum to array
        push @ls,($sum/(scalar(@ls)-1));

        # add row sum to total fraction
        $sum_total+=$ls[-1];
        push @$result,\@ls;
    }

    # In case the abundance was calculated with more OTUs than 
    # included in the table this re-calculates the abundance based
    # on the sum of the average abundance.
    foreach my $l(@$result){
        push @$l,$sum_total;
        push @$l,($l->[-2]/$l->[-1]);
    }

    close($ih);
    return $result;
}


sub _usage{
    print STDOUT "\n\nScript takes a tab separates file of overal relative OTU abundance (rows) per replicate (cols),\nadds columns \'average count\' and \'sum abundance\' and removes OTUs below a given abundance \n";
    print STDOUT "Note: Rows starting with \'#\' are ignored. First column is considered OTU name\n";
    print STDOUT "Parameter:\n";
    print STDOUT "i : input table (tab separated)\n";
    print STDOUT "o : output list\n";
    print STDOUT "f : fraction of abundance (0.1 = 10%)\n";
    print STDOUT "\n\n";
    exit;
}




