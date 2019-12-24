/*
My thanks to Jimmy Brisson for interactively helping me through a lot of this
program and educating me on language features I had not yet read about.
https://github.com/theotherjimmy

My thanks to Guillaume Depardon (Globi#0117/Globi::<!> on Rust's Discord
channel https://discord.gg/rust-lang) for helping me understand and fix my
problems with std::slice::Join::join (https://doc.rust-lang.org/std/slice/trait.Join.html)
https://github.com/Globidev

Some notes for people unfamiliar with Rust language...

Rust has two naming styles...
    LeadingUpperCamelCase: struct, trait
    snake_case: everything else

Rust has Hindley-Milner type inference, where the desired return type can be
used by the compiler to select the appropriate function; sometimes the
turbofish operator ("::<Something>") is needed (especially for collect method)
for compiler to figure out desired return type; articles:
    https://matematikaadit.github.io/posts/rust-turbofish.html
    https://techblog.tonsser.com/posts/what-is-rusts-turbofish

The "What is Rust's Turbofish" article above also explains that the Into<T>::into method can not be
simply turbofished with "someVar.into::<DesiredType>()"; you'd have to do
"Into::<DesiredType>::into(someVar)";

The question/? operator is used on Result types, either UNWRAPPING the Ok's inner value or
RETURNING the Err's inner value;
https://doc.rust-lang.org/edition-guide/rust-2018/error-handling-and-panics/the-question-mark-operator-for-easier-error-handling.html

I still don't fully understand why our Err portion of our Result types was chosen to be
Box<dyn Error>; I think we need to box the error so the size/type does not have to be fully
determined at build time (and furthermore we don't have to choose a type at build time and convert
errors into our chosen type); I think the "dyn" keyword is part of making it explicit that "Error"
in "dyn Error" is a trait (dynamically sized), not a type (statically sized).

As of 2019-12-04, Racer issue #1033 means that RLS autocomplete does not work for all things inside the
standard prelude; when I was using std::convert::Into<T>::into, I had to add "use
std::convert::Into;" for RLS autocomplete to work; https://github.com/racer-rust/racer/issues/1033
*/

use itertools;
use std::collections::{BTreeSet, HashMap};
use std::error::Error;
use std::fs::File;
use std::io::Write;
use std::io::{self, BufRead};
use std::path::Path;

type WordMap = HashMap<Vec<char>, BTreeSet<String>>;

fn main() -> Result<(), Box<dyn Error>> {
    if std::env::args_os().count() < 2 {
        println!("usage: jumble_solver_rust.exe DICTIONARY_FILE [DICTIONARY_FILE] ...");
        return Ok(());
    }

    let mut sorted_to_origs: WordMap = Default::default();

    // following works even if given a path-string with invalid unicode;
    // could use std::env::args(), which will panic if given invalid unicode;
    for arg in std::env::args_os().skip(1) {
        add_words(&mut sorted_to_origs, Path::new(&arg))?;
    }

    print!("$ ");
    std::io::stdout().flush()?;

    for line in std::io::stdin().lock().lines() {
        let word = line?;

        if word.is_empty() {
            break;
        }

        match sorted_to_origs.get(&as_sorted_lowercase(&word)) {
            None => println!("no anagrams in dictionary"),
            Some(orig_words) => println!("{}", itertools::join(orig_words, ", ")),
            // an alternate way without itertools crate...
            //Some(orig_words) => println!("{}", orig_words.iter().map(String::as_str).collect::<Vec<_>>().join(", ")),
        }

        print!("$ ");
        std::io::stdout().flush()?;
    }

    Ok(())
}

fn add_words(sorted_to_origs: &mut WordMap, path: &Path) -> Result<(), Box<dyn Error>> {
    let file = File::open(&path)?;

    for line in io::BufReader::new(file).lines() {
        add_word(sorted_to_origs, &line?);
    }

    Ok(())
}

fn add_word(sorted_to_origs: &mut WordMap, word: &str) {
    let lower_word = word.to_ascii_lowercase();
    let sorted_chars = as_sorted_lowercase(&lower_word);

    sorted_to_origs
        .entry(sorted_chars)
        .or_default()
        .insert(lower_word);
}

fn as_sorted_lowercase(word: &str) -> Vec<char> {
    itertools::sorted(word.to_ascii_lowercase().chars()).collect()
    /* // an alernate way without itertools crate...
    let mut sorted_chars = word.to_ascii_lowercase().chars().collect::<Vec<_>>();
    sorted_chars.sort();
    sorted_chars
    */
}

#[cfg(test)]
#[macro_use]
extern crate maplit;

#[cfg(test)]
mod tests {
    use super::*;

    struct TestData {
        word_1: String,
        word_2: String,
        word_1_2_sorted: Vec<char>,
        map_0: WordMap,
        map_1: WordMap,
        map_2: WordMap,
    }

    impl TestData {
        fn new() -> TestData {
            TestData {
                word_1: String::from("bat"),
                word_2: String::from("tab"),
                word_1_2_sorted: vec!['a', 'b', 't'],
                map_0: WordMap::new(),
                map_1: hashmap! { word_1_2_sorted.clone() => btreeset!{String::from(word_1)} },
                map_2: hashmap! { word_1_2_sorted.clone() => btreeset!{String::from(word_1), String::from(word_2)} },
            }
        }
    }

    #[test]
    fn word_sorted() {
        assert_eq!(as_sorted_lowercase("CBabC"), vec!['a', 'b', 'b', 'c', 'c']);
    }

    #[test]
    fn word_added_to_empty() {
        let answers = TestData::new();
        let mut sorted_to_origs: WordMap = Default::default();
        add_word(&mut sorted_to_origs, &answers.word_1);
        assert_eq!(&sorted_to_origs, &answers.map_1);
    }

    #[test]
    fn word_added_to_existing() {
        let answers = TestData::new();
        let mut sorted_to_origs = answers.map_1;
        add_word(&mut sorted_to_origs, &answers.word_2);
        assert_eq!(&sorted_to_origs, &answers.map_2)
    }
}
