/*
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

use std::collections::{BTreeSet, HashMap};
use std::error::Error;
use std::fs::File;
use std::io::Write;
use std::io::{self, BufRead};
use std::path::Path;
use itertools;

fn main() -> Result<(), Box<dyn Error>> {
    let mut sorted_to_origs: HashMap<Vec<char>, BTreeSet<String>> = Default::default();

    // following works even if given a path-string with invalid unicode;
    // could use std::env::args(), which will panic if given invalid unicode;
    for arg in std::env::args_os().skip(1) {
        add_words(&mut sorted_to_origs, Path::new(&arg))?;
    }

    print!("$ ");
    std::io::stdout().flush()?;

    for line in std::io::stdin().lock().lines() {
        let word = line?.to_ascii_lowercase();

        if word.is_empty() {
            break;
        }

        match sorted_to_origs.get(&as_sorted(&word)) {
            None => println!("no anagrams in dictionary"),
            Some(orig_words) => println!("{}", itertools::join(orig_words, ", ")),
            // an alternate way without itertools crate...
            // Some(orig_words) => println!("{}", orig_words.iter().cloned().collect::<Vec<_>>().join(", ")),
        }

        print!("$ ");
        std::io::stdout().flush()?;
    }

    Ok(())
}

fn add_words(
    sorted_to_origs: &mut HashMap<Vec<char>, BTreeSet<String>>,
    path: &Path,
) -> Result<(), Box<dyn Error>> {
    let file = File::open(&path)?;

    for line in io::BufReader::new(file).lines() {
        let orig_word = line?.to_ascii_lowercase();
        let sorted_chars = as_sorted(&orig_word);

        sorted_to_origs
            .entry(sorted_chars)
            .or_default()
            .insert(orig_word);
    }

    Ok(())
}

fn as_sorted(word: &str) -> Vec<char> {
    itertools::sorted(word.chars()).collect()
    /* // an alernate way without itertools crate...
    let mut sorted_chars = word.chars().collect::<Vec<_>>();
    sorted_chars.sort();
    sorted_chars
    */
}
