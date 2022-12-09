use std::fs::File;
use std::io::{self, prelude::*, BufReader};
use regex::Regex;

fn main() -> io::Result<()> {
    let file = File::open("input")?;
    let reader = BufReader::new(file);

    let mut curr = 0;

    for line in reader.lines() {
        let line = line.unwrap();
        let re = Regex::new(r"(\d+)\-(\d+),(\d+)\-(\d+)").unwrap();
        let numbers = re.captures(&line).unwrap();
        let numbers: Vec<u8> = numbers.iter().skip(1).map(|n| n.unwrap().as_str().parse::<u8>().unwrap()).collect();
        if (numbers[1] >= numbers[2] && numbers[0] <= numbers[2]) || (numbers[3] >= numbers[0] && numbers[2] <= numbers[0]) {
            curr += 1;
        }
    }

    println!("{}", curr);

    Ok(())
}