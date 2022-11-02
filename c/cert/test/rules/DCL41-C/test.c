#include <stdio.h>

void f(int expr) {
  switch (expr) {
    int i = 4; // NON_COMPLIANT
  case 0:
    i = 17;
  default:
    printf("%d\n", i);
  }
}

void f1(int expr) {
  int i = 4; // COMPLIANT
  switch (expr) {
  case 0:
    i = 17;
  default:
    printf("%d\n", i);
  }
}

void f2(int expr) {
  switch (expr) {
  case 0:
    int i = 4; // COMPLIANT
  case 1:
    i = 6; // COMPLIANT
  default:
    printf("%d\n", i);
  }
}