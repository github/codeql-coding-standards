#include "test-diff.h"

int g(int x) {
  if (x > 42)
    throw -1; // COMPLIANT - exception is thrown and caught in the library
  return 0;
}

int client_f() {
  try {
    f(5);
  } catch (int e) {
    return -1;
  }
  return 0;
}

int client_g() {
  try {
    g(5);
  } catch (int e) {
    return -1;
  }
  return 0;
}
