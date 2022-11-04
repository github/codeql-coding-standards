#include <iostream>

void test_switchclause_termination(int expression) {
  int i = 3;
  int j = 5;
  int k;
  switch (expression) {
  case 1: // COMPLIANT
  case 2: // NON_COMPLIANT
    if (i > 0) {
      k = i + j;
    }
  case 3: // COMPLIANT
    std::cout << "Hello World";
    throw;
  case 4: // NON_COMPLIANT
    if (i < 4) {
      k = i;
    }
  default:
    break;
  }
}

void test_switchclause_termination2(int expression) {
  int i = 3;
  int j = 5;
  int k;
  switch (expression) {
  case 1: // COMPLIANT
  case 2: // NON_COMPLIANT
    if (i > 0) {
      k = i + j;
    }
  case 3: // COMPLIANT
    std::cout << "Hello World";
    throw;
  case 4: // NON_COMPLIANT
    if (i < 4) {
      k = i;
    }
  default: // NON_COMPLIANT
      ;
  }
}
