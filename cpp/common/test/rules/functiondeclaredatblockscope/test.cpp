class A {};

int f0(); // COMPLIANT

int f1() {
  void f1_1(); // NON_COMPLIANT
  return 0;
} // COMPLIANT

int f2() { return 0; } // COMPLIANT

int f3(); // COMPLIANT

namespace N {

int f4(); // COMPLIANT

int f5() { return 0; } // COMPLIANT

int f6() {
  void f6_1(); // NON_COMPLIANT
  return 0;
} // COMPLIANT

namespace N_1 {

int f7(); // COMPLIANT

int f8() {
  void f8_1(); // NON_COMPLIANT
  return 0;
} // COMPLIANT
} // namespace N_1
} // namespace N

int f9() {
  A f9_1(); // NON_COMPLIANT
  return 0;
} // COMPLIANT