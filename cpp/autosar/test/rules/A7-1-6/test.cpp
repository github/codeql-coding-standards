// NON_COMPLIANT
typedef unsigned int uint_32;

// COMPLIANT
using fPointer2 = int (*)(int);
void test_typedef() { uint_32 ui = 0; }