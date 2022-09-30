extern int *a; // NON_COMPLIANT
extern int i;  // NON_COMPLIANT

extern int f(int a);   // NON_COMPLIANT
extern void f1(int a); // NON_COMPLIANT
void f2(int a, ...) {} // NON_COMPLIANT
int f3();              // COMPLIANT