#include <stdlib.h>

class ClassA {};

void test_global_new() {
  ClassA *a1 = new ClassA{};
  delete a1; // COMPLIANT

  ClassA *a2 = new ClassA{};
  delete[] a2; // NON_COMPLIANT

  ClassA *a3 = new ClassA{};
  free(a3); // NON_COMPLIANT
}

void test_global_new_array() {
  ClassA *a1 = new ClassA[10]{};
  delete a1; // NON_COMPLIANT

  ClassA *a2 = new ClassA[10]{};
  delete[] a2; // COMPLIANT

  ClassA *a3 = new ClassA[10]{};
  free(a3); // NON_COMPLIANT
}

void test_malloc() {
  int *i1 = (int *)malloc(sizeof(int));
  delete i1; // NON_COMPLIANT

  int *i2 = (int *)malloc(sizeof(int));
  delete[] i2; // NON_COMPLIANT

  int *i3 = (int *)malloc(sizeof(int));
  free(i3); // COMPLIANT
}