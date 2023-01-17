int f1();        // COMPLIANT
int f2(int f2a); // COMPLIANT

long f3();       // NON_COMPLIANT
int f4(int f4a); // NON_COMPLIANT

long f5(int f5a) { return 0; } // COMPLIANT

long f6(int f6a) { return 0; } // NON_COMPLIANT

int f20(int f20a, int f20b); // COMPLIANT -- overloaded function

typedef int wi;
typedef int hi;
typedef long a;

extern a f21(wi w, hi h); // NON_COMPLIANT

extern void f22(int f22a, int f22b); // NON_COMPLIANT