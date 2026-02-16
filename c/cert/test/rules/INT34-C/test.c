#include <inttypes.h>
#include <limits.h>
#include <stddef.h>

extern size_t popcount(uintmax_t x){};
#define PRECISION(x) popcount(x)

int main() {
  unsigned char lhs0 = UCHAR_MAX;
  signed char lhs1 = CHAR_MAX;
  char lhs2 = CHAR_MAX;
  unsigned short lhs3 = USHRT_MAX;
  signed short lhs4 = SHRT_MAX;
  short lhs5 = SHRT_MAX;
  unsigned int lhs6 = UINT_MAX;
  signed int lhs7 = INT_MAX;
  int lhs8 = INT_MAX;
  unsigned long lhs9 = ULONG_MAX;
  signed long lhs10 = LONG_MAX;
  long lhs11 = LONG_MAX;
  unsigned long long lhs12 = ULLONG_MAX;
  signed long long lhs13 = LLONG_MAX;
  long long lhs14 = LLONG_MAX;

  unsigned long long rhs0 = 8;
  unsigned long long rhs1 = 7;
  unsigned long long rhs2 = 7;
  unsigned long long rhs3 = 16;
  unsigned long long rhs4 = 15;
  unsigned long long rhs5 = 15;
  unsigned long long rhs6 = 32;
  unsigned long long rhs7 = 31;
  unsigned long long rhs8 = 31;
  unsigned long long rhs9 = 32;
  unsigned long long rhs10 = 31;
  unsigned long long rhs11 = 31;
  unsigned long long rhs12 = 64;
  unsigned long long rhs13 = 63;
  unsigned long long rhs14 = 63;

  /* ========== Left shifts ========== */

  lhs0 << rhs0;  // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs0's
  lhs0 << rhs1;  // COMPLIANT: lhs0's precision is strictly greater than rhs1
  lhs0 << rhs2;  // COMPLIANT: lhs0's precision is strictly greater than rhs2
  lhs0 << rhs3;  // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs3's
  lhs0 << rhs4;  // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs4's
  lhs0 << rhs5;  // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs5's
  lhs0 << rhs6;  // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs6's
  lhs0 << rhs7;  // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs7's
  lhs0 << rhs8;  // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs8's
  lhs0 << rhs9;  // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs9's
  lhs0 << rhs10; // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs10's
  lhs0 << rhs11; // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs11's
  lhs0 << rhs12; // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs12's
  lhs0 << rhs13; // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs13's
  lhs0 << rhs14; // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs14's
  lhs1 << rhs0;  // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs0's
  lhs1 << rhs1;  // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs1's
  lhs1 << rhs2;  // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs2's
  lhs1 << rhs3;  // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs3's
  lhs1 << rhs4;  // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs4's
  lhs1 << rhs5;  // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs5's
  lhs1 << rhs6;  // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs6's
  lhs1 << rhs7;  // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs7's
  lhs1 << rhs8;  // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs8's
  lhs1 << rhs9;  // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs9's
  lhs1 << rhs10; // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs10's
  lhs1 << rhs11; // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs11's
  lhs1 << rhs12; // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs12's
  lhs1 << rhs13; // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs13's
  lhs1 << rhs14; // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs14's
  lhs2 << rhs0;  // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs0's
  lhs2 << rhs1;  // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs1's
  lhs2 << rhs2;  // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs2's
  lhs2 << rhs3;  // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs3's
  lhs2 << rhs4;  // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs4's
  lhs2 << rhs5;  // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs5's
  lhs2 << rhs6;  // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs6's
  lhs2 << rhs7;  // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs7's
  lhs2 << rhs8;  // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs8's
  lhs2 << rhs9;  // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs9's
  lhs2 << rhs10; // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs10's
  lhs2 << rhs11; // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs11's
  lhs2 << rhs12; // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs12's
  lhs2 << rhs13; // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs13's
  lhs2 << rhs14; // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs14's
  lhs3 << rhs0;  // COMPLIANT: lhs3's precision is strictly greater than rhs0
  lhs3 << rhs1;  // COMPLIANT: lhs3's precision is strictly greater than rhs1
  lhs3 << rhs2;  // COMPLIANT: lhs3's precision is strictly greater than rhs2
  lhs3 << rhs3;  // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs3's
  lhs3 << rhs4;  // COMPLIANT: lhs3's precision is strictly greater than rhs4
  lhs3 << rhs5;  // COMPLIANT: lhs3's precision is strictly greater than rhs5
  lhs3 << rhs6;  // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs6's
  lhs3 << rhs7;  // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs7's
  lhs3 << rhs8;  // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs8's
  lhs3 << rhs9;  // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs9's
  lhs3 << rhs10; // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs10's
  lhs3 << rhs11; // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs11's
  lhs3 << rhs12; // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs12's
  lhs3 << rhs13; // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs13's
  lhs3 << rhs14; // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs14's
  lhs4 << rhs0;  // COMPLIANT: lhs4's precision is strictly greater than rhs0
  lhs4 << rhs1;  // COMPLIANT: lhs4's precision is strictly greater than rhs1
  lhs4 << rhs2;  // COMPLIANT: lhs4's precision is strictly greater than rhs2
  lhs4 << rhs3;  // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs3's
  lhs4 << rhs4;  // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs4's
  lhs4 << rhs5;  // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs5's
  lhs4 << rhs6;  // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs6's
  lhs4 << rhs7;  // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs7's
  lhs4 << rhs8;  // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs8's
  lhs4 << rhs9;  // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs9's
  lhs4 << rhs10; // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs10's
  lhs4 << rhs11; // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs11's
  lhs4 << rhs12; // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs12's
  lhs4 << rhs13; // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs13's
  lhs4 << rhs14; // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs14's
  lhs5 << rhs0;  // COMPLIANT: lhs5's precision is strictly greater than rhs0
  lhs5 << rhs1;  // COMPLIANT: lhs5's precision is strictly greater than rhs1
  lhs5 << rhs2;  // COMPLIANT: lhs5's precision is strictly greater than rhs2
  lhs5 << rhs3;  // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs3's
  lhs5 << rhs4;  // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs4's
  lhs5 << rhs5;  // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs5's
  lhs5 << rhs6;  // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs6's
  lhs5 << rhs7;  // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs7's
  lhs5 << rhs8;  // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs8's
  lhs5 << rhs9;  // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs9's
  lhs5 << rhs10; // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs10's
  lhs5 << rhs11; // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs11's
  lhs5 << rhs12; // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs12's
  lhs5 << rhs13; // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs13's
  lhs5 << rhs14; // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs14's
  lhs6 << rhs0;  // COMPLIANT: lhs6's precision is strictly greater than rhs0
  lhs6 << rhs1;  // COMPLIANT: lhs6's precision is strictly greater than rhs1
  lhs6 << rhs2;  // COMPLIANT: lhs6's precision is strictly greater than rhs2
  lhs6 << rhs3;  // COMPLIANT: lhs6's precision is strictly greater than rhs3
  lhs6 << rhs4;  // COMPLIANT: lhs6's precision is strictly greater than rhs4
  lhs6 << rhs5;  // COMPLIANT: lhs6's precision is strictly greater than rhs5
  lhs6 << rhs6;  // NON_COMPLIANT: lhs6's precision is not strictly greater than
                 // rhs6's
  lhs6 << rhs7;  // COMPLIANT: lhs6's precision is strictly greater than rhs7
  lhs6 << rhs8;  // COMPLIANT: lhs6's precision is strictly greater than rhs8
  lhs6 << rhs9;  // NON_COMPLIANT: lhs6's precision is not strictly greater than
                 // rhs9's
  lhs6 << rhs10; // COMPLIANT: lhs6's precision is strictly greater than rhs10
  lhs6 << rhs11; // COMPLIANT: lhs6's precision is strictly greater than rhs11
  lhs6 << rhs12; // NON_COMPLIANT: lhs6's precision is not strictly greater than
                 // rhs12's
  lhs6 << rhs13; // NON_COMPLIANT: lhs6's precision is not strictly greater than
                 // rhs13's
  lhs6 << rhs14; // NON_COMPLIANT: lhs6's precision is not strictly greater than
                 // rhs14's
  lhs7 << rhs0;  // COMPLIANT: lhs7's precision is strictly greater than rhs0
  lhs7 << rhs1;  // COMPLIANT: lhs7's precision is strictly greater than rhs1
  lhs7 << rhs2;  // COMPLIANT: lhs7's precision is strictly greater than rhs2
  lhs7 << rhs3;  // COMPLIANT: lhs7's precision is strictly greater than rhs3
  lhs7 << rhs4;  // COMPLIANT: lhs7's precision is strictly greater than rhs4
  lhs7 << rhs5;  // COMPLIANT: lhs7's precision is strictly greater than rhs5
  lhs7 << rhs6;  // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs6's
  lhs7 << rhs7;  // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs7's
  lhs7 << rhs8;  // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs8's
  lhs7 << rhs9;  // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs9's
  lhs7 << rhs10; // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs10's
  lhs7 << rhs11; // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs11's
  lhs7 << rhs12; // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs12's
  lhs7 << rhs13; // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs13's
  lhs7 << rhs14; // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs14's
  lhs8 << rhs0;  // COMPLIANT: lhs8's precision is strictly greater than rhs0
  lhs8 << rhs1;  // COMPLIANT: lhs8's precision is strictly greater than rhs1
  lhs8 << rhs2;  // COMPLIANT: lhs8's precision is strictly greater than rhs2
  lhs8 << rhs3;  // COMPLIANT: lhs8's precision is strictly greater than rhs3
  lhs8 << rhs4;  // COMPLIANT: lhs8's precision is strictly greater than rhs4
  lhs8 << rhs5;  // COMPLIANT: lhs8's precision is strictly greater than rhs5
  lhs8 << rhs6;  // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs6's
  lhs8 << rhs7;  // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs7's
  lhs8 << rhs8;  // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs8's
  lhs8 << rhs9;  // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs9's
  lhs8 << rhs10; // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs10's
  lhs8 << rhs11; // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs11's
  lhs8 << rhs12; // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs12's
  lhs8 << rhs13; // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs13's
  lhs8 << rhs14; // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs14's
  lhs9 << rhs0;  // COMPLIANT: lhs9's precision is strictly greater than rhs0
  lhs9 << rhs1;  // COMPLIANT: lhs9's precision is strictly greater than rhs1
  lhs9 << rhs2;  // COMPLIANT: lhs9's precision is strictly greater than rhs2
  lhs9 << rhs3;  // COMPLIANT: lhs9's precision is strictly greater than rhs3
  lhs9 << rhs4;  // COMPLIANT: lhs9's precision is strictly greater than rhs4
  lhs9 << rhs5;  // COMPLIANT: lhs9's precision is strictly greater than rhs5
  lhs9 << rhs6;  // NON_COMPLIANT: lhs9's precision is not strictly greater than
                 // rhs6's
  lhs9 << rhs7;  // COMPLIANT: lhs9's precision is strictly greater than rhs7
  lhs9 << rhs8;  // COMPLIANT: lhs9's precision is strictly greater than rhs8
  lhs9 << rhs9;  // NON_COMPLIANT: lhs9's precision is not strictly greater than
                 // rhs9's
  lhs9 << rhs10; // COMPLIANT: lhs9's precision is strictly greater than rhs10
  lhs9 << rhs11; // COMPLIANT: lhs9's precision is strictly greater than rhs11
  lhs9 << rhs12; // NON_COMPLIANT: lhs9's precision is not strictly greater than
                 // rhs12's
  lhs9 << rhs13; // NON_COMPLIANT: lhs9's precision is not strictly greater than
                 // rhs13's
  lhs9 << rhs14; // NON_COMPLIANT: lhs9's precision is not strictly greater than
                 // rhs14's
  lhs10 << rhs0; // COMPLIANT: lhs10's precision is strictly greater than rhs0
  lhs10 << rhs1; // COMPLIANT: lhs10's precision is strictly greater than rhs1
  lhs10 << rhs2; // COMPLIANT: lhs10's precision is strictly greater than rhs2
  lhs10 << rhs3; // COMPLIANT: lhs10's precision is strictly greater than rhs3
  lhs10 << rhs4; // COMPLIANT: lhs10's precision is strictly greater than rhs4
  lhs10 << rhs5; // COMPLIANT: lhs10's precision is strictly greater than rhs5
  lhs10 << rhs6; // NON_COMPLIANT: lhs10's precision is not strictly greater
                 // than rhs6's
  lhs10 << rhs7; // NON_COMPLIANT: lhs10's precision is not strictly greater
                 // than rhs7's
  lhs10 << rhs8; // NON_COMPLIANT: lhs10's precision is not strictly greater
                 // than rhs8's
  lhs10 << rhs9; // NON_COMPLIANT: lhs10's precision is not strictly greater
                 // than rhs9's
  lhs10 << rhs10; // NON_COMPLIANT: lhs10's precision is not strictly greater
                  // than rhs10's
  lhs10 << rhs11; // NON_COMPLIANT: lhs10's precision is not strictly greater
                  // than rhs11's
  lhs10 << rhs12; // NON_COMPLIANT: lhs10's precision is not strictly greater
                  // than rhs12's
  lhs10 << rhs13; // NON_COMPLIANT: lhs10's precision is not strictly greater
                  // than rhs13's
  lhs10 << rhs14; // NON_COMPLIANT: lhs10's precision is not strictly greater
                  // than rhs14's
  lhs11 << rhs0;  // COMPLIANT: lhs11's precision is strictly greater than rhs0
  lhs11 << rhs1;  // COMPLIANT: lhs11's precision is strictly greater than rhs1
  lhs11 << rhs2;  // COMPLIANT: lhs11's precision is strictly greater than rhs2
  lhs11 << rhs3;  // COMPLIANT: lhs11's precision is strictly greater than rhs3
  lhs11 << rhs4;  // COMPLIANT: lhs11's precision is strictly greater than rhs4
  lhs11 << rhs5;  // COMPLIANT: lhs11's precision is strictly greater than rhs5
  lhs11 << rhs6;  // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs6's
  lhs11 << rhs7;  // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs7's
  lhs11 << rhs8;  // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs8's
  lhs11 << rhs9;  // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs9's
  lhs11 << rhs10; // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs10's
  lhs11 << rhs11; // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs11's
  lhs11 << rhs12; // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs12's
  lhs11 << rhs13; // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs13's
  lhs11 << rhs14; // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs14's
  lhs12 << rhs0;  // COMPLIANT: lhs12's precision is strictly greater than rhs0
  lhs12 << rhs1;  // COMPLIANT: lhs12's precision is strictly greater than rhs1
  lhs12 << rhs2;  // COMPLIANT: lhs12's precision is strictly greater than rhs2
  lhs12 << rhs3;  // COMPLIANT: lhs12's precision is strictly greater than rhs3
  lhs12 << rhs4;  // COMPLIANT: lhs12's precision is strictly greater than rhs4
  lhs12 << rhs5;  // COMPLIANT: lhs12's precision is strictly greater than rhs5
  lhs12 << rhs6;  // COMPLIANT: lhs12's precision is strictly greater than rhs6
  lhs12 << rhs7;  // COMPLIANT: lhs12's precision is strictly greater than rhs7
  lhs12 << rhs8;  // COMPLIANT: lhs12's precision is strictly greater than rhs8
  lhs12 << rhs9;  // COMPLIANT: lhs12's precision is strictly greater than rhs9
  lhs12 << rhs10; // COMPLIANT: lhs12's precision is strictly greater than rhs10
  lhs12 << rhs11; // COMPLIANT: lhs12's precision is strictly greater than rhs11
  lhs12 << rhs12; // NON_COMPLIANT: lhs12's precision is not strictly greater
                  // than rhs12's
  lhs12 << rhs13; // COMPLIANT: lhs12's precision is strictly greater than rhs13
  lhs12 << rhs14; // COMPLIANT: lhs12's precision is strictly greater than rhs14
  lhs13 << rhs0;  // COMPLIANT: lhs13's precision is strictly greater than rhs0
  lhs13 << rhs1;  // COMPLIANT: lhs13's precision is strictly greater than rhs1
  lhs13 << rhs2;  // COMPLIANT: lhs13's precision is strictly greater than rhs2
  lhs13 << rhs3;  // COMPLIANT: lhs13's precision is strictly greater than rhs3
  lhs13 << rhs4;  // COMPLIANT: lhs13's precision is strictly greater than rhs4
  lhs13 << rhs5;  // COMPLIANT: lhs13's precision is strictly greater than rhs5
  lhs13 << rhs6;  // COMPLIANT: lhs13's precision is strictly greater than rhs6
  lhs13 << rhs7;  // COMPLIANT: lhs13's precision is strictly greater than rhs7
  lhs13 << rhs8;  // COMPLIANT: lhs13's precision is strictly greater than rhs8
  lhs13 << rhs9;  // COMPLIANT: lhs13's precision is strictly greater than rhs9
  lhs13 << rhs10; // COMPLIANT: lhs13's precision is strictly greater than rhs10
  lhs13 << rhs11; // COMPLIANT: lhs13's precision is strictly greater than rhs11
  lhs13 << rhs12; // NON_COMPLIANT: lhs13's precision is not strictly greater
                  // than rhs12's
  lhs13 << rhs13; // NON_COMPLIANT: lhs13's precision is not strictly greater
                  // than rhs13's
  lhs13 << rhs14; // NON_COMPLIANT: lhs13's precision is not strictly greater
                  // than rhs14's
  lhs14 << rhs0;  // COMPLIANT: lhs14's precision is strictly greater than rhs0
  lhs14 << rhs1;  // COMPLIANT: lhs14's precision is strictly greater than rhs1
  lhs14 << rhs2;  // COMPLIANT: lhs14's precision is strictly greater than rhs2
  lhs14 << rhs3;  // COMPLIANT: lhs14's precision is strictly greater than rhs3
  lhs14 << rhs4;  // COMPLIANT: lhs14's precision is strictly greater than rhs4
  lhs14 << rhs5;  // COMPLIANT: lhs14's precision is strictly greater than rhs5
  lhs14 << rhs6;  // COMPLIANT: lhs14's precision is strictly greater than rhs6
  lhs14 << rhs7;  // COMPLIANT: lhs14's precision is strictly greater than rhs7
  lhs14 << rhs8;  // COMPLIANT: lhs14's precision is strictly greater than rhs8
  lhs14 << rhs9;  // COMPLIANT: lhs14's precision is strictly greater than rhs9
  lhs14 << rhs10; // COMPLIANT: lhs14's precision is strictly greater than rhs10
  lhs14 << rhs11; // COMPLIANT: lhs14's precision is strictly greater than rhs11
  lhs14 << rhs12; // NON_COMPLIANT: lhs14's precision is not strictly greater
                  // than rhs12's
  lhs14 << rhs13; // NON_COMPLIANT: lhs14's precision is not strictly greater
                  // than rhs13's
  lhs14 << rhs14; // NON_COMPLIANT: lhs14's precision is not strictly greater
                  // than rhs14's

  /* ===== Left shift with guards, the shift expression is at `then` branch
   * ===== */

  if (rhs0 < PRECISION(UCHAR_MAX))
    lhs0 << rhs0; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs0, but it's inside a PRECISION guard
  if (rhs3 < PRECISION(UCHAR_MAX))
    lhs0 << rhs3; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  if (rhs4 < PRECISION(UCHAR_MAX))
    lhs0 << rhs4; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  if (rhs5 < PRECISION(UCHAR_MAX))
    lhs0 << rhs5; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(UCHAR_MAX))
    lhs0 << rhs6; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(UCHAR_MAX))
    lhs0 << rhs7; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(UCHAR_MAX))
    lhs0 << rhs8; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(UCHAR_MAX))
    lhs0 << rhs9; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(UCHAR_MAX))
    lhs0 << rhs10; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(UCHAR_MAX))
    lhs0 << rhs11; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(UCHAR_MAX))
    lhs0 << rhs12; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(UCHAR_MAX))
    lhs0 << rhs13; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(UCHAR_MAX))
    lhs0 << rhs14; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs0 < PRECISION(CHAR_MAX))
    lhs1 << rhs0; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs0, but it's inside a PRECISION guard
  if (rhs1 < PRECISION(CHAR_MAX))
    lhs1 << rhs1; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs1, but it's inside a PRECISION guard
  if (rhs2 < PRECISION(CHAR_MAX))
    lhs1 << rhs2; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs2, but it's inside a PRECISION guard
  if (rhs3 < PRECISION(CHAR_MAX))
    lhs1 << rhs3; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  if (rhs4 < PRECISION(CHAR_MAX))
    lhs1 << rhs4; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  if (rhs5 < PRECISION(CHAR_MAX))
    lhs1 << rhs5; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(CHAR_MAX))
    lhs1 << rhs6; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(CHAR_MAX))
    lhs1 << rhs7; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(CHAR_MAX))
    lhs1 << rhs8; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(CHAR_MAX))
    lhs1 << rhs9; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(CHAR_MAX))
    lhs1 << rhs10; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(CHAR_MAX))
    lhs1 << rhs11; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(CHAR_MAX))
    lhs1 << rhs12; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(CHAR_MAX))
    lhs1 << rhs13; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(CHAR_MAX))
    lhs1 << rhs14; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs0 < PRECISION(CHAR_MAX))
    lhs2 << rhs0; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs0, but it's inside a PRECISION guard
  if (rhs1 < PRECISION(CHAR_MAX))
    lhs2 << rhs1; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs1, but it's inside a PRECISION guard
  if (rhs2 < PRECISION(CHAR_MAX))
    lhs2 << rhs2; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs2, but it's inside a PRECISION guard
  if (rhs3 < PRECISION(CHAR_MAX))
    lhs2 << rhs3; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  if (rhs4 < PRECISION(CHAR_MAX))
    lhs2 << rhs4; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  if (rhs5 < PRECISION(CHAR_MAX))
    lhs2 << rhs5; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(CHAR_MAX))
    lhs2 << rhs6; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(CHAR_MAX))
    lhs2 << rhs7; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(CHAR_MAX))
    lhs2 << rhs8; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(CHAR_MAX))
    lhs2 << rhs9; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(CHAR_MAX))
    lhs2 << rhs10; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(CHAR_MAX))
    lhs2 << rhs11; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(CHAR_MAX))
    lhs2 << rhs12; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(CHAR_MAX))
    lhs2 << rhs13; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(CHAR_MAX))
    lhs2 << rhs14; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs3 < PRECISION(USHRT_MAX))
    lhs3 << rhs3; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(USHRT_MAX))
    lhs3 << rhs6; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(USHRT_MAX))
    lhs3 << rhs7; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(USHRT_MAX))
    lhs3 << rhs8; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(USHRT_MAX))
    lhs3 << rhs9; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(USHRT_MAX))
    lhs3 << rhs10; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(USHRT_MAX))
    lhs3 << rhs11; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(USHRT_MAX))
    lhs3 << rhs12; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(USHRT_MAX))
    lhs3 << rhs13; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(USHRT_MAX))
    lhs3 << rhs14; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs3 < PRECISION(SHRT_MAX))
    lhs4 << rhs3; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  if (rhs4 < PRECISION(SHRT_MAX))
    lhs4 << rhs4; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  if (rhs5 < PRECISION(SHRT_MAX))
    lhs4 << rhs5; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(SHRT_MAX))
    lhs4 << rhs6; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(SHRT_MAX))
    lhs4 << rhs7; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(SHRT_MAX))
    lhs4 << rhs8; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(SHRT_MAX))
    lhs4 << rhs9; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(SHRT_MAX))
    lhs4 << rhs10; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(SHRT_MAX))
    lhs4 << rhs11; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(SHRT_MAX))
    lhs4 << rhs12; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(SHRT_MAX))
    lhs4 << rhs13; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(SHRT_MAX))
    lhs4 << rhs14; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs3 < PRECISION(SHRT_MAX))
    lhs5 << rhs3; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  if (rhs4 < PRECISION(SHRT_MAX))
    lhs5 << rhs4; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  if (rhs5 < PRECISION(SHRT_MAX))
    lhs5 << rhs5; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(SHRT_MAX))
    lhs5 << rhs6; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(SHRT_MAX))
    lhs5 << rhs7; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(SHRT_MAX))
    lhs5 << rhs8; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(SHRT_MAX))
    lhs5 << rhs9; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(SHRT_MAX))
    lhs5 << rhs10; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(SHRT_MAX))
    lhs5 << rhs11; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(SHRT_MAX))
    lhs5 << rhs12; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(SHRT_MAX))
    lhs5 << rhs13; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(SHRT_MAX))
    lhs5 << rhs14; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(UINT_MAX))
    lhs6 << rhs6; // COMPLIANT: lhs6's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(UINT_MAX))
    lhs6 << rhs9; // COMPLIANT: lhs6's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(UINT_MAX))
    lhs6 << rhs12; // COMPLIANT: lhs6's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(UINT_MAX))
    lhs6 << rhs13; // COMPLIANT: lhs6's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(UINT_MAX))
    lhs6 << rhs14; // COMPLIANT: lhs6's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(INT_MAX))
    lhs7 << rhs6; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(INT_MAX))
    lhs7 << rhs7; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(INT_MAX))
    lhs7 << rhs8; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(INT_MAX))
    lhs7 << rhs9; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(INT_MAX))
    lhs7 << rhs10; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(INT_MAX))
    lhs7 << rhs11; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(INT_MAX))
    lhs7 << rhs12; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(INT_MAX))
    lhs7 << rhs13; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(INT_MAX))
    lhs7 << rhs14; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(INT_MAX))
    lhs8 << rhs6; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(INT_MAX))
    lhs8 << rhs7; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(INT_MAX))
    lhs8 << rhs8; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(INT_MAX))
    lhs8 << rhs9; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(INT_MAX))
    lhs8 << rhs10; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(INT_MAX))
    lhs8 << rhs11; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(INT_MAX))
    lhs8 << rhs12; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(INT_MAX))
    lhs8 << rhs13; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(INT_MAX))
    lhs8 << rhs14; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(ULONG_MAX))
    lhs9 << rhs6; // COMPLIANT: lhs9's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(ULONG_MAX))
    lhs9 << rhs9; // COMPLIANT: lhs9's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(ULONG_MAX))
    lhs9 << rhs12; // COMPLIANT: lhs9's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(ULONG_MAX))
    lhs9 << rhs13; // COMPLIANT: lhs9's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(ULONG_MAX))
    lhs9 << rhs14; // COMPLIANT: lhs9's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(LONG_MAX))
    lhs10 << rhs6; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(LONG_MAX))
    lhs10 << rhs7; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(LONG_MAX))
    lhs10 << rhs8; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(LONG_MAX))
    lhs10 << rhs9; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(LONG_MAX))
    lhs10 << rhs10; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(LONG_MAX))
    lhs10 << rhs11; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(LONG_MAX))
    lhs10 << rhs12; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(LONG_MAX))
    lhs10 << rhs13; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(LONG_MAX))
    lhs10 << rhs14; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(LONG_MAX))
    lhs11 << rhs6; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(LONG_MAX))
    lhs11 << rhs7; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(LONG_MAX))
    lhs11 << rhs8; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(LONG_MAX))
    lhs11 << rhs9; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(LONG_MAX))
    lhs11 << rhs10; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(LONG_MAX))
    lhs11 << rhs11; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(LONG_MAX))
    lhs11 << rhs12; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(LONG_MAX))
    lhs11 << rhs13; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(LONG_MAX))
    lhs11 << rhs14; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(ULLONG_MAX))
    lhs12 << rhs12; // COMPLIANT: lhs12's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(LLONG_MAX))
    lhs13 << rhs12; // COMPLIANT: lhs13's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(LLONG_MAX))
    lhs13 << rhs13; // COMPLIANT: lhs13's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(LLONG_MAX))
    lhs13 << rhs14; // COMPLIANT: lhs13's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(LLONG_MAX))
    lhs14 << rhs12; // COMPLIANT: lhs14's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(LLONG_MAX))
    lhs14 << rhs13; // COMPLIANT: lhs14's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(LLONG_MAX))
    lhs14 << rhs14; // COMPLIANT: lhs14's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard

  /* ===== Left shift with guards, the shift expression is at `else` branch
   * ===== */

  if (rhs0 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 << rhs0; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs0, but it's inside a PRECISION guard
  }
  if (rhs3 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 << rhs3; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  }
  if (rhs4 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 << rhs4; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  }
  if (rhs5 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 << rhs5; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 << rhs6; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 << rhs7; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 << rhs8; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 << rhs9; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 << rhs10; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 << rhs11; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 << rhs12; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 << rhs13; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 << rhs14; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs0 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs0; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs0, but it's inside a PRECISION guard
  }
  if (rhs1 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs1; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs1, but it's inside a PRECISION guard
  }
  if (rhs2 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs2; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs2, but it's inside a PRECISION guard
  }
  if (rhs3 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs3; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  }
  if (rhs4 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs4; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  }
  if (rhs5 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs5; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs6; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs7; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs8; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs9; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs10; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs11; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs12; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs13; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 << rhs14; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs0 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs0; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs0, but it's inside a PRECISION guard
  }
  if (rhs1 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs1; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs1, but it's inside a PRECISION guard
  }
  if (rhs2 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs2; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs2, but it's inside a PRECISION guard
  }
  if (rhs3 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs3; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  }
  if (rhs4 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs4; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  }
  if (rhs5 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs5; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs6; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs7; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs8; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs9; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs10; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs11; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs12; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs13; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 << rhs14; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs3 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 << rhs3; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 << rhs6; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 << rhs7; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 << rhs8; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 << rhs9; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 << rhs10; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 << rhs11; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 << rhs12; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 << rhs13; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 << rhs14; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs3 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 << rhs3; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  }
  if (rhs4 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 << rhs4; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  }
  if (rhs5 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 << rhs5; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 << rhs6; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 << rhs7; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 << rhs8; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 << rhs9; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 << rhs10; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 << rhs11; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 << rhs12; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 << rhs13; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 << rhs14; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs3 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 << rhs3; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  }
  if (rhs4 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 << rhs4; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  }
  if (rhs5 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 << rhs5; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 << rhs6; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 << rhs7; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 << rhs8; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 << rhs9; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 << rhs10; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 << rhs11; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 << rhs12; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 << rhs13; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 << rhs14; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(UINT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs6 << rhs6; // COMPLIANT: lhs6's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(UINT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs6 << rhs9; // COMPLIANT: lhs6's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(UINT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs6 << rhs12; // COMPLIANT: lhs6's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(UINT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs6 << rhs13; // COMPLIANT: lhs6's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(UINT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs6 << rhs14; // COMPLIANT: lhs6's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 << rhs6; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 << rhs7; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 << rhs8; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 << rhs9; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 << rhs10; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 << rhs11; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 << rhs12; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 << rhs13; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 << rhs14; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 << rhs6; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 << rhs7; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 << rhs8; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 << rhs9; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 << rhs10; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 << rhs11; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 << rhs12; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 << rhs13; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 << rhs14; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(ULONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs9 << rhs6; // COMPLIANT: lhs9's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(ULONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs9 << rhs9; // COMPLIANT: lhs9's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(ULONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs9 << rhs12; // COMPLIANT: lhs9's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(ULONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs9 << rhs13; // COMPLIANT: lhs9's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(ULONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs9 << rhs14; // COMPLIANT: lhs9's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 << rhs6; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 << rhs7; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 << rhs8; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 << rhs9; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 << rhs10; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 << rhs11; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 << rhs12; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 << rhs13; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 << rhs14; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 << rhs6; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 << rhs7; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 << rhs8; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 << rhs9; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 << rhs10; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 << rhs11; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 << rhs12; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 << rhs13; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 << rhs14; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(ULLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs12 << rhs12; // COMPLIANT: lhs12's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(LLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs13 << rhs12; // COMPLIANT: lhs13's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(LLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs13 << rhs13; // COMPLIANT: lhs13's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(LLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs13 << rhs14; // COMPLIANT: lhs13's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(LLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs14 << rhs12; // COMPLIANT: lhs14's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(LLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs14 << rhs13; // COMPLIANT: lhs14's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(LLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs14 << rhs14; // COMPLIANT: lhs14's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  }

  /* ========== Right shifts ========== */

  lhs0 >>
      rhs0; // NON_COMPLIANT: lhs0's precision is not strictly greater than rhs0
  lhs0 >> rhs1; // COMPLIANT: lhs0's precision is strictly greater than rhs1
  lhs0 >> rhs2; // COMPLIANT: lhs0's precision is strictly greater than rhs2
  lhs0 >>
      rhs3; // NON_COMPLIANT: lhs0's precision is not strictly greater than rhs3
  lhs0 >>
      rhs4; // NON_COMPLIANT: lhs0's precision is not strictly greater than rhs4
  lhs0 >>
      rhs5; // NON_COMPLIANT: lhs0's precision is not strictly greater than rhs5
  lhs0 >>
      rhs6; // NON_COMPLIANT: lhs0's precision is not strictly greater than rhs6
  lhs0 >>
      rhs7; // NON_COMPLIANT: lhs0's precision is not strictly greater than rhs7
  lhs0 >>
      rhs8; // NON_COMPLIANT: lhs0's precision is not strictly greater than rhs8
  lhs0 >>
      rhs9; // NON_COMPLIANT: lhs0's precision is not strictly greater than rhs9
  lhs0 >> rhs10; // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs10
  lhs0 >> rhs11; // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs11
  lhs0 >> rhs12; // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs12
  lhs0 >> rhs13; // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs13
  lhs0 >> rhs14; // NON_COMPLIANT: lhs0's precision is not strictly greater than
                 // rhs14
  lhs1 >>
      rhs0; // NON_COMPLIANT: lhs1's precision is not strictly greater than rhs0
  lhs1 >>
      rhs1; // NON_COMPLIANT: lhs1's precision is not strictly greater than rhs1
  lhs1 >>
      rhs2; // NON_COMPLIANT: lhs1's precision is not strictly greater than rhs2
  lhs1 >>
      rhs3; // NON_COMPLIANT: lhs1's precision is not strictly greater than rhs3
  lhs1 >>
      rhs4; // NON_COMPLIANT: lhs1's precision is not strictly greater than rhs4
  lhs1 >>
      rhs5; // NON_COMPLIANT: lhs1's precision is not strictly greater than rhs5
  lhs1 >>
      rhs6; // NON_COMPLIANT: lhs1's precision is not strictly greater than rhs6
  lhs1 >>
      rhs7; // NON_COMPLIANT: lhs1's precision is not strictly greater than rhs7
  lhs1 >>
      rhs8; // NON_COMPLIANT: lhs1's precision is not strictly greater than rhs8
  lhs1 >>
      rhs9; // NON_COMPLIANT: lhs1's precision is not strictly greater than rhs9
  lhs1 >> rhs10; // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs10
  lhs1 >> rhs11; // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs11
  lhs1 >> rhs12; // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs12
  lhs1 >> rhs13; // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs13
  lhs1 >> rhs14; // NON_COMPLIANT: lhs1's precision is not strictly greater than
                 // rhs14
  lhs2 >>
      rhs0; // NON_COMPLIANT: lhs2's precision is not strictly greater than rhs0
  lhs2 >>
      rhs1; // NON_COMPLIANT: lhs2's precision is not strictly greater than rhs1
  lhs2 >>
      rhs2; // NON_COMPLIANT: lhs2's precision is not strictly greater than rhs2
  lhs2 >>
      rhs3; // NON_COMPLIANT: lhs2's precision is not strictly greater than rhs3
  lhs2 >>
      rhs4; // NON_COMPLIANT: lhs2's precision is not strictly greater than rhs4
  lhs2 >>
      rhs5; // NON_COMPLIANT: lhs2's precision is not strictly greater than rhs5
  lhs2 >>
      rhs6; // NON_COMPLIANT: lhs2's precision is not strictly greater than rhs6
  lhs2 >>
      rhs7; // NON_COMPLIANT: lhs2's precision is not strictly greater than rhs7
  lhs2 >>
      rhs8; // NON_COMPLIANT: lhs2's precision is not strictly greater than rhs8
  lhs2 >>
      rhs9; // NON_COMPLIANT: lhs2's precision is not strictly greater than rhs9
  lhs2 >> rhs10; // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs10
  lhs2 >> rhs11; // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs11
  lhs2 >> rhs12; // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs12
  lhs2 >> rhs13; // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs13
  lhs2 >> rhs14; // NON_COMPLIANT: lhs2's precision is not strictly greater than
                 // rhs14
  lhs3 >> rhs0;  // COMPLIANT: lhs3's precision is strictly greater than rhs0
  lhs3 >> rhs1;  // COMPLIANT: lhs3's precision is strictly greater than rhs1
  lhs3 >> rhs2;  // COMPLIANT: lhs3's precision is strictly greater than rhs2
  lhs3 >>
      rhs3; // NON_COMPLIANT: lhs3's precision is not strictly greater than rhs3
  lhs3 >> rhs4; // COMPLIANT: lhs3's precision is strictly greater than rhs4
  lhs3 >> rhs5; // COMPLIANT: lhs3's precision is strictly greater than rhs5
  lhs3 >>
      rhs6; // NON_COMPLIANT: lhs3's precision is not strictly greater than rhs6
  lhs3 >>
      rhs7; // NON_COMPLIANT: lhs3's precision is not strictly greater than rhs7
  lhs3 >>
      rhs8; // NON_COMPLIANT: lhs3's precision is not strictly greater than rhs8
  lhs3 >>
      rhs9; // NON_COMPLIANT: lhs3's precision is not strictly greater than rhs9
  lhs3 >> rhs10; // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs10
  lhs3 >> rhs11; // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs11
  lhs3 >> rhs12; // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs12
  lhs3 >> rhs13; // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs13
  lhs3 >> rhs14; // NON_COMPLIANT: lhs3's precision is not strictly greater than
                 // rhs14
  lhs4 >> rhs0;  // COMPLIANT: lhs4's precision is strictly greater than rhs0
  lhs4 >> rhs1;  // COMPLIANT: lhs4's precision is strictly greater than rhs1
  lhs4 >> rhs2;  // COMPLIANT: lhs4's precision is strictly greater than rhs2
  lhs4 >>
      rhs3; // NON_COMPLIANT: lhs4's precision is not strictly greater than rhs3
  lhs4 >>
      rhs4; // NON_COMPLIANT: lhs4's precision is not strictly greater than rhs4
  lhs4 >>
      rhs5; // NON_COMPLIANT: lhs4's precision is not strictly greater than rhs5
  lhs4 >>
      rhs6; // NON_COMPLIANT: lhs4's precision is not strictly greater than rhs6
  lhs4 >>
      rhs7; // NON_COMPLIANT: lhs4's precision is not strictly greater than rhs7
  lhs4 >>
      rhs8; // NON_COMPLIANT: lhs4's precision is not strictly greater than rhs8
  lhs4 >>
      rhs9; // NON_COMPLIANT: lhs4's precision is not strictly greater than rhs9
  lhs4 >> rhs10; // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs10
  lhs4 >> rhs11; // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs11
  lhs4 >> rhs12; // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs12
  lhs4 >> rhs13; // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs13
  lhs4 >> rhs14; // NON_COMPLIANT: lhs4's precision is not strictly greater than
                 // rhs14
  lhs5 >> rhs0;  // COMPLIANT: lhs5's precision is strictly greater than rhs0
  lhs5 >> rhs1;  // COMPLIANT: lhs5's precision is strictly greater than rhs1
  lhs5 >> rhs2;  // COMPLIANT: lhs5's precision is strictly greater than rhs2
  lhs5 >>
      rhs3; // NON_COMPLIANT: lhs5's precision is not strictly greater than rhs3
  lhs5 >>
      rhs4; // NON_COMPLIANT: lhs5's precision is not strictly greater than rhs4
  lhs5 >>
      rhs5; // NON_COMPLIANT: lhs5's precision is not strictly greater than rhs5
  lhs5 >>
      rhs6; // NON_COMPLIANT: lhs5's precision is not strictly greater than rhs6
  lhs5 >>
      rhs7; // NON_COMPLIANT: lhs5's precision is not strictly greater than rhs7
  lhs5 >>
      rhs8; // NON_COMPLIANT: lhs5's precision is not strictly greater than rhs8
  lhs5 >>
      rhs9; // NON_COMPLIANT: lhs5's precision is not strictly greater than rhs9
  lhs5 >> rhs10; // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs10
  lhs5 >> rhs11; // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs11
  lhs5 >> rhs12; // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs12
  lhs5 >> rhs13; // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs13
  lhs5 >> rhs14; // NON_COMPLIANT: lhs5's precision is not strictly greater than
                 // rhs14
  lhs6 >> rhs0;  // COMPLIANT: lhs6's precision is strictly greater than rhs0
  lhs6 >> rhs1;  // COMPLIANT: lhs6's precision is strictly greater than rhs1
  lhs6 >> rhs2;  // COMPLIANT: lhs6's precision is strictly greater than rhs2
  lhs6 >> rhs3;  // COMPLIANT: lhs6's precision is strictly greater than rhs3
  lhs6 >> rhs4;  // COMPLIANT: lhs6's precision is strictly greater than rhs4
  lhs6 >> rhs5;  // COMPLIANT: lhs6's precision is strictly greater than rhs5
  lhs6 >>
      rhs6; // NON_COMPLIANT: lhs6's precision is not strictly greater than rhs6
  lhs6 >> rhs7; // COMPLIANT: lhs6's precision is strictly greater than rhs7
  lhs6 >> rhs8; // COMPLIANT: lhs6's precision is strictly greater than rhs8
  lhs6 >>
      rhs9; // NON_COMPLIANT: lhs6's precision is not strictly greater than rhs9
  lhs6 >> rhs10; // COMPLIANT: lhs6's precision is strictly greater than rhs10
  lhs6 >> rhs11; // COMPLIANT: lhs6's precision is strictly greater than rhs11
  lhs6 >> rhs12; // NON_COMPLIANT: lhs6's precision is not strictly greater than
                 // rhs12
  lhs6 >> rhs13; // NON_COMPLIANT: lhs6's precision is not strictly greater than
                 // rhs13
  lhs6 >> rhs14; // NON_COMPLIANT: lhs6's precision is not strictly greater than
                 // rhs14
  lhs7 >> rhs0;  // COMPLIANT: lhs7's precision is strictly greater than rhs0
  lhs7 >> rhs1;  // COMPLIANT: lhs7's precision is strictly greater than rhs1
  lhs7 >> rhs2;  // COMPLIANT: lhs7's precision is strictly greater than rhs2
  lhs7 >> rhs3;  // COMPLIANT: lhs7's precision is strictly greater than rhs3
  lhs7 >> rhs4;  // COMPLIANT: lhs7's precision is strictly greater than rhs4
  lhs7 >> rhs5;  // COMPLIANT: lhs7's precision is strictly greater than rhs5
  lhs7 >>
      rhs6; // NON_COMPLIANT: lhs7's precision is not strictly greater than rhs6
  lhs7 >>
      rhs7; // NON_COMPLIANT: lhs7's precision is not strictly greater than rhs7
  lhs7 >>
      rhs8; // NON_COMPLIANT: lhs7's precision is not strictly greater than rhs8
  lhs7 >>
      rhs9; // NON_COMPLIANT: lhs7's precision is not strictly greater than rhs9
  lhs7 >> rhs10; // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs10
  lhs7 >> rhs11; // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs11
  lhs7 >> rhs12; // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs12
  lhs7 >> rhs13; // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs13
  lhs7 >> rhs14; // NON_COMPLIANT: lhs7's precision is not strictly greater than
                 // rhs14
  lhs8 >> rhs0;  // COMPLIANT: lhs8's precision is strictly greater than rhs0
  lhs8 >> rhs1;  // COMPLIANT: lhs8's precision is strictly greater than rhs1
  lhs8 >> rhs2;  // COMPLIANT: lhs8's precision is strictly greater than rhs2
  lhs8 >> rhs3;  // COMPLIANT: lhs8's precision is strictly greater than rhs3
  lhs8 >> rhs4;  // COMPLIANT: lhs8's precision is strictly greater than rhs4
  lhs8 >> rhs5;  // COMPLIANT: lhs8's precision is strictly greater than rhs5
  lhs8 >>
      rhs6; // NON_COMPLIANT: lhs8's precision is not strictly greater than rhs6
  lhs8 >>
      rhs7; // NON_COMPLIANT: lhs8's precision is not strictly greater than rhs7
  lhs8 >>
      rhs8; // NON_COMPLIANT: lhs8's precision is not strictly greater than rhs8
  lhs8 >>
      rhs9; // NON_COMPLIANT: lhs8's precision is not strictly greater than rhs9
  lhs8 >> rhs10; // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs10
  lhs8 >> rhs11; // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs11
  lhs8 >> rhs12; // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs12
  lhs8 >> rhs13; // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs13
  lhs8 >> rhs14; // NON_COMPLIANT: lhs8's precision is not strictly greater than
                 // rhs14
  lhs9 >> rhs0;  // COMPLIANT: lhs9's precision is strictly greater than rhs0
  lhs9 >> rhs1;  // COMPLIANT: lhs9's precision is strictly greater than rhs1
  lhs9 >> rhs2;  // COMPLIANT: lhs9's precision is strictly greater than rhs2
  lhs9 >> rhs3;  // COMPLIANT: lhs9's precision is strictly greater than rhs3
  lhs9 >> rhs4;  // COMPLIANT: lhs9's precision is strictly greater than rhs4
  lhs9 >> rhs5;  // COMPLIANT: lhs9's precision is strictly greater than rhs5
  lhs9 >>
      rhs6; // NON_COMPLIANT: lhs9's precision is not strictly greater than rhs6
  lhs9 >> rhs7; // COMPLIANT: lhs9's precision is strictly greater than rhs7
  lhs9 >> rhs8; // COMPLIANT: lhs9's precision is strictly greater than rhs8
  lhs9 >>
      rhs9; // NON_COMPLIANT: lhs9's precision is not strictly greater than rhs9
  lhs9 >> rhs10; // COMPLIANT: lhs9's precision is strictly greater than rhs10
  lhs9 >> rhs11; // COMPLIANT: lhs9's precision is strictly greater than rhs11
  lhs9 >> rhs12; // NON_COMPLIANT: lhs9's precision is not strictly greater than
                 // rhs12
  lhs9 >> rhs13; // NON_COMPLIANT: lhs9's precision is not strictly greater than
                 // rhs13
  lhs9 >> rhs14; // NON_COMPLIANT: lhs9's precision is not strictly greater than
                 // rhs14
  lhs10 >> rhs0; // COMPLIANT: lhs10's precision is strictly greater than rhs0
  lhs10 >> rhs1; // COMPLIANT: lhs10's precision is strictly greater than rhs1
  lhs10 >> rhs2; // COMPLIANT: lhs10's precision is strictly greater than rhs2
  lhs10 >> rhs3; // COMPLIANT: lhs10's precision is strictly greater than rhs3
  lhs10 >> rhs4; // COMPLIANT: lhs10's precision is strictly greater than rhs4
  lhs10 >> rhs5; // COMPLIANT: lhs10's precision is strictly greater than rhs5
  lhs10 >> rhs6; // NON_COMPLIANT: lhs10's precision is not strictly greater
                 // than rhs6
  lhs10 >> rhs7; // NON_COMPLIANT: lhs10's precision is not strictly greater
                 // than rhs7
  lhs10 >> rhs8; // NON_COMPLIANT: lhs10's precision is not strictly greater
                 // than rhs8
  lhs10 >> rhs9; // NON_COMPLIANT: lhs10's precision is not strictly greater
                 // than rhs9
  lhs10 >> rhs10; // NON_COMPLIANT: lhs10's precision is not strictly greater
                  // than rhs10
  lhs10 >> rhs11; // NON_COMPLIANT: lhs10's precision is not strictly greater
                  // than rhs11
  lhs10 >> rhs12; // NON_COMPLIANT: lhs10's precision is not strictly greater
                  // than rhs12
  lhs10 >> rhs13; // NON_COMPLIANT: lhs10's precision is not strictly greater
                  // than rhs13
  lhs10 >> rhs14; // NON_COMPLIANT: lhs10's precision is not strictly greater
                  // than rhs14
  lhs11 >> rhs0;  // COMPLIANT: lhs11's precision is strictly greater than rhs0
  lhs11 >> rhs1;  // COMPLIANT: lhs11's precision is strictly greater than rhs1
  lhs11 >> rhs2;  // COMPLIANT: lhs11's precision is strictly greater than rhs2
  lhs11 >> rhs3;  // COMPLIANT: lhs11's precision is strictly greater than rhs3
  lhs11 >> rhs4;  // COMPLIANT: lhs11's precision is strictly greater than rhs4
  lhs11 >> rhs5;  // COMPLIANT: lhs11's precision is strictly greater than rhs5
  lhs11 >> rhs6;  // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs6
  lhs11 >> rhs7;  // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs7
  lhs11 >> rhs8;  // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs8
  lhs11 >> rhs9;  // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs9
  lhs11 >> rhs10; // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs10
  lhs11 >> rhs11; // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs11
  lhs11 >> rhs12; // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs12
  lhs11 >> rhs13; // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs13
  lhs11 >> rhs14; // NON_COMPLIANT: lhs11's precision is not strictly greater
                  // than rhs14
  lhs12 >> rhs0;  // COMPLIANT: lhs12's precision is strictly greater than rhs0
  lhs12 >> rhs1;  // COMPLIANT: lhs12's precision is strictly greater than rhs1
  lhs12 >> rhs2;  // COMPLIANT: lhs12's precision is strictly greater than rhs2
  lhs12 >> rhs3;  // COMPLIANT: lhs12's precision is strictly greater than rhs3
  lhs12 >> rhs4;  // COMPLIANT: lhs12's precision is strictly greater than rhs4
  lhs12 >> rhs5;  // COMPLIANT: lhs12's precision is strictly greater than rhs5
  lhs12 >> rhs6;  // COMPLIANT: lhs12's precision is strictly greater than rhs6
  lhs12 >> rhs7;  // COMPLIANT: lhs12's precision is strictly greater than rhs7
  lhs12 >> rhs8;  // COMPLIANT: lhs12's precision is strictly greater than rhs8
  lhs12 >> rhs9;  // COMPLIANT: lhs12's precision is strictly greater than rhs9
  lhs12 >> rhs10; // COMPLIANT: lhs12's precision is strictly greater than rhs10
  lhs12 >> rhs11; // COMPLIANT: lhs12's precision is strictly greater than rhs11
  lhs12 >> rhs12; // NON_COMPLIANT: lhs12's precision is not strictly greater
                  // than rhs12
  lhs12 >> rhs13; // COMPLIANT: lhs12's precision is strictly greater than rhs13
  lhs12 >> rhs14; // COMPLIANT: lhs12's precision is strictly greater than rhs14
  lhs13 >> rhs0;  // COMPLIANT: lhs13's precision is strictly greater than rhs0
  lhs13 >> rhs1;  // COMPLIANT: lhs13's precision is strictly greater than rhs1
  lhs13 >> rhs2;  // COMPLIANT: lhs13's precision is strictly greater than rhs2
  lhs13 >> rhs3;  // COMPLIANT: lhs13's precision is strictly greater than rhs3
  lhs13 >> rhs4;  // COMPLIANT: lhs13's precision is strictly greater than rhs4
  lhs13 >> rhs5;  // COMPLIANT: lhs13's precision is strictly greater than rhs5
  lhs13 >> rhs6;  // COMPLIANT: lhs13's precision is strictly greater than rhs6
  lhs13 >> rhs7;  // COMPLIANT: lhs13's precision is strictly greater than rhs7
  lhs13 >> rhs8;  // COMPLIANT: lhs13's precision is strictly greater than rhs8
  lhs13 >> rhs9;  // COMPLIANT: lhs13's precision is strictly greater than rhs9
  lhs13 >> rhs10; // COMPLIANT: lhs13's precision is strictly greater than rhs10
  lhs13 >> rhs11; // COMPLIANT: lhs13's precision is strictly greater than rhs11
  lhs13 >> rhs12; // NON_COMPLIANT: lhs13's precision is not strictly greater
                  // than rhs12
  lhs13 >> rhs13; // NON_COMPLIANT: lhs13's precision is not strictly greater
                  // than rhs13
  lhs13 >> rhs14; // NON_COMPLIANT: lhs13's precision is not strictly greater
                  // than rhs14
  lhs14 >> rhs0;  // COMPLIANT: lhs14's precision is strictly greater than rhs0
  lhs14 >> rhs1;  // COMPLIANT: lhs14's precision is strictly greater than rhs1
  lhs14 >> rhs2;  // COMPLIANT: lhs14's precision is strictly greater than rhs2
  lhs14 >> rhs3;  // COMPLIANT: lhs14's precision is strictly greater than rhs3
  lhs14 >> rhs4;  // COMPLIANT: lhs14's precision is strictly greater than rhs4
  lhs14 >> rhs5;  // COMPLIANT: lhs14's precision is strictly greater than rhs5
  lhs14 >> rhs6;  // COMPLIANT: lhs14's precision is strictly greater than rhs6
  lhs14 >> rhs7;  // COMPLIANT: lhs14's precision is strictly greater than rhs7
  lhs14 >> rhs8;  // COMPLIANT: lhs14's precision is strictly greater than rhs8
  lhs14 >> rhs9;  // COMPLIANT: lhs14's precision is strictly greater than rhs9
  lhs14 >> rhs10; // COMPLIANT: lhs14's precision is strictly greater than rhs10
  lhs14 >> rhs11; // COMPLIANT: lhs14's precision is strictly greater than rhs11
  lhs14 >> rhs12; // NON_COMPLIANT: lhs14's precision is not strictly greater
                  // than rhs12
  lhs14 >> rhs13; // NON_COMPLIANT: lhs14's precision is not strictly greater
                  // than rhs13
  lhs14 >> rhs14; // NON_COMPLIANT: lhs14's precision is not strictly greater
                  // than rhs14

  /* ===== Right shift with guards, the shift expression is at `then` branch
   * ===== */

  if (rhs0 < PRECISION(UCHAR_MAX))
    lhs0 >> rhs0; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs0, but it's inside a PRECISION guard
  if (rhs3 < PRECISION(UCHAR_MAX))
    lhs0 >> rhs3; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  if (rhs4 < PRECISION(UCHAR_MAX))
    lhs0 >> rhs4; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  if (rhs5 < PRECISION(UCHAR_MAX))
    lhs0 >> rhs5; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(UCHAR_MAX))
    lhs0 >> rhs6; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(UCHAR_MAX))
    lhs0 >> rhs7; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(UCHAR_MAX))
    lhs0 >> rhs8; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(UCHAR_MAX))
    lhs0 >> rhs9; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(UCHAR_MAX))
    lhs0 >> rhs10; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(UCHAR_MAX))
    lhs0 >> rhs11; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(UCHAR_MAX))
    lhs0 >> rhs12; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(UCHAR_MAX))
    lhs0 >> rhs13; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(UCHAR_MAX))
    lhs0 >> rhs14; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs0 < PRECISION(CHAR_MAX))
    lhs1 >> rhs0; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs0, but it's inside a PRECISION guard
  if (rhs1 < PRECISION(CHAR_MAX))
    lhs1 >> rhs1; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs1, but it's inside a PRECISION guard
  if (rhs2 < PRECISION(CHAR_MAX))
    lhs1 >> rhs2; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs2, but it's inside a PRECISION guard
  if (rhs3 < PRECISION(CHAR_MAX))
    lhs1 >> rhs3; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  if (rhs4 < PRECISION(CHAR_MAX))
    lhs1 >> rhs4; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  if (rhs5 < PRECISION(CHAR_MAX))
    lhs1 >> rhs5; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(CHAR_MAX))
    lhs1 >> rhs6; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(CHAR_MAX))
    lhs1 >> rhs7; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(CHAR_MAX))
    lhs1 >> rhs8; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(CHAR_MAX))
    lhs1 >> rhs9; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(CHAR_MAX))
    lhs1 >> rhs10; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(CHAR_MAX))
    lhs1 >> rhs11; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(CHAR_MAX))
    lhs1 >> rhs12; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(CHAR_MAX))
    lhs1 >> rhs13; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(CHAR_MAX))
    lhs1 >> rhs14; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs0 < PRECISION(CHAR_MAX))
    lhs2 >> rhs0; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs0, but it's inside a PRECISION guard
  if (rhs1 < PRECISION(CHAR_MAX))
    lhs2 >> rhs1; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs1, but it's inside a PRECISION guard
  if (rhs2 < PRECISION(CHAR_MAX))
    lhs2 >> rhs2; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs2, but it's inside a PRECISION guard
  if (rhs3 < PRECISION(CHAR_MAX))
    lhs2 >> rhs3; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  if (rhs4 < PRECISION(CHAR_MAX))
    lhs2 >> rhs4; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  if (rhs5 < PRECISION(CHAR_MAX))
    lhs2 >> rhs5; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(CHAR_MAX))
    lhs2 >> rhs6; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(CHAR_MAX))
    lhs2 >> rhs7; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(CHAR_MAX))
    lhs2 >> rhs8; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(CHAR_MAX))
    lhs2 >> rhs9; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(CHAR_MAX))
    lhs2 >> rhs10; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(CHAR_MAX))
    lhs2 >> rhs11; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(CHAR_MAX))
    lhs2 >> rhs12; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(CHAR_MAX))
    lhs2 >> rhs13; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(CHAR_MAX))
    lhs2 >> rhs14; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs3 < PRECISION(USHRT_MAX))
    lhs3 >> rhs3; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(USHRT_MAX))
    lhs3 >> rhs6; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(USHRT_MAX))
    lhs3 >> rhs7; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(USHRT_MAX))
    lhs3 >> rhs8; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(USHRT_MAX))
    lhs3 >> rhs9; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(USHRT_MAX))
    lhs3 >> rhs10; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(USHRT_MAX))
    lhs3 >> rhs11; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(USHRT_MAX))
    lhs3 >> rhs12; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(USHRT_MAX))
    lhs3 >> rhs13; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(USHRT_MAX))
    lhs3 >> rhs14; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs3 < PRECISION(SHRT_MAX))
    lhs4 >> rhs3; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  if (rhs4 < PRECISION(SHRT_MAX))
    lhs4 >> rhs4; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  if (rhs5 < PRECISION(SHRT_MAX))
    lhs4 >> rhs5; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(SHRT_MAX))
    lhs4 >> rhs6; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(SHRT_MAX))
    lhs4 >> rhs7; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(SHRT_MAX))
    lhs4 >> rhs8; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(SHRT_MAX))
    lhs4 >> rhs9; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(SHRT_MAX))
    lhs4 >> rhs10; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(SHRT_MAX))
    lhs4 >> rhs11; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(SHRT_MAX))
    lhs4 >> rhs12; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(SHRT_MAX))
    lhs4 >> rhs13; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(SHRT_MAX))
    lhs4 >> rhs14; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs3 < PRECISION(SHRT_MAX))
    lhs5 >> rhs3; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  if (rhs4 < PRECISION(SHRT_MAX))
    lhs5 >> rhs4; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  if (rhs5 < PRECISION(SHRT_MAX))
    lhs5 >> rhs5; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(SHRT_MAX))
    lhs5 >> rhs6; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(SHRT_MAX))
    lhs5 >> rhs7; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(SHRT_MAX))
    lhs5 >> rhs8; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(SHRT_MAX))
    lhs5 >> rhs9; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(SHRT_MAX))
    lhs5 >> rhs10; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(SHRT_MAX))
    lhs5 >> rhs11; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(SHRT_MAX))
    lhs5 >> rhs12; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(SHRT_MAX))
    lhs5 >> rhs13; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(SHRT_MAX))
    lhs5 >> rhs14; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(UINT_MAX))
    lhs6 >> rhs6; // COMPLIANT: lhs6's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(UINT_MAX))
    lhs6 >> rhs9; // COMPLIANT: lhs6's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(UINT_MAX))
    lhs6 >> rhs12; // COMPLIANT: lhs6's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(UINT_MAX))
    lhs6 >> rhs13; // COMPLIANT: lhs6's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(UINT_MAX))
    lhs6 >> rhs14; // COMPLIANT: lhs6's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(INT_MAX))
    lhs7 >> rhs6; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(INT_MAX))
    lhs7 >> rhs7; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(INT_MAX))
    lhs7 >> rhs8; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(INT_MAX))
    lhs7 >> rhs9; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(INT_MAX))
    lhs7 >> rhs10; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(INT_MAX))
    lhs7 >> rhs11; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(INT_MAX))
    lhs7 >> rhs12; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(INT_MAX))
    lhs7 >> rhs13; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(INT_MAX))
    lhs7 >> rhs14; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(INT_MAX))
    lhs8 >> rhs6; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(INT_MAX))
    lhs8 >> rhs7; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(INT_MAX))
    lhs8 >> rhs8; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(INT_MAX))
    lhs8 >> rhs9; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(INT_MAX))
    lhs8 >> rhs10; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(INT_MAX))
    lhs8 >> rhs11; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(INT_MAX))
    lhs8 >> rhs12; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(INT_MAX))
    lhs8 >> rhs13; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(INT_MAX))
    lhs8 >> rhs14; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(ULONG_MAX))
    lhs9 >> rhs6; // COMPLIANT: lhs9's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(ULONG_MAX))
    lhs9 >> rhs9; // COMPLIANT: lhs9's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(ULONG_MAX))
    lhs9 >> rhs12; // COMPLIANT: lhs9's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(ULONG_MAX))
    lhs9 >> rhs13; // COMPLIANT: lhs9's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(ULONG_MAX))
    lhs9 >> rhs14; // COMPLIANT: lhs9's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(LONG_MAX))
    lhs10 >> rhs6; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(LONG_MAX))
    lhs10 >> rhs7; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(LONG_MAX))
    lhs10 >> rhs8; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(LONG_MAX))
    lhs10 >> rhs9; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(LONG_MAX))
    lhs10 >> rhs10; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(LONG_MAX))
    lhs10 >> rhs11; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(LONG_MAX))
    lhs10 >> rhs12; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(LONG_MAX))
    lhs10 >> rhs13; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(LONG_MAX))
    lhs10 >> rhs14; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  if (rhs6 < PRECISION(LONG_MAX))
    lhs11 >> rhs6; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs6, but it's inside a PRECISION guard
  if (rhs7 < PRECISION(LONG_MAX))
    lhs11 >> rhs7; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs7, but it's inside a PRECISION guard
  if (rhs8 < PRECISION(LONG_MAX))
    lhs11 >> rhs8; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs8, but it's inside a PRECISION guard
  if (rhs9 < PRECISION(LONG_MAX))
    lhs11 >> rhs9; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs9, but it's inside a PRECISION guard
  if (rhs10 < PRECISION(LONG_MAX))
    lhs11 >> rhs10; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs10, but it's inside a PRECISION guard
  if (rhs11 < PRECISION(LONG_MAX))
    lhs11 >> rhs11; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs11, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(LONG_MAX))
    lhs11 >> rhs12; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(LONG_MAX))
    lhs11 >> rhs13; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(LONG_MAX))
    lhs11 >> rhs14; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(ULLONG_MAX))
    lhs12 >> rhs12; // COMPLIANT: lhs12's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(LLONG_MAX))
    lhs13 >> rhs12; // COMPLIANT: lhs13's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(LLONG_MAX))
    lhs13 >> rhs13; // COMPLIANT: lhs13's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(LLONG_MAX))
    lhs13 >> rhs14; // COMPLIANT: lhs13's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  if (rhs12 < PRECISION(LLONG_MAX))
    lhs14 >> rhs12; // COMPLIANT: lhs14's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  if (rhs13 < PRECISION(LLONG_MAX))
    lhs14 >> rhs13; // COMPLIANT: lhs14's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  if (rhs14 < PRECISION(LLONG_MAX))
    lhs14 >> rhs14; // COMPLIANT: lhs14's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard

  /* ===== Right shift with guards, the shift expression is at `else` branch
   * ===== */

  if (rhs0 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 >> rhs0; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs0, but it's inside a PRECISION guard
  }
  if (rhs3 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 >> rhs3; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  }
  if (rhs4 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 >> rhs4; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  }
  if (rhs5 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 >> rhs5; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 >> rhs6; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 >> rhs7; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 >> rhs8; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 >> rhs9; // COMPLIANT: lhs0's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 >> rhs10; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 >> rhs11; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 >> rhs12; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 >> rhs13; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(UCHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs0 >> rhs14; // COMPLIANT: lhs0's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs0 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs0; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs0, but it's inside a PRECISION guard
  }
  if (rhs1 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs1; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs1, but it's inside a PRECISION guard
  }
  if (rhs2 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs2; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs2, but it's inside a PRECISION guard
  }
  if (rhs3 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs3; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  }
  if (rhs4 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs4; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  }
  if (rhs5 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs5; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs6; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs7; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs8; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs9; // COMPLIANT: lhs1's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs10; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs11; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs12; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs13; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs1 >> rhs14; // COMPLIANT: lhs1's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs0 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs0; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs0, but it's inside a PRECISION guard
  }
  if (rhs1 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs1; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs1, but it's inside a PRECISION guard
  }
  if (rhs2 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs2; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs2, but it's inside a PRECISION guard
  }
  if (rhs3 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs3; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  }
  if (rhs4 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs4; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  }
  if (rhs5 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs5; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs6; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs7; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs8; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs9; // COMPLIANT: lhs2's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs10; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs11; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs12; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs13; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(CHAR_MAX)) {
    ; /* Handle Error */
  } else {
    lhs2 >> rhs14; // COMPLIANT: lhs2's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs3 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 >> rhs3; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 >> rhs6; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 >> rhs7; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 >> rhs8; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 >> rhs9; // COMPLIANT: lhs3's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 >> rhs10; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 >> rhs11; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 >> rhs12; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 >> rhs13; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(USHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs3 >> rhs14; // COMPLIANT: lhs3's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs3 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 >> rhs3; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  }
  if (rhs4 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 >> rhs4; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  }
  if (rhs5 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 >> rhs5; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 >> rhs6; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 >> rhs7; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 >> rhs8; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 >> rhs9; // COMPLIANT: lhs4's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 >> rhs10; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 >> rhs11; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 >> rhs12; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 >> rhs13; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs4 >> rhs14; // COMPLIANT: lhs4's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs3 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 >> rhs3; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs3, but it's inside a PRECISION guard
  }
  if (rhs4 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 >> rhs4; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs4, but it's inside a PRECISION guard
  }
  if (rhs5 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 >> rhs5; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs5, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 >> rhs6; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 >> rhs7; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 >> rhs8; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 >> rhs9; // COMPLIANT: lhs5's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 >> rhs10; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 >> rhs11; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 >> rhs12; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 >> rhs13; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(SHRT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs5 >> rhs14; // COMPLIANT: lhs5's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(UINT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs6 >> rhs6; // COMPLIANT: lhs6's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(UINT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs6 >> rhs9; // COMPLIANT: lhs6's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(UINT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs6 >> rhs12; // COMPLIANT: lhs6's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(UINT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs6 >> rhs13; // COMPLIANT: lhs6's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(UINT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs6 >> rhs14; // COMPLIANT: lhs6's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 >> rhs6; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 >> rhs7; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 >> rhs8; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 >> rhs9; // COMPLIANT: lhs7's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 >> rhs10; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 >> rhs11; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 >> rhs12; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 >> rhs13; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs7 >> rhs14; // COMPLIANT: lhs7's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 >> rhs6; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 >> rhs7; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 >> rhs8; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 >> rhs9; // COMPLIANT: lhs8's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 >> rhs10; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 >> rhs11; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 >> rhs12; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 >> rhs13; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(INT_MAX)) {
    ; /* Handle Error */
  } else {
    lhs8 >> rhs14; // COMPLIANT: lhs8's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(ULONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs9 >> rhs6; // COMPLIANT: lhs9's precision is not strictly greater than
                  // rhs6, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(ULONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs9 >> rhs9; // COMPLIANT: lhs9's precision is not strictly greater than
                  // rhs9, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(ULONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs9 >> rhs12; // COMPLIANT: lhs9's precision is not strictly greater than
                   // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(ULONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs9 >> rhs13; // COMPLIANT: lhs9's precision is not strictly greater than
                   // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(ULONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs9 >> rhs14; // COMPLIANT: lhs9's precision is not strictly greater than
                   // rhs14, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 >> rhs6; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 >> rhs7; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 >> rhs8; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 >> rhs9; // COMPLIANT: lhs10's precision is not strictly greater than
                   // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 >> rhs10; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 >> rhs11; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 >> rhs12; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 >> rhs13; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs10 >> rhs14; // COMPLIANT: lhs10's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  }
  if (rhs6 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 >> rhs6; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs6, but it's inside a PRECISION guard
  }
  if (rhs7 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 >> rhs7; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs7, but it's inside a PRECISION guard
  }
  if (rhs8 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 >> rhs8; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs8, but it's inside a PRECISION guard
  }
  if (rhs9 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 >> rhs9; // COMPLIANT: lhs11's precision is not strictly greater than
                   // rhs9, but it's inside a PRECISION guard
  }
  if (rhs10 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 >> rhs10; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs10, but it's inside a PRECISION guard
  }
  if (rhs11 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 >> rhs11; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs11, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 >> rhs12; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 >> rhs13; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(LONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs11 >> rhs14; // COMPLIANT: lhs11's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(ULLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs12 >> rhs12; // COMPLIANT: lhs12's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(LLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs13 >> rhs12; // COMPLIANT: lhs13's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(LLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs13 >> rhs13; // COMPLIANT: lhs13's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(LLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs13 >> rhs14; // COMPLIANT: lhs13's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  }
  if (rhs12 >= PRECISION(LLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs14 >> rhs12; // COMPLIANT: lhs14's precision is not strictly greater than
                    // rhs12, but it's inside a PRECISION guard
  }
  if (rhs13 >= PRECISION(LLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs14 >> rhs13; // COMPLIANT: lhs14's precision is not strictly greater than
                    // rhs13, but it's inside a PRECISION guard
  }
  if (rhs14 >= PRECISION(LLONG_MAX)) {
    ; /* Handle Error */
  } else {
    lhs14 >> rhs14; // COMPLIANT: lhs14's precision is not strictly greater than
                    // rhs14, but it's inside a PRECISION guard
  }

  /* Negative shifts */

  lhs0 << -1;  // NON_COMPLIANT: shifting by a negative operand
  lhs1 << -1;  // NON_COMPLIANT: shifting by a negative operand
  lhs2 << -1;  // NON_COMPLIANT: shifting by a negative operand
  lhs3 << -1;  // NON_COMPLIANT: shifting by a negative operand
  lhs4 << -1;  // NON_COMPLIANT: shifting by a negative operand
  lhs5 << -1;  // NON_COMPLIANT: shifting by a negative operand
  lhs6 << -1;  // NON_COMPLIANT: shifting by a negative operand
  lhs7 << -1;  // NON_COMPLIANT: shifting by a negative operand
  lhs8 << -1;  // NON_COMPLIANT: shifting by a negative operand
  lhs9 << -1;  // NON_COMPLIANT: shifting by a negative operand
  lhs10 << -1; // NON_COMPLIANT: shifting by a negative operand
  lhs11 << -1; // NON_COMPLIANT: shifting by a negative operand
  lhs12 << -1; // NON_COMPLIANT: shifting by a negative operand
  lhs13 << -1; // NON_COMPLIANT: shifting by a negative operand
  lhs14 << -1; // NON_COMPLIANT: shifting by a negative operand

  return 0;
}
