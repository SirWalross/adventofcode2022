use std::fs::File;
use std::io::{self, prelude::*, BufReader};

fn main() -> io::Result<()> {
    let file = File::open("input")?;
    let reader = BufReader::new(file);

    let mut max = [0; 3];
    let mut curr = 0;

    let mut it = reader.lines().peekable();
    while let Some(line) = it.next() {
        if line.is_err() {
            break;
        }
        let line = line.unwrap();
        if !line.is_empty() {
            curr += line.parse::<i32>().unwrap();
        }
        if line.is_empty() || it.peek().is_none() {
            let mut a = curr;
            let mut b;
            for i in 0..max.len() {
                b = max[i];
                max[i] = std::cmp::max(max[i], a);
                a = std::cmp::min(a, b);
            }
            curr = 0;
        }
    }

    println!("{:?}", max);
    println!("{:?}", max.iter().sum::<i32>());
    Ok(())
}
