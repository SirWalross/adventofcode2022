fid = fopen('input');
tline = fgetl(fid);
field = [];
start_x = 300;
while ischar(tline)
    char_index = 1;
    last_position = [0, 0];
    while char_index < size(tline, 2)
        x = str2double( regexp(tline(char_index:end), '\d+', 'match', 'once' ));
        char_index = char_index + size(num2str(x), 2) + 1;
        y = str2double( regexp(tline(char_index:end), '\d+', 'match', 'once' ));
        char_index = char_index + size(num2str(y), 2) + 4;
        if last_position(1) == 0
            field(y + 1, x - start_x + 1) = 1;
        else
            offset = [y + 1 - last_position(1), x - start_x + 1 - last_position(2)];
            step = sign(offset);
            if step(1) == 0
                field(last_position(1):(y + 1), last_position(2):step(2):(x - start_x + 1)) = 1;
            else
                field(last_position(1):step(1):(y + 1), last_position(2):(x - start_x + 1)) = 1;
            end
        end
        last_position = [y + 1, x - start_x + 1];
    end
    tline = fgetl(fid);
end
fclose(fid);
% generate bottom
field(end+2, 1:400) = 1;

sand_spawn = [1, 500-start_x+1];
finished = false;
units_of_sand = 0;
while ~finished
    sand_position = sand_spawn;
    while true
        if field(sand_position(1) + 1, sand_position(2)) == 0
            sand_position = sand_position + [1, 0];
        elseif field(sand_position(1) + 1, sand_position(2) - 1) == 0
            sand_position = sand_position + [1, -1];
        elseif field(sand_position(1) + 1, sand_position(2) + 1) == 0
            sand_position = sand_position + [1, 1];
        else
            field(sand_position(1), sand_position(2)) = 2;
            units_of_sand = units_of_sand + 1;
            if all(sand_position == sand_spawn)
                finished = true;
            end
            break;
        end
    end
end
units_of_sand