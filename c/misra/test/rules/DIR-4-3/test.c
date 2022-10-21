#define N1 asm("HCF")
#define N2 __asm__("HCF")

void f1() {
  int a;
  N1; // NON_COMPLIANT
}

void f2() {
  int a;
  N2; // NON_COMPLIANT
}

void f3() {
  N1; // COMPLIANT
}

void f4() {
  N2; // COMPLIANT
}

void f5() {
  __asm__("HCF"); // COMPLIANT
}

void f6() {
  asm("HCF"); // COMPLIANT
}

inline void f7() {
  int a;
  N1; // NON_COMPLIANT
}

inline void f8() {
  int a;
  N2; // NON_COMPLIANT
}

inline void f9() {
  N1; // COMPLIANT
}

inline void f10() {
  N2; // COMPLIANT
}

inline void f11() {
  __asm__("HCF"); // COMPLIANT
}

inline void f12() {
  asm("HCF"); // COMPLIANT
}

inline int f13() {
  int a;
  N2; // NON_COMPLIANT
  return 0;
}

inline int f14() {
  N1; // COMPLIANT
  return 0;
}

inline int f15() {
  N2; // COMPLIANT
  return 0;
}

inline int f16() {
  __asm__("HCF"); // COMPLIANT
  return 0;
}

inline int f17() {
  asm("HCF"); // COMPLIANT
  return 0;
}