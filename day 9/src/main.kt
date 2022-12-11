import java.io.File
import java.io.InputStream
import kotlin.math.*

fun calc_new_tail_pos(tail: Pair<Int, Int>, head: Pair<Int, Int>): Pair<Int, Int> {
    val offset = Pair(head.first - tail.first, head.second - tail.second);
    val len = abs(offset.first) + abs(offset.second)
    val diagonal = offset.first != 0 && offset.second != 0
    if (len == 2 && !diagonal) {
        // move towards head
        return Pair(tail.first + offset.first / 2, tail.second + offset.second / 2)
    } else if ((len == 3 || len == 4) && diagonal) {
        // move towards diagonal pos
        return Pair(tail.first + offset.first.sign, tail.second + offset.second.sign)
    } else {
        // dont move
        return tail
    }
}

fun calc_direction(direction: Char): Pair<Int, Int> {
    if (direction == 'R') {
        return Pair(1, 0)
    } else if (direction == 'U') {
        return Pair(0, 1)
    } else if (direction == 'L') {
        return Pair(-1, 0)
    } else if (direction == 'D') {
        return Pair(0, -1)
    } else {
        // should never happen
        return Pair(0, 0)
    }
}

fun main(args: Array<String>) {
    val inputStream: InputStream = File("input").inputStream()
    val lineList = mutableListOf<String>()

    var visited = mutableSetOf<Pair<Int, Int>>()
    var rope = Array(10) {Pair(0, 0)}

    inputStream.bufferedReader().forEachLine { lineList.add(it) } 

    lineList.forEach { 
        val direction = calc_direction(it[0])
        val magnitude = it.drop(2).toInt()
        for (i in 1..magnitude) {
            rope[0] = Pair(rope[0].first + direction.first, rope[0].second + direction.second)
            for (j in 1..rope.size-1) {
                rope[j] = calc_new_tail_pos(rope[j], rope[j-1])
            }
            visited += rope[rope.size-1]
        }
     }

     println(visited.size)
}