#include "stdlib.h"

void f() {
  // rand() is banned -- and thus, so is srand().
  srand(0);       // NON-COMPLIANT
  int x = rand(); // NON-COMPLIANT

  // Other functions from stdlib are not banned by this rule.
  x = abs(-4);       // COMPLIANT
  getenv("ENV_VAR"); // COMPLIANT
}