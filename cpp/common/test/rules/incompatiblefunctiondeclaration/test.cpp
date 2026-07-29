long f(int a) { // NON_COMPLIANT
  return a * 2;
}

void f1(long a); // NON_COMPLIANT
void f2() {}     // NON_COMPLIANT
int f3();        // COMPLIANT

extern "C" long f4(int a); // NON_COMPLIANT
long f5();                 // NON_COMPLIANT[FALSE_NEGATIVE]