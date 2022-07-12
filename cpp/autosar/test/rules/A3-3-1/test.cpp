#include "test.hpp"

int g1;                  // NON_COMPLIANT
extern int g2;           // NON_COMPLIANT
const int g3 = 0;        // COMPLIANT
extern const int g4 = 0; // COMPLIANT
static int g5;           // COMPLIANT

namespace n1 { // named namespace as external linkage
int l1;        // NON_COMPLIANT
void f1() {}   // NON_COMPLIANT
} // namespace n1

namespace {    // unnamed namespace has internal linkage
namespace n2 { // inherits internal linkage from unnamed namespace
int l1;        // COMPLIANT

void f1() {} // COMPLIANT
} // namespace n2
} // namespace

int f() { // NON_COMPLIANT
  return 1;
}
int f1(); // NON_COMPLIANT

static int f2() { // COMPLIANT
  return 1;
}

int main(int, char **) { // COMPLIANT
}

namespace n {
void f5() { // COMPLIANT
  int i = 0;
}
} // namespace n