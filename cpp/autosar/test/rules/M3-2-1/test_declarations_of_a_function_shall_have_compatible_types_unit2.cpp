typedef long LL;

int f1();        // COMPLIANT
int f2(int f2a); // COMPLIANT

long f3(); // NON_COMPLIANT

LL f3();          // COMPLIANT
long f4(int f4a); // NON_COMPLIANT

long f5(int f5a) { return 0; } // COMPLIANT

int f6(int f6a) { return 0; } // NON_COMPLIANT

int f20(int f20a); // COMPLIANT - overloaded function
