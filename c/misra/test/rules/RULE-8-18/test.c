// semmle-extractor-options:--clang -std=c11 -nostdinc
#include "conditional.h"
#include "sample.h"

// Source definitions are allowed, including completion of header declarations.
int initialized_elsewhere = 0;       // COMPLIANT
int source_tentative;                // COMPLIANT
DECLARE_OBJECT(macro_source_object); // COMPLIANT

// Static locals are not file-scope tentative definitions.
void local_objects(void) {
  static int static_local; // COMPLIANT
}