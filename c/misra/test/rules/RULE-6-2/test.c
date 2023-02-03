#include <stdint.h>

struct SampleStruct {
  int x1 : 1; // NON_COMPLIANT: very likely be signed, but if it's not, the
              // query will automatically handle it since we use signed(), not
              // isExplicitlySigned().
  signed int x2 : 1; // NON_COMPLIANT: single-bit named field with a signed type
  signed char
      x3 : 1; // NON_COMPLIANT: single-bit named field with a signed type
  signed short
      x4 : 1; // NON_COMPLIANT: single-bit named field with a signed type
  unsigned int
      x5 : 1; // COMPLIANT: single-bit named field but with an unsigned type
  signed int x6 : 2; // COMPLIANT: named field with a signed type but declared
                     // to carry more than 1 bit
  signed char : 1;   // COMPLIANT: single-bit bit-field but unnamed
} sample_struct;
