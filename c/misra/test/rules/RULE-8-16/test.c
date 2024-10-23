_Alignas(8) int g1;     // COMPLIANT
_Alignas(0) int g2;     // NON-COMPLIANT
_Alignas(8 - 8) int g3; // NON-COMPLIANT
_Alignas(float) int g4; // COMPLIANT

struct s {
  _Alignas(64) int m1; // COMPLIANT
  _Alignas(0) int m2;  // NON_COMPLIANT
};

void f() {
  _Alignas(8) int l1; // COMPLIANT
  _Alignas(0) int l2; // NON-COMPLIANT
}