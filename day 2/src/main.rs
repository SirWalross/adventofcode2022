use std::fs::File;
use std::io::{self, prelude::*, BufReader};

fn main() -> io::Result<()> {
    let file = File::open("input")?;
    let reader = BufReader::new(file);

    let mut curr = 0;

    let shape_score = [1, 2, 3];

    for line in reader.lines() {
        let line = line.unwrap();
        let line = line.as_bytes();
        let opponent = (line[0] - 'A' as u8) as i8;
        let strategy_guide = (opponent + ((line[2] - 'X' as u8) as i8 - 1)).rem_euclid(3);

        if strategy_guide - opponent == 1 || strategy_guide - opponent == -2 {
            curr += 6;
        } else if strategy_guide == opponent {
            curr += 3;
        }
        curr += shape_score[strategy_guide as usize];
    }

    println!("{}", curr);

    Ok(())
}