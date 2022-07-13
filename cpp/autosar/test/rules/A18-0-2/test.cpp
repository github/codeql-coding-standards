#include "stdlib.h"
#include <cstdlib>
#include <string>

void test_non_compliant(const char *s) {
  atoi(s);       // NON_COMPLIANT
  atol(s);       // NON_COMPLIANT
  atoll(s);      // NON_COMPLIANT
  atof(s);       // NON_COMPLIANT
  std::atoi(s);  // NON_COMPLIANT
  std::atol(s);  // NON_COMPLIANT
  std::atoll(s); // NON_COMPLIANT
  std::atof(s);  // NON_COMPLIANT
}

void test_compliant(const char *s) {
  std::stoi(s);   // COMPLIANT
  std::stol(s);   // COMPLIANT
  std::stoul(s);  // COMPLIANT
  std::stoll(s);  // COMPLIANT
  std::stoull(s); // COMPLIANT
  std::stof(s);   // COMPLIANT
  std::stod(s);   // COMPLIANT
  std::stold(s);  // COMPLIANT
}