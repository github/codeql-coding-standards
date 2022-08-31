
class A {};

A operator+(A const &a1, A const &a2) noexcept { // COMPLIANT
  return A();
}

int operator/(A const &a1, A const &a2) noexcept { // COMPLIANT
  return 0;
}

A operator&(A const &a1, A const &a2) noexcept { // COMPLIANT
  return A();
}

const A operator-(A const &a1, int n2) noexcept { // NON_COMPLIANT
  return A();
}

A *operator|(A const &a1, A const &a2) noexcept { // NON_COMPLIANT
  return new A();
}

const A operator<<(A const &, A const &) noexcept // NON_COMPLIANT
{
  return A{};
}

class C {
  C &operator=(const C &rhs);
};

namespace NS_C {
int &operator+(const C &lhs, const C &rhs) { // NON_COMPLIANT
  static int slocal = 0;
  return slocal;
}
} // namespace NS_C

#include <iostream>
struct Test {};
std::ostream &operator<<(std::ostream &os, const Test &) { // COMPLIANT
  os << "test";
  return os;
}
