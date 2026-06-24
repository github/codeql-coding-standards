extern int f(int a);   // NON_COMPLIANT
extern void f1(int a); // NON_COMPLIANT
void f2(int a, ...) {} // NON_COMPLIANT
int f3();              // COMPLIANT

extern "C" long f4(char a); // NON_COMPLIANT
long f5() noexcept;         // NON_COMPLIANT[FALSE_NEGATIVE]