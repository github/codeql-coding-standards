#include <cstdio>
#include <iostream>
#include <string>

void f1() {
  char a1[7] = "CodeQL";
  char a2[10];
  char a4[2];
  char a9[10];
  char a10[100];

  std::strncpy(a2, a1, 10);
  std::strncpy(a2, a1, 5);
  std::strncpy(a4, a1, 10);
  std::strncpy(a9, a1, 10);

  std::cin >> a10;

  std::string a5(a1); // COMPLIANT - a1 was null terminated
  std::string a6(
      "CodeQL"); // COMPLIANT - string literal will be null termianted
  std::string a8(
      a2); // NON_COMPLIANT - last call to strncpy didn't null terminate
  std::string a11(
      a9); // COMPLIANT - last call to strncpy null terminated the string.
  std::string a12(a10); // NON_COMPLIANT - a10 was possibly not null terminated
}

void f3(std::istream &in) {
  char b[100];

  in.read(b, sizeof(b));

  try {
    in.read(b, sizeof(b));
  } catch (...) {
  }
}

void f4() {
  char a1[10];
  char a2[10];

  std::snprintf(a1, 10, "CodeQL %d", 3);
  std::snprintf(a2, 11, "CodeQL %d", 3);

  std::string a4(a2); // NON_COMPLIANT - a2 may not have been terminated.
  std::string a5(a1); // COMPLIANT
}

void f5() {
  char a1[2];

  std::strncat(a1, "CodeQL", 5);

  std::string a4(a1); // NON_COMPLIANT - a1 may not have been null terminated
}

class A {
private:
  std::string _string;
  A(const std::string &string) : _string(string) {} // COMPLIANT

  std::string string() const { return _string; } // COMPLIANT
};