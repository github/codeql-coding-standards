#include <iostream>
#include <stdlib.h>

class C1 {
public:
  virtual ~C1() {}
  int i;
};

class C2 {
public:
  int i;
};

void f1(const C1 *foo, std::size_t count) {
  for (const C1 *end = foo + count; foo != end; ++foo) {
    std::cout << foo->i << std::endl; // NON_COMPLIANT
  }
}

void f2(const C2 *foo, std::size_t count) {
  for (const C2 *end = foo + count; foo != end; ++foo) {
    std::cout << foo->i << std::endl; // COMPLIANT
  }
}

void f3(const C1 *foo, std::size_t count) {
  for (std::size_t i = 0; i < count; ++i) {
    std::cout << foo[i].i << std::endl; // NON_COMPLIANT
  }
}

void f4(const C2 *foo, std::size_t count) {
  for (std::size_t i = 0; i < count; ++i) {
    std::cout << foo[i].i << std::endl; // COMPLIANT
  }
}

int main() {
  C1 *l1 = new C1();
  C1 l2;
  C1 *l3 = &l2;
  f1(l1, 10);
  f3(l1, 10);
  f1(l3, 10);
  f3(l3, 10);

  C2 *l4 = new C2();
  C2 l5;
  C2 *l6 = &l5;
  f2(l4, 10);
  f4(l4, 10);
  f2(l6, 10);
  f4(l6, 10);
}
