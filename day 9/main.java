import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashSet;
import java.util.Set;

class Point {
    public int x;
    public int y;

    Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

    @Override
    public int hashCode() {
        return x * 1000 + y;
    }

    @Override
    public boolean equals(Object obj) {
        return (obj instanceof Point) && (((Point) obj).x == this.x) && (((Point) obj).y == this.y);
    }
}

class Main {
    public static Point calc_new_tail_pos(Point tail, Point head) {
        Point offset = new Point(head.x - tail.x, head.y - tail.y);
        int len = Math.abs(offset.x) + Math.abs(offset.y);
        Boolean diagonal = offset.x != 0 && offset.y != 0;
        if (len == 2 && !diagonal) {
            // move towards head
            return new Point(tail.x + offset.x / 2, tail.y + offset.y / 2);
        } else if ((len == 3 || len == 4) && diagonal) {
            // move towards diagonal pos
            return new Point(tail.x + Integer.signum(offset.x), tail.y + Integer.signum(offset.y));
        } else {
            // dont move
            return new Point(tail.x, tail.y);
        }
    }

    public static Point calc_direction(char direction) {
        if (direction == 'R') {
            return new Point(1, 0);
        } else if (direction == 'U') {
            return new Point(0, 1);
        } else if (direction == 'L') {
            return new Point(-1, 0);
        } else {
            return new Point(0, -1);
        }
    }

    public static void main(String[] args) throws IOException {
        Set<Point> visited = new HashSet<Point>();
        Point[] rope = new Point[10];
        for (int i = 0; i < rope.length; i++) {
            rope[i] = new Point(0, 0);
        }

        Files.lines(Paths.get("input")).forEach((line) -> {
            Point direction = calc_direction(line.charAt(0));
            int magnitude = Integer.parseInt(line.substring(2));
            for (int i = 1; i <= magnitude; i++) {
                rope[0] = new Point(rope[0].x + direction.x, rope[0].y + direction.y);
                for (int j = 1; j < rope.length; j++) {
                    rope[j] = calc_new_tail_pos(rope[j], rope[j - 1]);
                }
                visited.add(new Point(rope[rope.length - 1].x, rope[rope.length - 1].y));
            }
        });
        System.out.println(visited.size());
    }
}