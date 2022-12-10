#include <cstddef>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#include "tree.hpp"

int main() {
    std::ifstream infile("../input");
    std::string line;

    Directory parent("/");

    Directory* curr_directory = &parent;

    std::getline(infile, line);  // skip first line

    while (std::getline(infile, line)) {
        if (line.starts_with("$ cd")) {
            // move directory
            auto prev_name = curr_directory->name;
            if (line.starts_with("$ cd ..")) {
                curr_directory = curr_directory->parent;
            } else {
                curr_directory = curr_directory->get_child(line.replace(0, 5, ""));
            }
        } else if (line.starts_with("dir")) {
            // create new directory
            line = line.replace(0, 4, "");
            curr_directory->add_dir(line);
        } else if (!line.starts_with("$ ls")) {
            // create new file
            std::istringstream istringstream(line);
            std::size_t size = 0;
            istringstream >> size;
            std::string name;
            istringstream >> name;
            curr_directory->add_file(name, size);
        }
    }

    auto space_to_be_deleted = parent.get_size() - 40000000;

    std::cout << parent.get_max_size() << "\n";
    std::cout << parent.smallest_dir_of_size(space_to_be_deleted) << "\n";
}