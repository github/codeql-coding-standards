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
const char *a1 = "\x11"
                 "G"; // COMPLIANT

const char *a2 = "\x1"
                 "G"; // COMPLIANT

const char *a3 = "\x1A"; // COMPLIANT

const char *a4 = "\x1AG"; // NON_COMPLIANT

const char *a5 = "\021"; // COMPLIANT
const char *a6 = "\029"; // NON_COMPLIANT
const char *a7 = "\0"
                 "0";     // COMPLIANT
const char *a8 = "\0127"; // NON_COMPLIANT
const char *a9 = "\0157"; // NON_COMPLIANT

const char *a10 = "\012\0129"; // NON_COMPLIANT (1x)
const char *a11 = "\012\019";  // NON_COMPLIANT
const char *a12 = "\012\017";  // COMPLIANT

const char *a13 = "\012AAA\017"; // NON_COMPLIANT (1x)

const char *a14 = "Some Data \012\017";  // COMPLIANT
const char *a15 = "Some Data \012\017A"; // NON_COMPLIANT (1x)
const char *a16 = "Some Data \012\017A"
                  "5"; // NON_COMPLIANT (1x)
const char *a17 = "Some Data \012\017"
                  "A"
                  "\0121"; // NON_COMPLIANT (1x)

const char *a18 = "\x11"
                  "G\001"; // COMPLIANT
const char *a19 = "\x11"
                  "G\0012"; // NON_COMPLIANT (1x)
const char *a20 = "\x11G"
                  "G\001"; // NON_COMPLIANT (1x)
const char *a21 = "\x11G"
                  "G\0013"; // NON_COMPLIANT (2x)

// clang-format off
const char *b1 = "\x11" "G"; // COMPLIANT
const char *b2 = "\x1" "G"; // COMPLIANT
const char *b3 = "\0" "0";     // COMPLIANT
const char *b4 = "Some Data \012\017A" "5"; // NON_COMPLIANT (1x)
const char *b5 = "Some Data \012\017" "A" "\0121"; // NON_COMPLIANT (1x)
const char *b6 = "\x11" "G\001"; // COMPLIANT
const char *b7 = "\x11" "G\0012"; // NON_COMPLIANT (1x)
const char *b8 = "\x11G" "G\001"; // NON_COMPLIANT (1x)
const char *b9 = "\x11G" "G\0013"; // NON_COMPLIANT (2x)

char c1 = '\023'; // COMPLIANT
char c2 = '\x0a'; // COMPLIANT
