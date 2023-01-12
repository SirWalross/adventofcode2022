class Position
{
    public int x { get; set; }
    public int y { get; set; }

    public Position(int x, int y)
    {
        this.x = x;
        this.y = y;
    }

    public Position Offset(int direction)
    {
        direction = (direction >= 0) ? direction : 8 + direction;
        int y = this.y +
            (direction >= 3 && direction <= 5 ? 1 : 0) -
            (direction >= 7 || direction <= 1 ? 1 : 0);
        int x = this.x +
            (direction >= 1 && direction <= 3 ? 1 : 0) -
            (direction >= 5 && direction <= 7 ? 1 : 0);
        return new Position(x, y);
    }
}

class Elf
{
    public Position position { get; set; }
    public int[] directions { get; private set; } = { 0, 4, 6, 2 };
    public Position proposed_position { get; private set; }

    public Elf(Position position)
    {
        this.position = position;
        this.proposed_position = new Position(-1, -1);
    }

    public void propose_move(Elfmap map)
    {
        this.proposed_position = new Position(-1, -1);
        if (Enumerable.Range(0, 10).Select(dir => map.has_elf(this.position.Offset(dir))).Any(item => item))
        {
            foreach (int dir in this.directions)
            {
                if (map.is_empty(this.position.Offset(dir - 1)) && map.is_empty(this.position.Offset(dir)) && map.is_empty(this.position.Offset(dir + 1)))
                {
                    this.proposed_position = this.position.Offset(dir);
                    break;
                }
            }
        }
        int first_dir = this.directions[0];
        for (int i = 0; i < this.directions.Length - 1; i++)
        {
            this.directions[i] = this.directions[i + 1];
        }
        this.directions[^1] = first_dir;
    }
}

class Elfmap
{
    public int[,] map = new int[300, 300];

    public bool is_empty(Position position)
    {
        return position.x >= 0 &&
        position.x < map.GetLength(1) &&
        position.y >= 0 &&
        position.y < map.GetLength(0) &&
        map[position.y, position.x] == 0;
    }

    public bool has_elf(Position position)
    {
        return position.x >= 0 &&
            position.x < map.GetLength(1) &&
            position.y >= 0 &&
            position.y < map.GetLength(0) &&
            map[position.y, position.x] == 1;
    }

    public bool move(List<Elf> elves)
    {
        var groups = elves.Select((pos, i) => new { Value = new { pos.proposed_position.y, pos.proposed_position.x }, Index = i }).GroupBy(dict => dict.Value).ToDictionary(x => x.Key, x => x.Select(y => y.Index).ToArray());
        var count = 0;
        foreach (var (position, indices) in groups)
        {
            if (indices.Length == 1)
            {
                map[elves[indices[0]].position.y, elves[indices[0]].position.x] = 0;
                map[position.y, position.x] = 1;
                elves[indices[0]].position = new Position(position.x, position.y);
                count++;
            }
        }
        return count != 0;
    }

    public int count_empty_ground_tiles(List<Elf> elves)
    {
        int x_min = elves.Min(elf => elf.position.x);
        int x_max = elves.Max(elf => elf.position.x);
        int y_min = elves.Min(elf => elf.position.y);
        int y_max = elves.Max(elf => elf.position.y);

        int count = 0;
        for (int y = y_min; y <= y_max; y++)
        {
            for (int x = x_min; x <= x_max; x++)
            {
                if (map[y, x] == 0)
                    count++;
            }
        }
        return count;
    }
}

class Program
{
    static void Main(string[] args)
    {
        Elfmap map = new Elfmap();
        List<Elf> elves = new List<Elf>();
        var index_y = 0;
        foreach (string line in File.ReadLines("../../../input"))
        {
            var index_x = 0;
            foreach (char character in line)
            {
                if (character == '#')
                {
                    map.map[index_y + 100, index_x + 100] = 1;
                    elves.Add(new Elf(new Position(index_x + 100, index_y + 100)));
                }
                index_x++;
            }
            index_y++;
        }

        int i = 1;
        for (; i < 1000000; i++)
        {
            foreach (Elf elf in elves)
            {
                elf.propose_move(map);
            }
            if (!map.move(elves))
            {
                break;
            }
        }
        Console.WriteLine(i);
        Console.WriteLine(map.count_empty_ground_tiles(elves));
    }
}