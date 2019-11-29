use std::collections::{BTreeSet, HashMap};
use std::error::Error;
use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;
use std::vec;

/*
LeadingUpperCamelCase: struct, trait
snake_case: everything else

TODO: read "rust turbofish" google results
*/

// TODO: reference to question operator and function returning a Result
fn main() -> Result<(), Box<dyn Error>> {
    let path = Path::new("../greetings.txt");
    let file = File::open(&path)?;
    let mut sorted_to_origs: HashMap<String, BTreeSet<String>> = Default::default();
    let x: Vec<u8> = Default::default();

    for line in io::BufReader::new(file).lines() {
        let orig_word = line?;
        let mut chars: Vec<char> = orig_word.chars().collect::<Vec<char>>();
        chars.sort();
        let sorted_word: String = chars.into_iter().collect();
        println!("orig={}, sorted={}", orig_word, sorted_word);
        //if sortedToOrigs.contains_key(&word)
    }

    Ok(())
}
