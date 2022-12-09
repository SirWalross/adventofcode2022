use regex::Regex;
use std::fs::File;
use std::io::{self, prelude::*, BufReader};

fn main() -> io::Result<()> {
    let file = File::open("input")?;
    let reader = BufReader::new(file);

    const initial_stack_size: usize = 8;

    let mut towers: Option<Vec<[u8; 70]>> = None;
    let mut stack_size: Vec<usize> = vec![0; 0];

    for (i, line) in reader.lines().enumerate() {
        let line = line.unwrap();
        let re = Regex::new(r"move (\d+) from (\d+) to (\d+)").unwrap();
        let captures = re.captures(&line);

        if i == 0 {
            let tower_count = (line.len() + 1) / 4;
            towers = Some((0..tower_count).map(|_| [0; 70]).collect());
            stack_size = (0..tower_count).map(|_| 0).collect();
        }
        if captures.is_none() {
            for (j, item) in line.as_bytes().iter().enumerate() {
                if item >= &('A' as u8) && item <= &('Z' as u8) {
                    match towers {
                        Some(ref mut towers) => {
                            towers[(j / 4) as usize][initial_stack_size - i - 1] = item - 'A' as u8;
                            stack_size[(j / 4) as usize] += 1;
                        }
                        _ => (),
                    };
                }
            }
        } else {
            match towers {
                Some(ref mut towers) => {
                    let numbers = captures.unwrap();
                    let numbers: Vec<u8> = numbers
                        .iter()
                        .skip(1)
                        .map(|n| n.unwrap().as_str().parse::<u8>().unwrap())
                        .collect();
                    let count = (numbers[0] - 1) as usize;
                    let from = (numbers[1] - 1) as usize;
                    let to = (numbers[2] - 1) as usize;
                    let _from_numbers: Vec<u8> = towers[from].into_iter().collect();
                    _from_numbers.into_iter().enumerate().for_each(|(i, n)| {
                        if n != 0 && i >= stack_size[from] - count - 1 && i < stack_size[from] {
                            towers[to][stack_size[to] + (i - (stack_size[from] - count - 1))] = n;
                            towers[from][i] = 0;
                        }
                    });
                    stack_size[from] -= count + 1;
                    stack_size[to] += count + 1;
                }
                _ => (),
            };
        }
    }

    for tower in towers.unwrap() {
        for (i, _crate) in tower.into_iter().enumerate() {
            if _crate == 0 {
                print!("{}", ('A' as u8 + tower[i - 1]) as char);
                break;
            }
        }
    }
    println!("");


    Ok(())
}
