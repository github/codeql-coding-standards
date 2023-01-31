typedef unsigned int UINT16;

enum Color { R, G, B };

struct SampleStruct {
  int x1 : 2;          // NON_COMPLIANT - not explicitly signed or unsigned
  unsigned int x2 : 2; // COMPILANT - explicitly unsigned
  signed int x3 : 2;   // COMPILANT - explicitly signed
  UINT16 x4 : 2;       // COMPLIANT - type alias resolves to a compliant type
  signed long x5 : 2; // NON_COMPLIANT - cannot declare bit field for long, even
                      // if it's signed
  signed char x6 : 2; // NON_COMPILANT - cannot declare bit field for char, even
                      // if it's signed
  enum Color x7 : 3;  // NON_COMPILANT - cannot declare bit field for enum
} sample_struct;
