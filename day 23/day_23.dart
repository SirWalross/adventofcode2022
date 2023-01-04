import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}

class Position implements Comparable {
  int x;
  int y;
  Position(this.x, this.y);

  String toString() {
    return "(${x}, ${y})";
  }

  Position offset(int direction) {
    direction = direction % 8;
    final y = this.y +
        (direction >= 3 && direction <= 5 ? 1 : 0) -
        (direction >= 7 || direction <= 1 ? 1 : 0);
    final x = this.x +
        (direction >= 1 && direction <= 3 ? 1 : 0) -
        (direction >= 5 && direction <= 7 ? 1 : 0);
    return Position(x, y);
  }

  @override
  int compareTo(other) {
    if (other.x == this.x && other.y == this.y) {
      return 0;
    } else if (other.y > this.y || (other.y == this.y && other.x > this.x)) {
      return -1;
    } else {
      return 1;
    }
  }

  @override
  bool operator ==(other) {
    if (other is Position) {
      return other.x == this.x && other.y == this.y;
    } else {
      return false;
    }
  }
}

extension MapExt<T, U> on Map<T, U> {
  Map<T, U> sortedBy(Comparable value(U u)) {
    final entries = this.entries.toList();
    entries.sort((a, b) => value(a.value).compareTo(value(b.value)));
    return Map<T, U>.fromEntries(entries);
  }
}

class Elf {
  Position position;
  List<int> direction_list = [0, 4, 6, 2];
  Position proposed_position = Position(-1, -1);
  Elf(this.position);

  String toString() {
    return "<Elf: ${position}, ${direction_list}, ${proposed_position}>";
  }

  void propose_move(Elfmap map) {
    this.proposed_position = Position(-1, -1);
    if ([for (var i = 0; i < 10; i += 1) i]
        .map((dir) => map.hasElf(position.offset(dir)))
        .any((element) => element)) {
      for (final dir in direction_list) {
        if (map.isEmpty(position.offset(dir - 1)) &&
            map.isEmpty(position.offset(dir)) &&
            map.isEmpty(position.offset(dir + 1))) {
          this.proposed_position = this.position.offset(dir);
          break;
        }
      }
    }
    final first_dir = this.direction_list[0];
    for (int i = 0; i < this.direction_list.length - 1; i++) {
      this.direction_list[i] = this.direction_list[i + 1];
    }
    this.direction_list[this.direction_list.length - 1] = first_dir;
  }
}

class Elfmap {
  List<List<int>> map = List.generate(0, (_) => [], growable: true);

  bool isEmpty(Position position) {
    return position.x >= 0 &&
        position.x < map[0].length &&
        position.y >= 0 &&
        position.y < map.length &&
        map[position.y][position.x] == 0;
  }

  bool hasElf(Position position) {
    return position.x >= 0 &&
        position.x < map[0].length &&
        position.y >= 0 &&
        position.y < map.length &&
        map[position.y][position.x] == 1;
  }

  String toString() {
    String string = "";
    map.forEach((element) {
      element.forEach((element) {
        if (element == 1) {
          string += "#";
        } else {
          string += ".";
        }
      });
      string += "\n";
    });
    return string.substring(0, string.length - 1);
  }

  bool move(List<Elf> elves) {
    final duplicates = elves
        .map((elf) => elf.proposed_position)
        .toList()
        .asMap()
        .sortedBy((u) => u);
    List keys = duplicates.keys.toList();
    List<Position> values = duplicates.values.toList();
    var count = 0;
    for (int i = 0; i < elves.length; i++) {
      if ((i >= elves.length - 1 || values[i] != values[i + 1]) &&
          (i <= 0 || values[i] != values[i - 1]) &&
          values[i].x != -1) {
        if (map[elves[keys[i]].proposed_position.y]
                [elves[keys[i]].proposed_position.x] ==
            1) {
          print("Error!");
        }
        map[elves[keys[i]].position.y][elves[keys[i]].position.x] = 0;
        map[elves[keys[i]].proposed_position.y]
            [elves[keys[i]].proposed_position.x] = 1;
        elves[keys[i]].position = elves[keys[i]].proposed_position;
        count++;
      }
    }
    return count != 0;
  }

  int empty_ground_tiles(List<Elf> elves) {
    final List<int> x_val = elves.map((elf) => elf.position.x).toList();
    final List<int> y_val = elves.map((elf) => elf.position.y).toList();
    final x_min = x_val.reduce(min);
    final x_max = x_val.reduce(max);
    final y_min = y_val.reduce(min);
    final y_max = y_val.reduce(max);

    int count = 0;
    for (int x = x_min; x <= x_max; x++) {
      for (int y = y_min; y <= y_max; y++) {
        if (map[y][x] == 0) {
          count++;
        }
      }
    }
    return count;
  }
}

void main() async {
  var path = "input";
  Elfmap map = Elfmap();
  List<Elf> elves = [];

  final size = [300, 300];
  final origin = [100, 100];
  map.map = List.generate(size[0], (i) => List<int>.filled(size[1], 0),
      growable: false);

  var index = 0;

  await new File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(new LineSplitter())
      .forEach((line) {
    line.codeUnits.asMap().forEach((i, e) => {
          if (e != 46)
            {
              map.map[index + origin[0]][i + origin[1]] = 1,
              elves.add(Elf(Position(i + origin[1], index + origin[0])))
            }
        });
    index++;
  });

  var i = 1;

  for (; i < 100000; i++) {
    for (final elf in elves) {
      elf.propose_move(map);
    }
    if (!map.move(elves)) {
      break;
    }
  }
  print(i);
  // print(map);
  print(map.empty_ground_tiles(elves));
}
