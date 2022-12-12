type public Monkey(in_items, in_operation, in_test, in_new_monkeys) =
    let mutable items: uint64 list = in_items
    let operation = in_operation
    let test: uint64 = in_test
    let new_monkeys: int list = in_new_monkeys
    let mutable inspection_count: uint64 = 0UL

    member self.update(denominator: uint64) =
        inspection_count <- inspection_count + (items.Length |> uint64)
        let updated_values = items |> Seq.map(fun item -> operation(item) % denominator) |> Seq.toList
        let items_monkey1 = updated_values |> Seq.filter(fun item -> item % test = 0UL) |> Seq.toList;
        let items_monkey2 = updated_values |> Seq.filter(fun item -> item % test <> 0UL) |> Seq.toList;
        items <- [];
        ((new_monkeys[0], items_monkey1), (new_monkeys[1], items_monkey2))

    member self.add_items(new_items: uint64 list) =
        items <- items @ new_items
        
    member this.InspectionCount = inspection_count
    
    member this.Items = items

let readLines = System.IO.File.ReadLines("../../../input");
let mutable monkeys = []
let mutable items = []
let mutable test: uint64 = 0UL;
let mutable new_monkeys: int list = [];
let mutable operation = "";
let mutable denominator = 1UL;

// parse input to create monkeys
readLines |> Seq.iter(fun line -> 
    if line.StartsWith("  Starting items: ") then
        items <- items @ (line[18..].Split(", ") |> Seq.map(fun num -> num |> uint64) |> Seq.toList);
    if line.StartsWith("  Test: divisible by ") then
        test <- line[21..] |> uint64;
        denominator <- denominator * test;
    if line.StartsWith("    If true: throw to monkey ") then
        new_monkeys <- new_monkeys @ [line[29..] |> int]
    if line.StartsWith("    If false: throw to monkey ") then
        new_monkeys <- new_monkeys @ [line[30..] |> int]
        let value: uint64 = if operation[2] <> 'o' then operation[2..] |> uint64 else 0UL;
        let operation_fun = if operation[0] = '+' then (if operation[2] = 'o' then (fun (old) -> old + old) else (fun (old) -> old + value)) else (if operation[2] = 'o' then (fun (old) -> old * old) else (fun (old) -> old * value))
        monkeys <- monkeys @ [Monkey(items, operation_fun, test, new_monkeys)]
        items <- []
        new_monkeys <- []
    if line.StartsWith("  Operation: new = old ") then
        operation <- line[23..]
)

for i in 0..9999 do
    for j in 0..monkeys.Length-1 do
        let ((monkey1, monkey1_list), (monkey2, monkey2_list)) = monkeys[j].update(denominator);
        monkeys[monkey1].add_items(monkey1_list)
        monkeys[monkey2].add_items(monkey2_list)

let inspection_counts = monkeys |> Seq.map(fun monkey -> monkey.InspectionCount) |> Seq.toList |> List.sortBy (fun x -> System.UInt64.MaxValue - x);
printfn "level of monkey business: %d" (inspection_counts[0] * inspection_counts[1])