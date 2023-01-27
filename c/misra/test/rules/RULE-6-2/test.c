#include <stdint.h>

struct SampleStruct {
  int x1 : 1; // compilant: single-bit named field without signed declaration
  signed int x2 : 1; // non_compilant: single-bit named field with a signed type
  signed char
      x3 : 1; // non_compilant: single-bit named field with a signed type
  signed short
      x4 : 1; // non_compilant: single-bit named field with a signed type
  unsigned int
      x5 : 1; // compilant: single-bit named field but with an unsigned type
  signed int x6 : 2; // compilant: named field with a signed type but declared
                     // to carry more than 1 bit
  int32_t x7 : 1;  // non_compilant: single-bit named field that has single-bit
                   // bit-field, even though technically it has 32 bits
  signed char : 1; // compilant: single-bit bit-field but unnamed
} sample_struct;