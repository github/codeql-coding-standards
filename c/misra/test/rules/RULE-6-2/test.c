#include <stdint.h>

struct SampleStruct {
  int x1 : 1; // NON_COMPILANT: very likely be signed, but if it's not, the
              // query will automatically handle it since we use signed(), not
              // isExplicitlySigned().
  signed int x2 : 1; // NON_COMPILANT: single-bit named field with a signed type
  signed char
      x3 : 1; // NON_COMPILANT: single-bit named field with a signed type
  signed short
      x4 : 1; // NON_COMPILANT: single-bit named field with a signed type
  unsigned int
      x5 : 1; // COMPILANT: single-bit named field but with an unsigned type
  signed int x6 : 2; // COMPILANT: named field with a signed type but declared
                     // to carry more than 1 bit
  int32_t x7 : 1;  // NON_COMPILANT: single-bit named field that has single-bit
                   // bit-field, even though technically it has 32 bits
  signed char : 1; // COMPILANT: single-bit bit-field but unnamed
} sample_struct;
