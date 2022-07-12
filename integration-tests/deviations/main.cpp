#include "nested/nested2/test2.h"
#include "nested/test.h"

int getX() { return 5; }

int main(int argc, char **argv) {
  int x = 0;      // COMPLIANT[DEVIATED]
  getX();         // NON_COMPLIANT
  long double d1; // NON_COMPLIANT (for A0-4-2)
  long double d2; // a0-4-2-deviation COMPLIANT[DEVIATED]
  return 0;
}