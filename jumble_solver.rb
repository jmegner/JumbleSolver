#! /usr/bin/env ruby

require 'set'


if ARGV.size() < 1
    puts "usage: jumble_solver.rb DICIONARY_FILE [DICTIONARY_FILE] ..."
    exit(1)
end

sortedToOrigs = Hash.new()

ARGV.each { |dictFileName|
    IO.foreach(dictFileName) { |dictWord|
        dictWord.strip!()
        sortedWord = dictWord.split("").sort().join("")

        if !sortedToOrigs.has_key?(sortedWord)
            sortedToOrigs[sortedWord] = Set.new([])
        end

        sortedToOrigs[sortedWord].add(dictWord)
    }
}

print '$ '

while jumbledWord = STDIN.gets
    sortedWord = jumbledWord.strip!().split("").sort().join("")

    if sortedToOrigs.has_key?(sortedWord)
        puts sortedToOrigs[sortedWord].to_a().join(" ")
    else
        puts "no anagram in dictionary"
    end

    print '$ '
end

puts ""


