#include <iostream>
#include <stdlib.h>

struct S {
  int i;
};

struct T final : S {};

void f1(const S *foo, std::size_t count) {
  for (const S *end = foo + count; foo != end; ++foo) {
    std::cout << foo->i << std::endl; // NON_COMPLIANT
  }
}

void f2(const S *foo, std::size_t count) {
  for (const S *end = foo + count; foo != end; ++foo) {
    std::cout << foo->i << std::endl; // COMPLIANT
  }
}

void f3(const S *foo, std::size_t count) {
  for (std::size_t i = 0; i < count; ++i) {
    std::cout << foo[i].i << std::endl; // NON_COMPLIANT
  }
}

void f4(const S *foo, std::size_t count) {
  for (std::size_t i = 0; i < count; ++i) {
    std::cout << foo[i].i << std::endl; // COMPLIANT
  }
}

int main() {
  S *l1 = new S();
  S l2;
  S *l3 = &l2;
  f1(l1, 10);
  f3(l1, 10);
  f1(l3, 10);
  f3(l3, 10);

  T *l4 = new T();
  T l5;
  T *l6 = &l5;
  f2(l4, 10);
  f4(l4, 10);
  f2(l6, 10);
  f4(l6, 10);
}
