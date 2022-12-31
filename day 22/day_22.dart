import 'dart:async';
import 'dart:io';
import 'dart:convert';

void main() async {
  var path = "input";
  var columns = 0;
  final facesize = 50;
  final facecount = 3; // number of faces in one line
  final wraparounds = {
    2: [
      {"face": 7, "dir": 3},
      {"face": 4, "dir": 3},
      {"face": 1, "dir": 3},
      {"face": 9, "dir": 0},
    ],
    1: [
      {"face": 2, "dir": 1},
      {"face": 4, "dir": 2},
      {"face": 6, "dir": 1},
      {"face": 9, "dir": 1}
    ],
    4: [
      {"face": 2, "dir": 0},
      {"face": 7, "dir": 2},
      {"face": 6, "dir": 2},
      {"face": 1, "dir": 0}
    ],
    6: [
      {"face": 7, "dir": 1},
      {"face": 9, "dir": 2},
      {"face": 1, "dir": 1},
      {"face": 4, "dir": 1}
    ],
    7: [
      {"face": 2, "dir": 3},
      {"face": 9, "dir": 3},
      {"face": 6, "dir": 3},
      {"face": 4, "dir": 0}
    ],
    9: [
      {"face": 7, "dir": 0},
      {"face": 2, "dir": 2},
      {"face": 1, "dir": 2},
      {"face": 6, "dir": 0}
    ]
  };
  // final wraparounds = {
  //   2: [
  //     {"face": 11, "dir": 3},
  //     {"face": 6, "dir": 2},
  //     {"face": 5, "dir": 2},
  //     {"face": 4, "dir": 2}
  //   ],
  //   4: [
  //     {"face": 5, "dir": 1},
  //     {"face": 10, "dir": 0},
  //     {"face": 11, "dir": 0},
  //     {"face": 2, "dir": 2},
  //   ],
  //   5: [
  //     {"face": 6, "dir": 1},
  //     {"face": 10, "dir": 1},
  //     {"face": 4, "dir": 3},
  //     {"face": 2, "dir": 1}
  //   ],
  //   6: [
  //     {"face": 11, "dir": 2},
  //     {"face": 10, "dir": 2},
  //     {"face": 5, "dir": 3},
  //     {"face": 2, "dir": 0}
  //   ],
  //   10: [
  //     {"face": 11, "dir": 1},
  //     {"face": 4, "dir": 0},
  //     {"face": 5, "dir": 0},
  //     {"face": 6, "dir": 0}
  //   ],
  //   11: [
  //     {"face": 2, "dir": 3},
  //     {"face": 4, "dir": 1},
  //     {"face": 10, "dir": 3},
  //     {"face": 6, "dir": 3}
  //   ]
  // };

  var map = List.generate(0, (_) => [], growable: true);

  var index = 0;
  var directions = "";

  await new File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(new LineSplitter())
      .forEach((line) {
    if (index == 0) {
      columns = line.length;
    }
    if (line != "" && !line.startsWith(RegExp(r'[A-Z0-9]'))) {
      map.add(List.filled(columns, 2));
      line.codeUnits
          .asMap()
          .forEach((i, e) => map[index][i] = e == 46 ? 0 : (e == 35 ? 1 : 2));
    }
    index++;
    directions = line;
  });
  final position = [map[0].indexOf(0), 0];
  var heading = 1;
  index = 0;
  while (index < directions.length) {
    if (directions.substring(index).startsWith(RegExp(r'\D'))) {
      final turn = directions[index];
      index += 1;
      heading = (heading + (turn == "R" ? 1 : -1)) % 4;
    } else {
      final match = RegExp(r'(\d+)').firstMatch(directions.substring(index));
      final offset = int.parse(match?.group(1));
      index += match?.group(1).length;
      for (int i = 0; i < offset; i++) {
        final new_pos = [position[0], position[1], heading];
        new_pos[0] += (heading % 2 == 1) ? (-1 * (heading - 2)) : 0;
        new_pos[1] += (heading % 2 == 0) ? (1 * (heading - 1)) : 0;
        if (new_pos[1] >= map.length ||
            new_pos[1] < 0 ||
            new_pos[0] >= map[0].length ||
            new_pos[0] < 0 ||
            map[new_pos[1]][new_pos[0]] == 2) {
          // boarder -> wrap
          final current_face =
              position[0] ~/ facesize + (position[1] ~/ facesize) * facecount;
          final new_face = wraparounds[current_face][(heading - 1) % 4]["face"];
          final new_heading =
              wraparounds[current_face][(heading - 1) % 4]["dir"];
          var offset = ((heading % 2 == 0) ? (position[0]) : 0) % facesize +
              ((heading % 2 == 1) ? (position[1]) : 0) % facesize;
          if (heading == 1 || heading == 0) {
            offset = facesize - offset - 1;
          }
          // offset from left point of connecting edge of the two faces
          if (new_heading == 0 || new_heading == 1) {
            offset = facesize - offset - 1;
          }
          new_pos[0] = new_face % facecount * facesize +
              ((new_heading % 2 == 0) ? offset : 0) +
              (new_heading == 3 ? facesize - 1 : 0);
          new_pos[1] = new_face ~/ facecount * facesize +
              ((new_heading % 2 == 1) ? offset : 0) +
              (new_heading == 0 ? facesize - 1 : 0);
          new_pos[2] = new_heading;
        }
        if (map[new_pos[1]][new_pos[0]] == 1) {
          // wall -> stop
          break;
        } else {
          // empty space -> move
          position[0] = new_pos[0];
          position[1] = new_pos[1];
          heading = new_pos[2];
        }
        // print("new position ${position}");
      }
    }
  }
  print(
      "Final password: ${1000 * (position[1] + 1) + 4 * (position[0] + 1) + (heading - 1) % 4}");
}
