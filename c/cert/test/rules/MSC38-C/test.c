#include "assert.h"

extern int errno; // NON_COMPLIANT

typedef void (*handler_type)(int);

void execute_handler(handler_type handler, int value) { handler(value); }

void f(int e) {
  execute_handler(&(assert), e < 0); // NON_COMPLIANT
}

static void assert_handler(int value) { assert(value); }

void f2(int e) {
  execute_handler(&assert_handler, e < 0); // COMPLIANT
}