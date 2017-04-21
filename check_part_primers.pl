#!/usr/bin/perl

use strict;
use Data::Dumper;
use Getopt::Std;

#########
#
# check_part_primers.pl - script to check for partial primers 
# in the beginning of reads
#
######
##   COPYRIGHT DISCALIMER:
##   This program is free software: you can redistribute it and/or modify
##   it under the terms of the GNU General Public License as published by
##   the Free Software Foundation, either version 3 of the License, or
##   (at your option) any later version.
##
##   This program is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU General Public License for more details.
##
##   You should have received a copy of the GNU General Public License
##   along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
##
##
##   Author: Tim Kahlke, tim.kahlke@audiotax.is
##   Date:   April 2017
##
#


eval{
    _main();
};

if($@){
    _main();
}


sub _main{
    our %opts;
    getopts("f:p:",\%opts);

    my $fq = $opts{'f'};
    my $p = $opts{'p'};

    if(!$fq||!$p){
        _usage();
    }

    my $last = _getNuc(substr($p,length($p)-1));
    die $last;

    open(my $fh,"<",$fq) or die "Failed to open $fq for reading";

    my $stats = {};

    while(my $line=<$fh>){
        if(($.==2)||(!(($.-2)%4))){
            my $inds = [];
            for(my $i=0;$i<length($last);$i++){
                my $li = index($line,$last);
                if($li<length($p)){
                    push @$inds,$li;
                }
            }
            my $strings = _getStrings($inds,$p);
            my $regs = _getRE($strings);

            my $match = 0;
            for my $r(keys(%$regs)){
                if($line=~/^$r.*$/){
                    $match = length($regs->{$r})>length($match)?$regs->{$r}:$match;
                }
            }
            $stats->{$match}=$stats->{$match}?$stats->{$match}+1:1; 
        }
    }
     


}




sub _getStrings{
    my ($list,$p) = @_;

    my $s = [];
    foreach($list){
        push @$s,substr($p,$_);
    }
    return $s;
}



sub _getNuc{
    my $n = shift;
    my $deg = {'R' => 'AG',
               'Y' => 'CT',
               'M' => 'AC',
               'K' => 'GT',
               'S' => 'CG',
               'W' => 'AT',
               'H' => 'ACT',
               'B' => 'CGT',
               'V' => 'ACG',
               'D' => 'AGT',
               'N' => 'ATCG]'
           };
    
    if($deg->{$n}){
        return $deg->{$n};
    }
    return $n;
}



sub _getRE{
    my $primers = shift;
    my $regs = {};

    foreach my $p (@$primers){
        my $regexp = "";
        foreach(split(//,$p)){
            my $nuc = _getNuc($_);
            if(length($nuc)>1){
                $nuc = "[$nuc]";
            }
            $regexp.=$nuc;
        }
        $regs->{$regexp} = $p;
    }
    return $regs;
}


sub _usage{
    print STDOUT "\n\nScript to check for presence of partial primers int he beginning of reads.\n";
    print STDOUT "Parameters:\n";
    print STDOUT "f : input fastq file\n";
    print STDOUT "p : primer (can be degenerated)\n";
    print STDOUT "\n\n";
    exit;
}



