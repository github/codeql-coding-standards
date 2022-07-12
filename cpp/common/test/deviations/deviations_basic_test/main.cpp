// NOTE: qltest doesn't extract .cpp files in nested directories. We work around
// this by including header files in nested directories
#include "nested/nested1/test1.h"
#include "nested/nested2/test2.h"
#include "nested/nested3/test3.h"
#include "nested/test.h"

int getX() { return 5; }

int main(int argc, char **argv) {
  int x = 0;      // COMPLIANT[DEVIATED]
  getX();         // NON_COMPLIANT
  long double d1; // NON_COMPLIANT (A0-4-2)
  long double d2; // a-0-4-2-deviation COMPLIANT[DEVIATED]
  return 0;
}