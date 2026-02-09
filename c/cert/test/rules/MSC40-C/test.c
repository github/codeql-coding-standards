static int g1 = 0;
extern int g2 = 1;
const int g3 = 1; // defaults to internal linkage

extern inline void test1() {
  static int i = 0; // NON_COMPLIANT
  g1++;             // NON_COMPLIANT
  g2++;             // COMPLIANT
  g3;               // NON_COMPLIANT
}

extern void test2() {
  static int i = 0; // COMPLIANT
  g1++;             // COMPLIANT
  g2++;             // COMPLIANT
  g3;               // COMPLIANT
}

void test3() {
  static int i = 0; // COMPLIANT
  g1++;             // COMPLIANT
  g2++;             // COMPLIANT
  g3;               // COMPLIANT
}

inline void test4() {
  static int i = 0; // NON_COMPLIANT
  g1++;             // NON_COMPLIANT
  g2++;             // COMPLIANT
  g3;               // NON_COMPLIANT
}