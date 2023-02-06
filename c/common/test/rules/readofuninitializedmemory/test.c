#include <stdlib.h>

struct A {
  int m1;
};

void use_int(int a);
void use_struct_A(struct A a);
void use_int_ptr(int *a);
void use_struct_A_ptr(struct A *a);

void init_by_pointer(int *pointer_param);

void test_basic_init() {
  int l1 = 0;
  use_int(l1); // COMPLIANT
  struct A l2 = {};
  use_struct_A(l2); // COMPLIANT
  int l3;
  init_by_pointer(&l3);
  use_int(l3); // COMPLIANT
  struct A l4;
  l4.m1 = 1;        // COMPLIANT
  use_struct_A(l4); // COMPLIANT
  int l5[10] = {1, 0};
  use_int_ptr(l5); // COMPLIANT
  struct A l6;
  use_struct_A(l6); // COMPLIANT[FALSE_NEGATIVE]
}

void test_basic_uninit() {
  int l1;
  use_int(l1); // NON_COMPLIANT
  int *l2;
  use_int_ptr(l2); // NON_COMPLIANT
  struct A *l3;
  use_struct_A_ptr(l3); // NON_COMPLIANT
  struct A l4;
  use_int(l4.m1); // NON_COMPLIANT[FALSE_NEGATIVE] - field is not initialized
  int l5[10];
  use_int(
      l5[0]); // NON_COMPLIANT[FALSE_NEGATIVE] - array entry is not initialized
}

int run1();

void test_conditional(int x) {

  int l1; // l1 is defined and used only when x is true
  if (x) {
    l1 = 0;
  }
  if (x) {
    use_int(l1); // COMPLIANT
  }

  int l2; // l2 is defined and used only when x is false
  if (!x) {
    l2 = 0;
  }
  if (!x) {
    use_int(l2); // COMPLIANT
  }

  int l3 = 0;
  int l4;
  if (x) {
    l3 = 1;
    l4 = 1;
  }

  if (l3) {      // l3 true indicates l4 is initialized
    use_int(l4); // COMPLIANT
  }

  int numElements = 0;
  int *arrayPtr;
  if (x) {
    numElements = 5;
    arrayPtr = malloc(sizeof(int) * numElements);
  }

  if (numElements > 0) {   // numElements > 0 indicates arrayPtr is initialized
    use_int_ptr(arrayPtr); // COMPLIANT[FALSE_POSITIVE]
  }
}

void test_non_default_init() {
  static int sl;
  use_int(sl); // COMPLIANT - static int type variables are zero initialized
  static int *slp;
  use_int_ptr(
      slp); // COMPLIANT - static pointer type variables are zero initialized
  static struct A ss;
  use_struct_A(
      ss); // COMPLIANT - static struct type variables are zero initialized
}