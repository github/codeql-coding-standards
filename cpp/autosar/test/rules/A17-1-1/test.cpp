#include <algorithm>
#include <cstring>
#include <exception>
#include <iostream>
#include <stdio.h>
#include <string>
#include <vector>

#define USER_DEFINED_STRLEN_MACRO(x) strlen(x)

namespace ns1 {
size_t strlen(const char *str) {
  std::strlen(str);     // NON_COMPLIANT
  return ::strlen(str); // NON_COMPLIANT
}

void call_within_namespace_no_qualifier(const char *source) {
  strlen(source);      // COMPLIANT
  ns1::strlen(source); // COMPLIANT
}
}; // namespace ns1

struct s1 {
  static size_t strlen(const char *str) {
    std::strlen(str);     // NON_COMPLIANT
    return ::strlen(str); // NON_COMPLIANT
  }

  char *strcpy(char *destination, const char *source) {
    return std::strcpy(destination, source); // NON_COMPLIANT
  }
};

void set_unexpected(void *) { return; }

void f2(std::vector<int> &c) {
  std::remove(c.begin(), c.begin(), 1); // COMPLIANT
  remove("path");                       // NON_COMPLIANT
}

void f1() {
  s1 v1;
  v1.strcpy(0, 0);              // COMPLIANT
  ns1::strlen(0);               // COMPLIANT
  s1::strlen(0);                // COMPLIANT
  strlen(0);                    // NON_COMPLIANT
  std::strlen(0);               // NON_COMPLIANT
  USER_DEFINED_STRLEN_MACRO(0); // NON_COMPLIANT
  std::set_unexpected(0);       // COMPLIANT
}