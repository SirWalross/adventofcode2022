function lines_from(file)
    local lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

local lines = lines_from('input')
local register = 1
local signal_strength = 0
local cycle = 0
local stack = 0
local instruction_count = 1
local instruction_stack = ""
local crt = {}

while instruction_count <= #lines do
    cycle = cycle + 1
    if cycle % 40 == 20 then
        signal_strength = signal_strength + register * cycle
    end
    if cycle % 40 >= register and cycle % 40 <= register + 2 then
        table.insert(crt, 1)
    else
        table.insert(crt, 0)
    end
    if instruction_stack == "" then
        instruction_stack = lines[instruction_count]
        instruction_count = instruction_count + 1
        if not string.match(instruction_stack, "noop") then
            stack = tonumber(string.sub(instruction_stack, 5))
        else
            instruction_stack = ""
        end
    else
        register = register + stack
        instruction_stack = ""
    end
end

print(signal_strength)

for index, pos in pairs(crt) do
    if pos == 0 then
        io.write(" ")
    else 
        io.write('█')
    end
    if index % 40 == 0 then
        print("")
    end
end