#include <errno.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int wrap_around_modulu(int64_t a, int64_t b) {
    return (b + (a % b)) % b;
}

uint32_t get_position_on_board(uint32_t* index_map, uint32_t mix_index, int64_t length) {
    for (uint32_t i = 0; i < length; i++) {
        if (index_map[i] == mix_index) {
            return i;
        }
    }
    printf("Error!!\n");
    return 0;
}

void move_number(int64_t* array, uint32_t* index_map, int64_t length, int mix_index) {
    int64_t index = get_position_on_board(index_map, mix_index, length);
    int64_t offset = array[index] % length;
    if (abs(array[index]) > length) {
        offset = array[index] % (length - 1);
    }
    if (offset == 0)
        return;
    int64_t prev = array[index];
    if (prev > 0) {
        // move all to the right
        for (int64_t i = index; i < index + offset; i++) {
            int old_index = wrap_around_modulu(i + 1, length);
            int new_index = wrap_around_modulu(i, length);
            array[new_index] = array[old_index];
            index_map[new_index] = index_map[old_index];
        }
    } else if (prev < 0) {
        // move all to the left
        for (int64_t i = index; i > index + offset; i--) {
            int old_index = wrap_around_modulu(i - 1, length);
            int new_index = wrap_around_modulu(i, length);
            array[new_index] = array[old_index];
            index_map[new_index] = index_map[old_index];
        }
    }
    array[wrap_around_modulu(index + offset, length)] = prev;
    index_map[wrap_around_modulu(index + offset, length)] = mix_index;
}

int main(void) {
    FILE* fp;
    char* line = NULL;
    size_t len = 0;
    ssize_t read;
    size_t size = 2;
    int64_t* array = malloc(size * sizeof(int64_t));
    uint32_t* index_map = calloc(2, sizeof(int64_t));  // map from position to mix_index on board

    fp = fopen("input", "r");
    if (fp == NULL)
        return 1;

    int zero_mix_index = 0;
    size_t length = 0;
    while ((read = getline(&line, &len, fp)) != -1) {
        char* temp;
        line[read - 1] = '\0';
        int64_t val = (int)strtol(line, &temp, 10);

        if (temp == line || *temp != '\0' || errno == ERANGE) {
            printf("Error %d\n", errno);
            return 1;
        }
        if (val == 0) {
            zero_mix_index = length;
        }

        array[length] = val * 811589153;
        index_map[length] = length;

        length++;

        if (length > size) {
            size *= size;
            array = realloc(array, size * sizeof(int64_t));
            index_map = realloc(index_map, size * sizeof(int64_t));
            if (array == NULL || index_map == NULL) {
                return 1;
            }
        }
    }

    fclose(fp);
    if (line)
        free(line);
    int* num_array = malloc(size * sizeof(int));
    memcpy(num_array, array, size * sizeof(int));

    for (int j = 0; j < 10; j++) {
        for (int i = 0; i < length; i++) {
            move_number(array, index_map, length, i);
        }
    }

    uint32_t zero_index = get_position_on_board(index_map, zero_mix_index, length);
    printf("%ld\n", array[wrap_around_modulu(1000 + zero_index, length)] +
                       array[wrap_around_modulu(2000 + zero_index, length)] +
                       array[wrap_around_modulu(3000 + zero_index, length)]);
    free(array);
    free(index_map);
}