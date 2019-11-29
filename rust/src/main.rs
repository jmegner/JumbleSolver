use std::error::Error;
use std::fs::File;
use std::io::prelude::*;
use std::io::{self, BufRead};
use std::path::Path;
use std::collections::{BTreeMap, BTreeSet};
use std::vec;

fn main() {
    let path = Path::new("../greetings.txt");
    let mut file = File::open(&path).expect("could not open dict file");
    let mut lineItr = io::BufReader::new(file).lines();
    let mut sortedToOrigs : BTreeMap<String,BTreeSet<String>> = Default::default();
    let x : Vec<u8> = Default::default();

    for line in lineItr {
        let origWord = line.expect("could not read line");
        let mut chars : Vec<char> = origWord.chars().collect();
        chars.sort();
        let sortedWord : String = chars.into_iter().collect();
        println!("orig={}", origWord);
        println!("sorted={}", sortedWord);
        //if sortedToOrigs.contains_key(&word)
    }

}

