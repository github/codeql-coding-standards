#undef assert
void assert(int i); // NON_COMPLIANT

#define assert(x) (void)0