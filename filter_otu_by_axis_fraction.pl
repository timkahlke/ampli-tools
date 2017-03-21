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
    getopts("a:i:o:f:",\%opts);
    
    my $if = $opts{'i'};
    my $of = $opts{'o'};
    my $frac = $opts{'f'};
    my $axis = $opts{'a'}?$opts{'a'}:"y";

    if(!$if||!$of||!$frac||($axis ne "x" && $axis ne "y")){
        _usage();
    }

    print STDOUT "\n[STATUS] Parsing OTU file...\n";
    my ($ch,$m) = _readOTU($if);
    print STDOUT "... Done.\n";

    print STDOUT "\n[STATUS] Filtering OTUs ...\n";
    my $keep = _filterM($m,$frac,scalar(@$ch)-1,$axis);
    print STDOUT "... Done.\n";

    print STDOUT "\n[STATUS] Writing output file ...\n";
    open(my $oh,">",$of) or die "Failed to open $of";

    # add additionaly columns
    if($axis eq "x"){
        push @$ch, "row average";
        push @$ch, "total average";
        push @$ch, "adjusted average";
    }

    # print header
    print $oh join("\t",@$ch)."\n";

    # write rows
    foreach my $otu(sort(@$keep)){
        print $oh $otu."\t".join("\t",@{$m->{$otu}})."\n";
    }
    close($oh);

    print STDOUT "... Done.\n\n\n";
}


# Get name of OTUs to keep
# sn = number of samples in matrix
sub _filterM{
    my ($m,$frac,$sn,$axis) = @_;

    my $kh = {};
    # Average over columns
    if($axis eq "y"){
        for(my $i = 0;$i<$sn;$i++){

            # get column sum
            my $sum = _getXSum($i,$m);

            # check if OTU if above given fraction 
            foreach(keys(%$m)){
                if(($m->{$_}->[$i]/$sum)>=$frac){
                    $kh->{$_} = 1;
                }
            }
        }
    }
    else{

        # total aaverage
        my $ta = 0;
        foreach my $r(keys(%$m)){

            # get row sum
            my $sum = _getYSum($m->{$r});

            # add row average to row
            push @{$m->{$r}},($sum/$sn);

            # add total average
            $ta += ($sum/$sn);
        } 

        # In case the abundance was calculated with more OTUs than 
        # included in the table this re-calculates the abundance based
        # on the sum of the average abundance.
        foreach my $r(keys(%$m)){

            # add total average (same for all rows)
            push @{$m->{$r}},$ta;

            # add adjusted average
            push @{$m->{$r}},($m->{$r}->[-2]/$m->{$r}->[-1]);

            # get rows above threshold
            if($m->{$r}->[-1]>=$frac){
                $kh->{$r} = 1;
            }
        }
    }

    my @keep = keys(%$kh);
    return \@keep;
}


# Get row sum
sub _getYSum{
    my $r = shift;
    my $sum = 0;
    foreach(@$r){
        $sum+=$_;
    }
    return $sum;
}


# Get column sum
sub _getXSum{
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

    $ch[-1]=~s/[\r\n]//g;

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
    print STDOUT "i : input OTU table\n";
    print STDOUT "o : output file\n";
    print STDOUT "f : minimum percentage of OTUs to keep (0.1 = 10%)\n";
    print STDOUT "a : axis to average over, x for rows, y for columns (default = y)\n    If set to x three additional columns will be added:\n    \'row average\',\'total average\' and \'adjusted average\'\n";
    print STDOUT "\n\n";
    exit;
}




