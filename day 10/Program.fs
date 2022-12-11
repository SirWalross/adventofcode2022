let readLines = Microsoft.FSharp.Collections.List.ofSeq(System.IO.File.ReadLines("../../../input"));
let mutable register = 1;
let mutable signal_strength = 0;
let mutable cycle = 0;
let mutable stack = 0;
let mutable instruction_count = 0;
let mutable instruction_stack = "";
let mutable crt = []

while instruction_count < readLines.Length do
    cycle <- cycle + 1;
    if cycle % 40 = 20 then
        signal_strength <- signal_strength + register * cycle;
    crt <- crt @ [if cycle % 40 >= register && cycle % 40 <= register+2 then 1 else 0];
    printfn "%d" register;
    if instruction_stack = "" then
        instruction_stack <- readLines[instruction_count]
        instruction_count <- instruction_count + 1;
        if instruction_stack <> "noop" then 
            stack <- instruction_stack[5..] |> int
        else
            instruction_stack <- ""
    else
        register <- register + stack;
        instruction_stack <- ""

printfn "%d" signal_strength

crt |> Seq.indexed |> Seq.iter(fun (index, pos) -> 
    let character = if pos = 0 then "." else "#";
    printf "%s" character;
    if index % 40 = 39 then
        printfn "";
)