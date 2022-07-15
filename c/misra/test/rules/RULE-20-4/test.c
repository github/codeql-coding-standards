#define int long               // NON_COMPLIANT
#define while (E) for (; (E);) // NON_COMPLIANT
#define test(E) for (; (E);)   // COMPLIANT
#define _Decimal128 long       // COMPLIANT introduced in C23