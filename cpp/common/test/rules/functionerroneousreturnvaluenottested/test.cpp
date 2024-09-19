#include <stdio.h>

void test_compliant() {
  // Return value is passed to an lvalue and then tested.
  FILE *fh = fopen("/etc/foo", "r");
  if (!fh) { // COMPLIANT
    return;
  }

  // Return value is tested immediately as an rvalue.
  if (fclose(fh)) // COMPLIANT
    return;
}

void test_noncompliant() {
  remove("/bin/bash"); // NON_COMPLIANT
}