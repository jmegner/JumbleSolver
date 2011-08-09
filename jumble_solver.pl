#! /usr/bin/env perl

use strict;
use warnings;


if(scalar(@ARGV) < 1){
    print("usage: jumble_solver.pl DICTIONARY_FILE [DICTIONARY_FILE] ...\n");
}

my $sortedToOrigs = {};
for my $dictFileName (@ARGV) {
    open(DICT_FILE, "<$dictFileName");

    while(my $origWord = <DICT_FILE>){
        chomp($origWord);

        my $sortedWord = sortString($origWord);
        $sortedToOrigs->{$sortedWord}->{$origWord} = 1;
    }
    close(DICT_FILE);
}

print('$ ');

while(my $jumbledWord = <STDIN>){
    chomp($jumbledWord);
    my $sortedWord = sortString($jumbledWord);

    if(exists($sortedToOrigs->{$sortedWord})){
        print(join(" ", keys(%{$sortedToOrigs->{$sortedWord}})) . "\n");
    }
    else {
        print("no anagram found in dictionary\n");
    }

    print('$ ');
}
print("\n");


sub sortString {
    return join("", sort(split("",$_[0])));
}


