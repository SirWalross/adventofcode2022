line = readlines("input")[1]
offsets = zeros(Int32, (length(line), 2))
for (i,char) in enumerate(line)
    if char == '<'
        offsets[i, 2] = -1
    else
        offsets[i, 2] = 1
    end
end

chamber = zeros(Int32, (1, 7))
rocks = Vector{Array{Int32, 2}}()

function expand_chamber(rock, highest_row)
    new_row_count = 3 + size(rock, 1) + highest_row - size(chamber, 1)
    if new_row_count > 0
        global chamber = [zeros(Int32, (new_row_count, 7)); chamber]
    end
end

function populate_rocks()
    push!(rocks, ones(Int32, (1, 4)))
    push!(rocks, ones(Int32, (3, 3)))
    global rocks[end][[1, 3], [1, 3]] .= 0
    push!(rocks, ones(Int32, (3, 3)))
    global rocks[end][[2, 3], [1, 2]] .= 0
    push!(rocks, ones(Int32, (4, 1)))
    push!(rocks, ones(Int32, (2, 2)))
end

function check_collision(rock, relative_position)
    for (y, _) in enumerate(rock[1:end, 1])
        for (x, _) in enumerate(rock[1, 1:end])
            # println("pos: (", relative_position[1], ",", relative_position[2], "), x: ", x, ", y: ", y, ", real_x: ", x + relative_position[2] - 1, ", real_y: ", size(chamber, 1) - y - relative_position[1] + 2)
            position = [size(chamber, 1) - y - relative_position[1] + 2, x + relative_position[2] - 1]
            if position[1] <= 0 || position[1] > size(chamber, 1) || position[2] <= 0 || position[2] > size(chamber, 2)
                return true
            end
            if rock[y, x] != 0 && chamber[position[1], position[2]] != 0
                return true
            end
        end
    end
    return false
end

function calc_highest_row()
    for row = 1:size(chamber,1)
        if sum(chamber[row, 1:end]) != 0
            return size(chamber,1) - row + 1
        end
    end
    return 0
end

function write_rock(rock, relative_position)
    for (y, _) in enumerate(rock[1:end, 1])
        for (x, _) in enumerate(rock[1, 1:end])
            if rock[y, x] != 0
                global chamber[size(chamber, 1) - y - relative_position[1] + 2, x + relative_position[2] - 1] = 1
            end
        end
    end
end

populate_rocks()
highest_row = 0
rock_index = 0
offset_index = 0
rock_position = [3, 3]

while true
    rock = rocks[rock_index % length(rocks) + 1]
    expand_chamber(rock, highest_row)
    global rock_position = [4 + highest_row, 3]
    while true
        offset = offsets[offset_index % size(offsets, 1) + 1, 1:end]
        global offset_index += 1
        # check for collision while moving from jet streams
        if !check_collision(rock, rock_position + offset)
            global rock_position += offset
            # println("Rock moved by airstream to ", rock_position)
        end
        # check for collision while moving downwoards
        if !check_collision(rock, rock_position + [-1, 0])
            global rock_position += [-1, 0]
            # println("Rock moved down to ", rock_position)
        else
            write_rock(rock, rock_position)
            # println("Rock hit bottom")
            break
        end
    end
    global highest_row = calc_highest_row()
    global rock_index += 1
    if rock_index == 1730
        break
    end
end
# display(chamber)

periodicity_start = 1730
periodicity = 343 * 5
height_periodicity = 2690
height_start = 0

println((1000000000000 - periodicity_start) % periodicity)
highest_row += (1000000000000 - periodicity_start) / periodicity  * height_periodicity
println(highest_row)