import Swift
import Foundation


func wrap_around_modulu(a: Int, b: Int) -> Int {
    return (b + (a % b)) % b;
}

func get_position_on_board(index_map: [Int: Int], mix_index: Int, length: Int) -> Int {
    for i in 0...(length - 1) {
        if (index_map[i] == mix_index) {
            return i;
        }
    }
    print("Error!!\n");
    return 0;
}

func move_number(array: inout [Int], index_map: inout [Int: Int], mix_index: Int) {
    let index = get_position_on_board(index_map: index_map, mix_index: mix_index, length: array.count)
    var offset = array[index] % array.count
    if (abs(array[index]) > array.count) {
        offset = array[index] % (array.count - 1)
    }
    let prev = array[index]
    if (offset == 0) {
        return
    } else if (offset > 0) {
        // move all to the left
        for i in stride(from: index, to: index + offset, by: 1) {
            let old_index = wrap_around_modulu(a: i + 1, b: array.count)
            let new_index = wrap_around_modulu(a: i, b: array.count)
            array[new_index] = array[old_index]
            index_map[new_index] = index_map[old_index]!
        }
    } else {
        // move all to the right
        for i in stride(from: index, to: index + offset, by: -1) {
            let old_index = wrap_around_modulu(a: i - 1, b: array.count)
            let new_index = wrap_around_modulu(a: i, b: array.count)
            array[new_index] = array[old_index]
            index_map[new_index] = index_map[old_index]!
        }
    }
    let new_index = wrap_around_modulu(a: index + offset, b: array.count)
    array[new_index] = prev;
    index_map[new_index] = mix_index
}

let data = try String(contentsOfFile: "input", encoding: .utf8)
var array = data.components(separatedBy: .newlines).map { 811589153 * Int($0)! }
var index_map: [Int: Int] = Dictionary(uniqueKeysWithValues: array.enumerated().map { (index, element) in (Int(index), index) }) // map from position to mix_index
let zero_mix_index = array.enumerated().filter {(index, value) in value == 0}[0].offset

for _ in 0...9 {
    for index in 0...(array.count - 1) {
        move_number(array: &array, index_map: &index_map, mix_index: index)
    }
}

let zero_index = get_position_on_board(index_map: index_map, mix_index: zero_mix_index, length: array.count);
print("\(array[wrap_around_modulu(a: 1000 + zero_index, b: array.count)] + array[wrap_around_modulu(a: 2000 + zero_index, b: array.count)] + array[wrap_around_modulu(a: 3000 + zero_index, b: array.count)])")