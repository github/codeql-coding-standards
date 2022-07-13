#include "test-diff.h"
// semmle-extractor-options:--g++ -std=gnu++14

int f(int x) {
  if (x > 42)
    throw 42; // NON_COMPLIANT - exception is thrown across execution boundary

  return 0;
}