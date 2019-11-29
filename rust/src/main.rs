use std::collections::{BTreeSet, HashMap};
use std::convert::Into;
use std::error::Error;
use std::fs::File;
use std::io::Write;
use std::io::{self, BufRead};
use std::path::{Path, PathBuf};

/*
LeadingUpperCamelCase: struct, trait
snake_case: everything else

TODO: read "rust turbofish" google results
*/

// TODO: reference to question operator and function returning a Result
fn main() -> Result<(), Box<dyn Error>> {
    let mut sorted_to_origs: HashMap<Vec<char>, BTreeSet<String>> = Default::default();

    for arg in std::env::args_os().skip(1) {
        let path: PathBuf = arg.into();
        add_words(&mut sorted_to_origs, &path)?;
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
            // TODO: find out best way to go from BTreeSet to slice so we can do slice.join()
            //Some(&orig_words) => println!("{}", orig_words.iter().collect::<Vec<_>>().join(", "))
            Some(orig_words) => {
                for word in orig_words {
                    print!("{} ", word);
                }
                println!("");
            }
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
    let mut sorted_chars: Vec<char> = word.chars().collect::<Vec<char>>();
    sorted_chars.sort();
    sorted_chars
}
