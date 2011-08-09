#! /usr/bin/env python

import sys
import fileinput


if len(sys.argv) < 2:
    print "usage: jumble_solver.py DICTIONARY_FILE [DICTIONARY_FILE] ..."
    exit(1)

sortedToOrigs = {};

for line in fileinput.input():
    origWord = line.strip().lower()
    sortedWord = "".join(sorted(origWord))

    if sortedToOrigs.has_key(sortedWord):
        origs = sortedToOrigs[sortedWord].add(origWord)
    else:
        sortedToOrigs[sortedWord] = set([origWord])

sys.stdout.write('$ ')

while True:
    line = sys.stdin.readline()

    if len(line) == 0:
        break

    sortedWord = "".join(sorted(line.strip().lower()))

    if sortedToOrigs.has_key(sortedWord):
        print " ".join(sortedToOrigs[sortedWord])
    else:
        print "no anagram in dictionary"

    sys.stdout.write('$ ')

print


