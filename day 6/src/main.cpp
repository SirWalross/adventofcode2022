#include <fmt/core.h>

#include <fstream>
#include <iostream>
#include <range/v3/all.hpp>
#include <range/v3/iterator/operations.hpp>
#include <range/v3/view/chunk_by.hpp>
#include <range/v3/view/for_each.hpp>
#include <range/v3/view/group_by.hpp>
#include <range/v3/view/sliding.hpp>
#include <range/v3/view/unique.hpp>
#include <string>
#include <vector>

int main() {
    std::ifstream infile("../input");
    std::string line;
    std::getline(infile, line);

    constexpr int start_of_message_marker = 14;

    int i = start_of_message_marker - 1;

    for (auto val : line | ranges::views::sliding(start_of_message_marker)) {
        i++;
        auto str = val | ranges::to<std::string>();
        auto unique_count =
            static_cast<std::size_t>(ranges::distance(ranges::views::unique(ranges::actions::sort(str))));
        if (val.size() == unique_count) {
            break;
        }
    }
    std::cout << i << '\n';
}