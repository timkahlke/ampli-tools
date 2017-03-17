#!/usr/bin/perl

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

    my $m = _getM($in_file);
    open(my $oh,">",$out_file) or die "failed to open output file $out_file for writing.";
    print $oh "#OTU\t";
    for(my $x = 1;$x<(scalar(@{$m->[0]})-3);$x++){
        print $oh "Sample_".$x."\t"; 
    }
    print $oh "average\ttotal averages\trelative average\n";
    foreach my $line(@$m){
        next unless $line->[-1]>=$frac;
        print $oh join("\t",@$line)."\n";
    }
    close($oh);
}


sub _getSum{
    my $r = shift;
    my $sum = 0;
    foreach(@$r){
        $sum+=$_;
    }
    return $sum;
}


sub _getM{
    my ($file,$rc) = @_;

    my $result = [];
    my $sum_total = 0;
    open(my $ih,"<",$file) or die "Failed to open input file $file for reading";
    while(my $line=<$ih>){
        my @ls = split(/[\s\n\r\t]/,$line);
        my $sum = 0;
        for(my $i = 1;$i<scalar(@ls);$i++){
            $sum+=$ls[$i];
        }
        push @ls,($sum/(scalar(@ls)-1));
        $sum_total+=$ls[-1];
        push @$result,\@ls;
    }

    foreach my $l(@$result){
        push @$l,$sum_total;
        push @$l,($l->[-2]/$l->[-1]);
    }

    close($ih);
    return $result;
}


sub _usage{
    print STDOUT "\n\nScript takes a tab separates file of OTU counts (rows) per treatment (cols) and adds columns average count & sum abundance and removes OTUs below a given abundance \n";
    print STDOUT "Parameter:\n";
    print STDOUT "i : input table (tab separated)\n";
    print STDOUT "o : output list\n";
    print STDOUT "f : fraction of abundance (0.1 = 10%)\n";
    print STDOUT "\n\n";
    exit;
}




