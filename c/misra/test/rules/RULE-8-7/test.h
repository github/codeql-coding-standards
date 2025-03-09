extern int i;     // COMPLIANT - accessed multiple translation units
extern int i1;    // NON_COMPLIANT - accessed one translation unit
extern void f1(); // COMPLIANT  - accessed multiple translation units
extern void f2(); // NON_COMPLIANT - accessed one translation unit