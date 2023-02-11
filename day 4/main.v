import regex
import os

fn main() {
    lines := os.read_lines('input')!
	mut re := regex.regex_opt(r'\d+')?
	mut curr := 0
	for line in lines {
		numbers := re.find_all_str(line).map(it.int())
		println(numbers)
        if (numbers[1] >= numbers[2] && numbers[0] <= numbers[2]) || (numbers[3] >= numbers[0] && numbers[2] <= numbers[0]) {
            curr++
        }
	}
	println(curr)
}