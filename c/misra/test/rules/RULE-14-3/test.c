#include <stdbool.h>

void f1(int p1) {
  if (2 > 3) { // NON_COMPLIANT
  }

  if (p1 > 0) { // COMPLIANT
  }

  if (p1 < 10 && p1 > 20) { // NON_COMPLIANT[FALSE_NEGATIVE]
  }
}

void f2() {
  while (20 > 10) { // NON_COMPLIANT
    if (1 > 2) {
    } // NON_COMPLIANT
  }

  for (int i = 10; i < 5; i++) { // NON_COMPLIANT
  }
}

void f3() {
  while (true) { // Permitted by exception
  }
  while (1 < 2) { // NON_COMPLIANT - likely an indication of a bug
  }
}