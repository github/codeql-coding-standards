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

  long double d3; // [[codingstandards::deviation(a-0-4-2-deviation)]]
                  // COMPLIANT[DEVIATED]
  long double d4; // NON_COMPLIANT (A0-4-2)
  // [[codingstandards::deviation_next_line(a-0-4-2-deviation)]]
  long double d5; // COMPLIANT[DEVIATED]
  long double d6; // NON_COMPLIANT (A0-4-2)

  // [[codingstandards::deviation_begin(a-0-4-2-deviation)]]
  long double d7; // COMPLIANT[DEVIATED]
  getX();         // NON_COMPLIANT (A0-1-2)
  long double d8; // COMPLIANT[DEVIATED]
  getX();         // NON_COMPLIANT (A0-1-2)
  long double d9; // COMPLIANT[DEVIATED]
  // [[codingstandards::deviation_end(a-0-4-2-deviation)]]
  long double d10; // NON_COMPLIANT (A0-4-2)
  // [[codingstandards::deviation_begin(a-0-4-2-deviation)]]
  long double d11; // COMPLIANT[DEVIATED]
  getX();          // NON_COMPLIANT (A0-1-2)
  long double d12; // COMPLIANT[DEVIATED]
  getX();          // NON_COMPLIANT (A0-1-2)
  long double d13; // COMPLIANT[DEVIATED]
  // [[codingstandards::deviation_end(a-0-4-2-deviation)]]
  long double d14; // NON_COMPLIANT (A0-4-2)
  getX();          // NON_COMPLIANT (A0-1-2)
  return 0;
}