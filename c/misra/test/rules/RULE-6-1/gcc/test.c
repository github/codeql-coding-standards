typedef unsigned int UINT16;

enum Color { R, G, B };

struct SampleStruct {
  int x1 : 2;          // COMPLIANT
  unsigned int x2 : 2; // COMPLIANT - explicitly unsigned
  signed int x3 : 2;   // COMPLIANT - explicitly signed
  UINT16 x4 : 2;       // COMPLIANT - type alias resolves to a compliant type
  signed long x5 : 2;  // COMPLIANT
  signed char x6 : 2;  // COMPLIANT
  enum Color x7 : 3;   // COMPLIANT
  //_Atomic(int) x8 : 2;   // NON_COMPLIANT[COMPILER_CHECKED] - atomic types are
  //not permitted for bit-fields.
} sample_struct;
