package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

type Element struct {
	single_value bool
	value        int
	childs       []Element
	parent       *Element
}

type Outcome struct {
	val int
}

func undecided() Outcome {
	return Outcome{1}
}

func right_order() Outcome {
	return Outcome{2}
}

func wrong_order() Outcome {
	return Outcome{3}
}

func (l *Element) right_order(r *Element) Outcome {
	if l.single_value && r.single_value {
		if l.value < r.value {
			return right_order()
		} else if l.value > r.value {
			return wrong_order()
		} else {
			return undecided()
		}
	}
	if !l.single_value && !r.single_value {
		var index = 0
		for true {
			if index < len(l.childs) && index < len(r.childs) {
				var return_value = l.childs[index].right_order(&r.childs[index])
				if return_value == undecided() {
					index++
					continue
				} else {
					return return_value
				}
			} else if len(l.childs) > len(r.childs) {
				return wrong_order()
			} else if len(l.childs) < len(r.childs) {
				return right_order()
			} else {
				return undecided()
			}
		}
	}
	if l.single_value {
		// promote left value to list
		l.single_value = false
		l.childs = append(l.childs, Element{true, l.value, []Element{}, l})
		return_value := l.right_order(r)

		// undo promotion
		l.single_value = true
		l.childs = []Element{}
		return return_value
	} else {
		// promote right value to list
		r.single_value = false
		r.childs = append(r.childs, Element{true, r.value, []Element{}, r})
		return_value := l.right_order(r)

		// undo promotion
		r.single_value = true
		r.childs = []Element{}
		return return_value
	}
}

func (elem *Element) to_string() string {
	if elem.single_value {
		return fmt.Sprintf("%d", elem.value)
	} else {
		var string_array = []string{}
		for index := range elem.childs {
			string_array = append(string_array, elem.childs[index].to_string())
		}
		return fmt.Sprintf("[%s]", strings.Join(string_array, ","))
	}
}

func main() {
	file, err := os.Open("input")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	comparison := 0
	var comparisons = []Element{}

	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			continue
		}
		index := 1
		comparisons = append(comparisons, Element{})
		var curr_elem *Element = &comparisons[len(comparisons)-1]
		for index < len(line)-1 {
			if line[index] == '[' {
				curr_elem.single_value = false
				curr_elem.childs = append(curr_elem.childs, Element{})
				curr_elem.childs[len(curr_elem.childs)-1].parent = curr_elem
				curr_elem = &curr_elem.childs[len(curr_elem.childs)-1]
			} else if line[index] == ']' {
				curr_elem = curr_elem.parent
			} else if line[index] != ',' {
				num, err := strconv.Atoi(strings.Split(strings.Split(strings.Split(line[index:], ",")[0], "]")[0], "[")[0])
				if err != nil {
					panic(err)
				}
				index += len(strconv.Itoa(num))
				curr_elem.childs = append(curr_elem.childs, Element{true, num, []Element{}, curr_elem})
				continue
			}
			index++
		}
		comparison++
	}

	index := 0
	count := 0

	for index < len(comparisons) {
		if comparisons[index].right_order(&comparisons[index+1]) == right_order() {
			count += index/2 + 1
		}
		index += 2
	}
	println(count)

	// include two divider packets
	comparisons = append(comparisons, Element{false, 0, make([]Element, 1), nil})
	comparisons[len(comparisons)-1].childs[0] = Element{false, 0, make([]Element, 1), nil}
	comparisons[len(comparisons)-1].childs[0].childs[0] = Element{true, 2, []Element{}, &comparisons[len(comparisons)-1]}
	comparisons = append(comparisons, Element{false, 0, make([]Element, 1), nil})
	comparisons[len(comparisons)-1].childs[0] = Element{false, 0, make([]Element, 1), nil}
	comparisons[len(comparisons)-1].childs[0].childs[0] = Element{true, 6, []Element{}, &comparisons[len(comparisons)-1]}

	sorted_indices := make([]int, len(comparisons))
	for i := range sorted_indices {
		sorted_indices[i] = i
	}
	var swaps = 1

	for swaps != 0 {
		swaps = 0
		index = 0
		for index < len(sorted_indices)-1 {
			if comparisons[sorted_indices[index]].right_order(&comparisons[sorted_indices[index+1]]) == wrong_order() {
				// in wrong order
				temp := sorted_indices[index+1]
				sorted_indices[index+1] = sorted_indices[index]
				sorted_indices[index] = temp
				swaps++
			}

			index++
		}
	}
	var distress_key = 1
	for index := range sorted_indices {
		if comparisons[sorted_indices[index]].to_string() == "[[2]]" || comparisons[sorted_indices[index]].to_string() == "[[6]]" {
			distress_key *= index + 1
		}
	}
	println(distress_key)
}
