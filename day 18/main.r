f <- file("input", open = "r")
lines <- readLines(f)
close(f)
grid <- array(0, dim = c(23, 23, 23))
# grid <- array(0, dim = c(5, 5, 8))
cubes <- array(0, dim = c(length(lines), 3))

for (i in 1:length(lines)) {
    index <- strtoi(unlist(strsplit(lines[i], ",")))
    cubes[i, ] <- index + 1
    grid[index[1] + 1, index[2] + 1, index[3] + 1] <- 1
}

offset <- c(
    c(1, 0, 0), c(-1, 0, 0), c(0, 1, 0),
    c(0, -1, 0), c(0, 0, 1), c(0, 0, -1)
)
offset <- matrix(offset, nrow = 3, byrow = FALSE)

# flood fill all exterior cubes with 2
flood_fill <- function(start) {
    values <- array(0, dim = c(1000000, 3))
    values[1, ] <- start
    index <- 1
    count <- 1
    while (count > 0) {
        start <- values[index, ]
        if (grid[start[1], start[2], start[3]] != 2) {
            grid[start[1], start[2], start[3]] <<- 2
            for (i in 1:dim(offset)[2]) {
                start <- start + offset[, i]
                if (all(dim(grid) >= start) && all(start > 0) && grid[start[1], start[2], start[3]] == 0) {
                    values[index + count, ] <- start
                    count <- count + 1
                }
                start <- start - offset[, i]
            }
        }
        count <- count - 1
        index <- index + 1
    }
}

flood_fill(c(1, 1, 1))

open_faces <- 0
for (i in 1:dim(cubes)[1]) {
    open_faces <- open_faces + (6 - sum(grid[t(cubes[i, ] - offset)] != 2))
}

print(open_faces)
