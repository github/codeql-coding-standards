#include <string>
void f(int &i) { // COMPLIANT
  int &j = i;
}
void f1(std::string &str) { // NON_COMPLIANT
  str = "replacement";
}
void f2(std::string &str) { // NON_COMPLIANT
  str += "suffix";
}

void f3(int &i) { // COMPLIANT
  f(i);
}

void f4(int &i) { // NON_COMPLIANT
  int x = 10;
  i = x;
}

void f5(int &i) { // NON_COMPLIANT
  f4(i);
}

class A {
public:
  int m;
};
void f6(A &a) { // NON_COMPLIANT
  a.m = 0;
  int l = a.m;
}
void f7(A &a) { // NON_COMPLIANT
  a = A();
}

void f8(int i) { // COMPLIANT
  i += 1;
}

constexpr A &operator|=(
    A &lhs,
    const A &rhs) noexcept { // COMPLIANT - non-member user defined assignment
                             // operators are considered an exception.
  return lhs;
}

enum class byte : unsigned char {};
constexpr byte &
operator|(const byte &lhs,
          const byte &rhs) noexcept { // COMPLIANT - parameters are const
                                      // qualified references
  return lhs | rhs;
}
constexpr byte &operator|=(
    byte &lhs,
    const byte rhs) noexcept { // COMPLIANT - non-member user defined assignment
                               // operators are considered an exception.
  lhs = (lhs | rhs);
  return lhs;
}

#include <iostream>
std::ostream &operator<<(std::ostream &os,
                         const byte &obj) { // COMPLIANT - insertion operators
                                            // are considered an exception.
  std::ostream other;
  os = other; // simulate modification
  return os;
}

std::istream &operator>>(std::istream &is,
                         byte &obj) { // COMPLIANT - extraction operators are
                                      // considered an exception.
  obj = static_cast<byte>('a');       // simulate modification
  return is;
}