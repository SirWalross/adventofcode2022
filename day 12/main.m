heightmap = [];
fid = fopen('input');
tline = fgetl(fid);
i = 1;
positions = zeros(2, 2);
while ischar(tline)
    for j = 1:size(tline, 2)
        if tline(j) == 83
            positions(1, :) = [i, j];
        elseif tline(j) == 69
            positions(2, :) = [i, j];
            heightmap(i, j) = 25;
        else
            heightmap(i, j) = tline(j) - 97;
        end
    end
    tline = fgetl(fid);
    i = i + 1;
end
fclose(fid);
[visited, valuemap] = search_from_position(positions(1, :), positions(2, :), [], zeros(size(heightmap))+10000, heightmap);
valuemap(positions(2, 1), positions(2, 2))

function [visited, valuemap] = search_from_position(curr_pos, end_pos, visited, valuemap, heightmap)
    visited(end + 1, :) = curr_pos;
    last_a_index = find(heightmap(sub2ind(size(heightmap), visited(:, 1), visited(:, 2))) == 0, 1, 'last'); % find last a index
    if valuemap(curr_pos(1), curr_pos(2)) > (size(visited, 1) - last_a_index)
        valuemap(curr_pos(1), curr_pos(2)) = size(visited, 1) - last_a_index;
    else
        return;
    end
    if curr_pos(1) == end_pos(1) && curr_pos(2) == end_pos(2)
        return;
    end
    if size(visited, 1) > 2000
        return;
    end
    for dir = [1, 0; -1, 0; 0, 1; 0, -1]'
        next_pos = curr_pos + dir';
        if next_pos(1) > 0 && next_pos(2) > 0 && next_pos(1) <= size(heightmap, 1) && next_pos(2) <= size(heightmap, 2)
            [already_visited, ~] = ismember(next_pos, visited, 'rows');
            if ~already_visited
                if heightmap(next_pos(1), next_pos(2)) <= heightmap(curr_pos(1), curr_pos(2)) + 1
                    [~, valuemap] = search_from_position(next_pos, end_pos, visited, valuemap, heightmap);
                end
            end
        end
    end
end