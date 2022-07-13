using intptr = int *;
using intconstptr = int *const;
using constintptr = const int *;

typedef int inttypedef;

void f() {
  int l = 0;
  const intptr ptr1 = &l;    // NON_COMPLIANT
  volatile intptr ptr2 = &l; // NON_COMPLIANT

  intptr const ptr3 = &l;    // COMPLIANT
  intptr volatile ptr4 = &l; // COMPLIANT

  intconstptr ptr5 = &l; // COMPLIANT

  constintptr ptr6 = &l;       // COMPLIANT
  constintptr const ptr7 = &l; // COMPLIANT
  const constintptr ptr8 = &l; // NON_COMPLIANT
  inttypedef ptr9 = l;         // COMPLIANT
}