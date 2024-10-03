// Compiled with -std=c17

#include "stdatomic.h"
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"

void f1(void) {
  // malloc() is not obsolete, but banned by Rule 21.3
  int *t = malloc(10); // COMPLIANT[False Negative]

  // Obsolete usage of realloc.
  realloc(t, 0); // NON-COMPLIANT

  // Valid usage of realloc, but all use of realloc is banned by Rule 21.3
  realloc(t, 20); // NON-COMPLIANT
}

extern const int g1; // COMPLIANT
const extern int g2; // NON-COMPLIANT

#define MY_TRUE 3  // COMPLIANT
#define true 3     // NON-COMPLIANT
#define false 3    // NON-COMPLIANT
#define bool int * // NON-COMPLIANT
#undef true        // NON-COMPLIANT
#undef false       // NON-COMPLIANT
#undef bool        // NON-COMPLIANT

_Atomic int g3 = ATOMIC_VAR_INIT(18); // NON-COMPLIANT
_Atomic int g4 = 18;                  // COMPLIANT

// The following cases are already covered by other rules:

// Rule 8.8:
static int g5 = 3; // COMPLIANT
extern int g5;     // NON-COMPLIANT

// Rule 8.2:
void f2();     // NON-COMPLIANT
void f3(void); // COMPLIANT

void f4(int p1) {}; // COMPLIANT
int f5(x)           // NON_COMPLIANT
int x;
{
  return 1;
}

// Rule 21.6 covers the below cases:
void f6(void) {
  // `gets` was removed from C11.
  // gets(stdin); // NON_COMPLIANT

  FILE *file = fopen("", 0);
  // Obsolete usage of ungetc.
  ungetc('c', file); // NON-COMPLIANT

  char buf[10];
  fread(buf, sizeof(buf), 10, file);
  // This is not an obsolete usage of ungetc, but ungetc isn't allowed.
  ungetc('c', file); // NON-COMPLIANT[FALSE NEGATIVE]
}