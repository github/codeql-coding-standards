#include <new>
#include <stddef.h>

class ClassA {
public:
  ClassA() : m1(1) {}
  ClassA(int p_m1) : m1(p_m1) {}

private:
  int m1;
};

class ClassB {};

void test_local_address_of() {
  ClassA a;
  ClassA *a1 = new (&a) ClassA(1); // COMPLIANT
  ClassB b;
  ClassA *a2 = new (&b) ClassA(1); // NON_COMPLIANT
}

void test_local_array() {
  char goodAlloc alignas(ClassA)[sizeof(ClassA)];
  ClassA *a1 = new (goodAlloc) ClassA(1); // COMPLIANT
  char a;
  char badAlloc[sizeof(ClassA)];
  ClassA *a2 = new (badAlloc) ClassA(1); // NON_COMPLIANT - not guaranteed to
                                         //                 be aligned properly
}