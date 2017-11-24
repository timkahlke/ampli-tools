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
    getopts("u:f:o:m:d:",\%opts);
    my $uf = $opts{'u'};
    my $of = $opts{'o'};
    my $ff = $opts{'f'};
    my $mf = $opts{'m'};
    my $df = $opts{'d'}?$opts{'d'}:0;

    if(!$uf||!$ff||!$of||!$mf){
        _usage();
    }

    print STDOUT "\n[STATUS] Reading mapping file\n";
    my $maps = _readMap($mf);

    foreach my $g(keys(%$maps)){
        print STDOUT "\n[STATUS] Compiling read names for group $g\n";
        # get reads of group
        my $reads = _getGroup($uf,$maps->{$g});
        if($df){
            print STDOUT "[STATUS] Adding dereplicated reads of group $g\n";
            my $derep = _getGroup($df,$reads);
            $reads = $derep;
        }
        print STDOUT "[STATUS] Reads in group $g: ".scalar(keys(%$reads))."\n";
        print STDOUT "[STATUS] Printing reads of group $g\n";
        _print($ff,$of,$reads,$g);
    }

    print STDOUT "[STATUS] Done!!\n\n";
}

sub _print{
    my ($ff,$of,$reads,$g) = @_;
    open(my $oh,">","$of/$g.fas") or die "Failed to open $of";
    open(my $fh,"<",$ff) or die "Failed to open fasta file $ff";
    my $p = 0;
    while(my $line=<$fh>){
        if($line=~/^>.*$/){
            my @s = grep{$_ ne ""}split(/[>\t\s]/,$line);
            $p=$reads->{$s[0]}?1:0;
        }
        next unless $p;
        print $oh $line;
    }
    close($oh);
}


sub _getGroup{
    my ($uf,$centroids) = @_;

    my $reads = {};
    open(my $uh,"<",$uf) or die "Failed to open $uf for reading";
    while(my $line=<$uh>){
        my @s = grep{$_ ne ""}split(/[\n\t]/,$line);
        next unless $centroids->{$s[-1]};
        $reads->{$s[-2]} = 1;
    }
    foreach my $c(keys(%$centroids)){
        $reads->{$c} = 1;
    }
    close($uh);
    return $reads;
}


sub _readMap{
    my $file = shift;
    my $m = {};
    open(my $mh,"<",$file) or die "Failed to open $file for reading";
    while(my $line=<$mh>){
        my @s = grep{$_ ne ""}split(/[\s\t\n\r]/,$line);
        $m->{$s[-1]}->{$s[0]} = 1;
    }
    close($mh);
    return $m;
}


sub _usage{
    print STDOUT "\nScript to extract sequences from a uc cluster file\n";
    print STDOUT "Parameter:\n";
    print STDOUT "u : uc file\n";
    print STDOUT "f : fasta file\n";
    print STDOUT "o : output fasta directory\n";
    print STDOUT "m : mapping file with first column representative sequence name, second column group name\n";
    print STDOUT "d : derep file of given uc file (optional)\n";
    print STDOUT "\n\n";
    exit;
}



