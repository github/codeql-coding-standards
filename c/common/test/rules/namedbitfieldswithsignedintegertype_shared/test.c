// NOTICE: THE TEST CASES BELOW ARE ALSO INCLUDED IN THE C++ TEST CASE AND
// CHANGES SHOULD BE REFLECTED THERE AS WELL.
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

struct S {
  signed int x : 1; // NON-COMPLIANT
  signed int y : 5; // COMPLIANT
  signed int z : 7; // COMPLIANT
  signed int : 0;   // COMPLIANT
  signed int : 1;   // COMPLIANT
  signed int : 2;   // COMPLIANT
};