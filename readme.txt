Jumble Solver written multiple times in different programming languages.

used languages:
    c
    c++
    java
    perl
    ruby
    python
    scheme
    haskell

Each jumble solver takes dictionary files as command line arguments.  Once the
dictionary files are processed, the user is presented with a prompt.  Once the
user enters a word, the jumble solver prints out all anagrams of that word that
was found in the dictionary files. The get-word-print-anagrams process is
repeated until the user terminates input (either by doing ctrl+d on the
keyboard or the end of a file).

Each implementation uses a data structure that maps alphabetically-sorted words
to a set of all words that sort to that word.  So, each time the user provides
a word, the jumble solver sorts the word, and prints the corresponding
collection of words.  This technique was chosen for its simplicity and
computational efficiency.

