// $Id: A21-8-1.cpp 312606 2018-03-21 09:52:14Z jan.babst $
#include <algorithm>
#include <cctype>
#include <string>
void RemoveDigits_Bad(std::string &s) {
  s.erase(std::remove_if(s.begin(), s.end(),
                         [](char c) {
                           return std::isdigit(c); // non-compliant
                         }),
          s.cend());
}
void RemoveDigits_Good(std::string &s) {
  s.erase(std::remove_if(s.begin(), s.end(),
                         [](char c) {
                           return std::isdigit(
                               static_cast<unsigned char>(c)); // compliant
                         }),
          s.cend());
}