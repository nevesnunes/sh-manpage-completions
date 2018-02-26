#pragma once

#include <string>
#include <vector>

#include "Converter.hpp"

class BashConverter : public Converter {
  private:
    std::ofstream file;
  public:
    BashConverter() {
        file.open("bash-converter.out", std::ios::trunc);
        file.close();
        file.open("bash-converter.out", std::ios::out | std::ios::app);
    };
    ~BashConverter() {
        file.close();
    };
    void convert(std::string &command, std::string &description,
                         std::vector<std::string> &short_option,
                         std::vector<std::string> &long_option,
                         std::vector<std::string> &old_option);
};
