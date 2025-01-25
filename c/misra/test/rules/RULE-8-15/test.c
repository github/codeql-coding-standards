extern _Alignas(16) int g1; // COMPLIANT
extern _Alignas(16) int g1; // COMPLIANT

extern _Alignas(16) int g2;
extern int g2; // NON_COMPLIANT

extern int g3; // NON_COMPLIANT
extern _Alignas(16) int g3;

// Does not compile on clang:
// extern _Alignas(16) int g4; // COMPLIANT
// extern _Alignas(32) int g4; // COMPLIANT

extern int g5; // COMPLIANT
extern int g5; // COMPLIANT

// Spec says elements must be lexically identical after macro expansion
extern _Alignas(int) int g6; // NON_COMPLIANT
extern _Alignas(4) int g6;   // NON_COMPLIANT

#define THIRTY_TWO 32
extern _Alignas(16 * 2) int g7; // NON_COMPLIANT
extern _Alignas(32) int g7;     // NON_COMPLIANT

extern _Alignas(THIRTY_TWO) int g8; // COMPLIANT
extern _Alignas(32) int g8;         // COMPLIANT

extern _Alignas(16 * 2) int g9; // NON_COMPLIANT
extern _Alignas(2 * 16) int g9; // NON_COMPLIANT

extern _Alignas(int) int g10; // COMPLIANT
extern _Alignas(int) int g10; // COMPLIANT

extern _Alignas(signed int) int g11;   // NON_COMPLIANT
extern _Alignas(unsigned int) int g11; // NON_COMPLIANT