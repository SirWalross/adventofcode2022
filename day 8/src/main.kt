import java.io.File
import java.io.InputStream

fun not_in_range(row: Int, column: Int, row_count: Int, column_count: Int): Boolean {
    return !(row in 1..(row_count - 2) && column in 1..(column_count - 2))
}

fun to_direction(i: Int): Pair<Int, Int> {
    if (i == 0) {
        return Pair(1, 0)
    } else if (i == 1) {
        return Pair(-1, 0)
    } else if (i == 2) {
        return Pair(0, 1)
    } else {
        return Pair(0, -1)
    }
}

fun main(args: Array<String>) {
    val inputStream: InputStream = File("input").inputStream()
    val lineList = mutableListOf<String>()

    var visible = 0;

    inputStream.bufferedReader().forEachLine { lineList.add(it) } 

    val column_count = 99 // lineList[0].size
    val row_count = lineList.size

    var max_scenic_score = 0

    lineList.forEachIndexed { row_index, row ->
        row.forEachIndexed { column_index, value -> 
            if (lineList[row_index].filterIndexed{index, it -> index > column_index && it >= value}.isEmpty() || 
                lineList[row_index].filterIndexed{index, it -> index < column_index && it >= value}.isEmpty() ||
                lineList.filterIndexed{index, it -> !it.filterIndexed{index2, val2 -> index2 == column_index && index > row_index && val2 >= value}.isEmpty()}.isEmpty() ||
                lineList.filterIndexed{index, it -> !it.filterIndexed{index2, val2 -> index2 == column_index && index < row_index && val2 >= value}.isEmpty()}.isEmpty()) {
                    visible = visible.inc()
            }
        }
    }

    // compute scenic score
    lineList.forEachIndexed { row_index, row ->
        row.forEachIndexed { column_index, value -> 
            var scenic_score = 1
            for (x in 0..3) {
                var direction = to_direction(x)
                val score = Array(100, {it + 1}).find{
                    index -> not_in_range(row_index + direction.first * index, column_index + direction.second * index, row_count, column_count) ||
                    lineList[row_index + direction.first * index][column_index + direction.second * index] >= value
                }
                println("$value, $direction, $score")
                scenic_score *= score ?: 0
            }
            max_scenic_score = maxOf(scenic_score, max_scenic_score)
        }
    }

    println("$visible")
    println("$max_scenic_score")
}