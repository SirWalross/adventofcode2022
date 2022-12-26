#include <errno.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Monkey Monkey;

struct Monkey {
    int64_t value;
    int operation;
    Monkey* monkey1;
    Monkey* monkey2;
};

int get_value(Monkey* monkey, int recalc) {
    if (recalc && monkey->value != 0 && monkey->operation != 0) {
        monkey->value = 0;
    }
    if (monkey->value == 0) {
        int64_t value = 0;
        if (get_value(monkey->monkey1, recalc) != 0 || get_value(monkey->monkey2, recalc) != 0) {
            return 1;
        }
        if (monkey->operation == 1) {
            // addition
            value = monkey->monkey1->value + monkey->monkey2->value;
        } else if (monkey->operation == 2) {
            // subtraction
            value = monkey->monkey1->value - monkey->monkey2->value;
        } else if (monkey->operation == 3) {
            // multiplication
            value = monkey->monkey1->value * monkey->monkey2->value;
        } else if (monkey->operation == 4) {
            // division
            if (monkey->monkey1->value % monkey->monkey2->value != 0) {
                // invalid division
                return 1;
            }
            value = monkey->monkey1->value / monkey->monkey2->value;
        } else {
            printf("Error\n");
        }
        monkey->value = value;
    }
    return 0;
}

uint32_t get_monkey_name(char* line) {
    return (((uint32_t)line[0]) << 24) + (((uint32_t)line[1]) << 16) + (((uint32_t)line[2]) << 8) + ((uint32_t)line[3]);
}

int get_monkey_from_name(uint32_t* monkey_names, uint32_t monkey, int length) {
    for (int i = 0; i < length; i++) {
        if (monkey_names[i] == monkey) {
            return i;
        }
    }
    printf("Error!\n");
    return 0;
}

int main(void) {
    FILE* fp;
    char* line = NULL;
    size_t len = 0;
    ssize_t read;
    size_t size = 2;
    uint32_t* monkey_names = malloc(size * sizeof(uint32_t));

    fp = fopen("input", "r");
    if (fp == NULL)
        return 1;

    int zero_mix_index = 0;
    size_t length = 0;
    while ((read = getline(&line, &len, fp)) != -1) {
        monkey_names[length] = get_monkey_name(line);

        length++;

        if (length > size) {
            size *= size;
            monkey_names = realloc(monkey_names, size * sizeof(uint32_t));
            if (monkey_names == NULL) {
                return 1;
            }
        }
    }

    fclose(fp);
    if (line)
        free(line);

    fp = fopen("input", "r");
    if (fp == NULL)
        return 1;

    int index = 0;
    Monkey* monkeys = calloc(size, sizeof(Monkey));
    while ((read = getline(&line, &len, fp)) != -1) {
        if (line[6] >= '0' && line[6] <= '9') {
            // monkey has value
            char* temp;
            line[read - 1] = '\0';
            int value = (int)strtol(line + 6, &temp, 10);

            if (temp == line || *temp != '\0' || errno == ERANGE) {
                printf("Error %d\n", errno);
                return 1;
            }
            monkeys[index].value = value;
        } else {
            monkeys[index].operation = line[11] == '+' ? 1 : (line[11] == '-' ? 2 : (line[11] == '*' ? 3 : 4));
            monkeys[index].monkey1 = monkeys + get_monkey_from_name(monkey_names, get_monkey_name(line + 6), length);
            monkeys[index].monkey2 = monkeys + get_monkey_from_name(monkey_names, get_monkey_name(line + 13), length);
        }

        index++;
    }

    fclose(fp);
    if (line)
        free(line);

    Monkey* root = monkeys + get_monkey_from_name(monkey_names, 1919905652, length);
    Monkey* human = monkeys + get_monkey_from_name(monkey_names, 1752526190, length);

    int64_t start_value = 0;
    int64_t start_value_index = 0;
    for (int64_t i = 1; i < 10000; i++) {
        human->value = i;
        if (get_value(root, 1) == 0) {
            start_value = root->monkey1->value;
            start_value_index = i;
            break;
        }
    }
    if (start_value == 0) {
        printf("Didnt find start value\n");
        return 1;
    }

    int64_t offset = 0;
    int64_t offset_index = 0;
    for (int64_t i = 5865692 + start_value_index; i < 1000000 + 5865692 + start_value_index; i++) {
        human->value = i;
        if (get_value(root, 1) == 0) {
            offset = root->monkey1->value;
            offset_index = i;
            break;
        }
    }
    if (offset == 0) {
        printf("Didnt find offset value\n");
        return 1;
    }
    int64_t goal = root->monkey2->value;

    int64_t human_value = start_value_index + ((__int128_t) (offset_index - start_value_index)) * ((__int128_t) (goal - start_value)) / ((offset - start_value));

    human->value = human_value;

    printf("Human value: %ld\n", human_value);
    free(monkeys);
    free(monkey_names);
}