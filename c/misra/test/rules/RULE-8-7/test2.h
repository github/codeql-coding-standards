#include "test.h"
extern void f6() {} // NON_COMPLIANT
static void test() { f6(); }