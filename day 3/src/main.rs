use std::fs::File;
use std::io::{self, prelude::*, BufReader};

use itertools::Itertools;

fn main() -> io::Result<()> {
    let file = File::open("input")?;
    let reader = BufReader::new(file);

    let mut curr: u32 = 0;

    for line in &reader.lines().into_iter().chunks(3) {
        let lines = line.map(|l| l.unwrap()).collect::<Vec<_>>();
        let mut duplicate: u128 = 0;
        for (i, line) in lines.iter().enumerate() {
            let items = line.as_bytes();
            for item in items {
                let val = if item >= &('a' as u8) {
                    item - 'a' as u8
                } else {
                    item - 'A' as u8 + 26
                };
                if i <= 1 {
                    duplicate |= 1 << (val as usize + 52 * i);
                } else if (duplicate & 1 << (val as usize)) != 0
                    && (duplicate & 1 << (val as usize + 52)) != 0
                {
                    curr += val as u32 + 1;
                    break;
                }
            }
        }
    }

    println!("{}", curr);

    Ok(())
}
