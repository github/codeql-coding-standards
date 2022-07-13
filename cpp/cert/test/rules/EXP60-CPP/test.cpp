
#include "test.h"
#include "test-diff.h"

void g() {
  S s;
  func(s); // NON_COMPLIANT - s is non-standard and passed to a library function
}

void h() {
  StdS s;
  funk(s); // COMPLIANT - StdS is standard layout and passed to a library
           // function
}
