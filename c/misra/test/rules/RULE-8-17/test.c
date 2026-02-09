_Alignas(8) int g1;                                     // COMPLIANT
_Alignas(8) _Alignas(16) int g2;                        // NON-COMPLIANT
_Alignas(8) _Alignas(8) int g3;                         // NON-COMPLIANT
_Alignas(float) _Alignas(int) int g4;                   // NON-COMPLIANT
_Alignas(float) _Alignas(float) int g5;                 // NON-COMPLIANT
_Alignas(float) _Alignas(float) _Alignas(float) int g5; // NON-COMPLIANT

struct s {
  _Alignas(64) int m1;                // COMPLIANT
  _Alignas(long) _Alignas(16) int m2; // NON_COMPLIANT
};

void f() {
  _Alignas(8) int l1;                 // COMPLIANT
  _Alignas(long) _Alignas(16) int l2; // NON_COMPLIANT
}