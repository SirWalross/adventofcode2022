#include <cstddef>
#include <cstdint>
#include <iostream>
#include <memory>
#include <range/v3/algorithm/min.hpp>
#include <range/v3/numeric/accumulate.hpp>
#include <range/v3/view/remove_if.hpp>
#include <range/v3/view/transform.hpp>
#include <string>
#include <vector>

class File {
    std::string name;
    uint64_t size;

   public:
    File(std::string name, uint64_t size) : name{name}, size{size} {}

    uint64_t get_size() {
        return size;
    }
};

class Directory {
   public:
    std::string name;
    std::vector<std::shared_ptr<Directory>> child_dirs;
    std::vector<std::shared_ptr<File>> child_files;
    Directory* parent;

    Directory(std::string name) : name{name}, parent{nullptr} {}

    void add_dir(std::string name) {
        child_dirs.emplace_back(std::make_shared<Directory>(name));
        child_dirs.back()->parent = this;
    }

    void add_file(std::string name, uint64_t size) {
        child_files.emplace_back(std::make_shared<File>(name, size));
    }

    uint64_t get_size() {
        return ranges::accumulate(child_dirs | ranges::views::transform([](auto dir) { return dir->get_size(); }), 0) +
               ranges::accumulate(child_files | ranges::views::transform([](auto file) { return file->get_size(); }),
                                  0);
    }

    uint64_t get_max_size() {
        if (this->get_size() > 100000) {
            return ranges::accumulate(
                child_dirs | ranges::views::transform([](auto dir) { return dir->get_max_size(); }), 0);
        } else {
            return ranges::accumulate(
                       child_dirs | ranges::views::transform([](auto dir) { return dir->get_max_size(); }), 0) +
                   this->get_size();
        }
    }

    Directory* get_child(std::string name) {
        return (child_dirs | ranges::views::remove_if([name](auto dir) { return name != dir->name; })).front().get();
    }

    uint64_t smallest_dir_of_size(uint64_t size) {
        if (get_size() > size) {
            return std::min(ranges::min(child_dirs | ranges::views::transform(
                                                         [size](auto dir) { return dir->smallest_dir_of_size(size); })),
                            get_size());
        } else {
            return UINT64_MAX;
        }
    }
};