#include "BashConverter.hpp"

void BashConverter::convert(std::string &command, std::string &description,
                            std::vector<std::string> &short_option,
                            std::vector<std::string> &long_option,
                            std::vector<std::string> &old_option) {
    int num_options =
        short_option.size() + long_option.size() + old_option.size();
    if (num_options == 0) {
        description = "";
        short_option.clear();
        long_option.clear();
        old_option.clear();

        return;
    }

    for (auto &it : short_option) {
        file << "-" << it << std::endl;
    }
    for (auto &it : long_option) {
        file << "--" << it << std::endl;
    }
    for (auto &it : old_option) {
        file << "-" << it << std::endl;
    }
};
