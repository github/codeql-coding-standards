
long a1 = 0L;  // COMPLIANT
long a2 = 0LL; // COMPLIANT
long a3 = 0uL; // COMPLIANT
long a4 = 0Lu; // COMPLIANT
long a5 = 0LU; // COMPLIANT

unsigned long b1 = 0L;  // NON_COMPLIANT
unsigned long b2 = 0LL; // NON_COMPLIANT
unsigned long b3 = 0uL; // COMPLIANT
unsigned long b4 = 0Lu; // COMPLIANT
unsigned long b5 = 0LU; // COMPLIANT

signed long c1 = 0L;  // COMPLIANT
signed long c2 = 0LL; // COMPLIANT
signed long c3 = 0uL; // COMPLIANT
signed long c4 = 0Lu; // COMPLIANT
signed long c5 = 0LU; // COMPLIANT

void f0(int a) {}

void f1(unsigned int a) {}

void f2() {

  f0(1);     // COMPLIANT
  f0(1U);    // COMPLIANT
  f0(0x01);  // COMPLIANT
  f0(0x01U); // COMPLIANT
  f0(001);   // COMPLIANT
  f0(001U);  // COMPLIANT

  f1(1);     // NON_COMPLIANT
  f1(1U);    // COMPLIANT
  f1(0x01);  // NON_COMPLIANT
  f1(0x01U); // COMPLIANT
  f1(001);   // NON_COMPLIANT
  f1(001U);  // COMPLIANT
}
