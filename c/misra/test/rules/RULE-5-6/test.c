#include "test.h"
void f() {
  {
    typedef unsigned char test; // NON_COMPLIANT
  }
  {
    typedef unsigned char test; // NON_COMPLIANT
  }
}

typedef float test1; // NON_COMPLIANT

void f2() { int test1 = 0; }

typedef struct list {
  int i;
} list; // COMPLIANT

typedef struct BIGList1 {
  int i;
} list1; // COMPLIANT

typedef enum enum1 { testenum } enum1; // COMPLIANT

typedef struct {
  struct chain {
    int ii;
  } s1;
  int i;
} chain; // NON_COMPLIANT