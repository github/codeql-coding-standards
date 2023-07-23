
long a1 = 0L;  // COMPLIANT
long a2 = 0LL; // COMPLIANT
long a3 = 0uL; // COMPLIANT
long a4 = 0Lu; // COMPLIANT
long a5 = 0LU; // COMPLIANT

unsigned long b1 = 0L;  // COMPLIANT - conversion is not considered
unsigned long b2 = 0LL; // COMPLIANT - conversion is not considered
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

  f1(1);     // COMPLIANT - conversion is not considered
  f1(1U);    // COMPLIANT
  f1(0x01);  // COMPLIANT - conversion is not considered
  f1(0x01U); // COMPLIANT
  f1(001);   // COMPLIANT - conversion is not considered
  f1(001U);  // COMPLIANT
}

void hex() {
  32767;       // COMPLIANT
  0x7fff;      // COMPLIANT
  32768;       // COMPLIANT
  32768u;      // COMPLIANT
  0xFFFFFFFF;  // NON_COMPLIANT
  0xFFFFFFFFu; // COMPLIANT
  0x8000u;     // COMPLIANT
}
