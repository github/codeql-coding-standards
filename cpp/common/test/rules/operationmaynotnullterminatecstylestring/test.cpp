#pragma clang diagnostic ignored "-Wfortify-source"
#include <cstdio>
#include <iostream>
#include <string>

void f1() {
  char a1[7] = "CodeQL";
  char a2[10];
  char a3[6];
  char a4[2];
  char a9[10];
  char a10[100];

  std::strncpy(a2, a1,
               10); // COMPLIANT - Will null terminate since N > sizeof(a1)
  std::strncpy(a2, a1, 5);  // NON_COMPLIANT - Will not null terminate
  std::strncpy(a4, a1, 10); // NON_COMPLIANT - Will overflow
  std::strncpy(a9, a1,
               10); // COMPLIANT - Will null terminate since N > sizeof(a1)

  std::cin >> a10; // NON_COMPLIANT
}

void f3(std::istream &in) {
  char b[100];

  in.read(b, sizeof(b)); // NON_COMPLIANT

  try {
    in.read(b, sizeof(b)); // COMPLIANT
  } catch (...) {
  }
}

void f4() {
  char a1[10];
  char a2[10];

  std::snprintf(a1, 10, "CodeQL %d", 3); // COMPLIANT - Will null terminate
  std::snprintf(a2, 11, "CodeQL %d", 3); // NON_COMPLIANT
}

void f5() {
  char a1[2];

  std::strncat(a1, "CodeQL", 5); // NON_COMPLIANT
}

class A {
private:
  std::string _string;
  A(const std::string &string) : _string(string) {} // COMPLIANT

  std::string string() const { return _string; } // COMPLIANT
};
