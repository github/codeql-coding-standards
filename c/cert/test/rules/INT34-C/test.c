int main() {
  unsigned char x0;
  signed char x1;
  char x2;
  unsigned short x3;
  signed short x4;
  short x5;
  unsigned int x6;
  signed int x7;
  int x8;
  unsigned long x9;
  signed long x10;
  long x11;
  unsigned long long x12;
  signed long long x13;
  long long x14;

  /* left shift */

  x0 << x0;  // NON_COMPLIANT: x0's precision is not strictly greater than x0's
  x0 << x1;  // COMPLIANT: x0's precision is strictly greater than x1's
  x0 << x2;  // COMPLIANT: x0's precision is strictly greater than x2's
  x0 << x3;  // NON_COMPLIANT: x0's precision is not strictly greater than x3's
  x0 << x4;  // NON_COMPLIANT: x0's precision is not strictly greater than x4's
  x0 << x5;  // NON_COMPLIANT: x0's precision is not strictly greater than x5's
  x0 << x6;  // NON_COMPLIANT: x0's precision is not strictly greater than x6's
  x0 << x7;  // NON_COMPLIANT: x0's precision is not strictly greater than x7's
  x0 << x8;  // NON_COMPLIANT: x0's precision is not strictly greater than x8's
  x0 << x9;  // NON_COMPLIANT: x0's precision is not strictly greater than x9's
  x0 << x10; // NON_COMPLIANT: x0's precision is not strictly greater than x10's
  x0 << x11; // NON_COMPLIANT: x0's precision is not strictly greater than x11's
  x0 << x12; // NON_COMPLIANT: x0's precision is not strictly greater than x12's
  x0 << x13; // NON_COMPLIANT: x0's precision is not strictly greater than x13's
  x0 << x14; // NON_COMPLIANT: x0's precision is not strictly greater than x14's
  x1 << x0;  // NON_COMPLIANT: x1's precision is not strictly greater than x0's
  x1 << x1;  // NON_COMPLIANT: x1's precision is not strictly greater than x1's
  x1 << x2;  // NON_COMPLIANT: x1's precision is not strictly greater than x2's
  x1 << x3;  // NON_COMPLIANT: x1's precision is not strictly greater than x3's
  x1 << x4;  // NON_COMPLIANT: x1's precision is not strictly greater than x4's
  x1 << x5;  // NON_COMPLIANT: x1's precision is not strictly greater than x5's
  x1 << x6;  // NON_COMPLIANT: x1's precision is not strictly greater than x6's
  x1 << x7;  // NON_COMPLIANT: x1's precision is not strictly greater than x7's
  x1 << x8;  // NON_COMPLIANT: x1's precision is not strictly greater than x8's
  x1 << x9;  // NON_COMPLIANT: x1's precision is not strictly greater than x9's
  x1 << x10; // NON_COMPLIANT: x1's precision is not strictly greater than x10's
  x1 << x11; // NON_COMPLIANT: x1's precision is not strictly greater than x11's
  x1 << x12; // NON_COMPLIANT: x1's precision is not strictly greater than x12's
  x1 << x13; // NON_COMPLIANT: x1's precision is not strictly greater than x13's
  x1 << x14; // NON_COMPLIANT: x1's precision is not strictly greater than x14's
  x2 << x0;  // NON_COMPLIANT: x2's precision is not strictly greater than x0's
  x2 << x1;  // NON_COMPLIANT: x2's precision is not strictly greater than x1's
  x2 << x2;  // NON_COMPLIANT: x2's precision is not strictly greater than x2's
  x2 << x3;  // NON_COMPLIANT: x2's precision is not strictly greater than x3's
  x2 << x4;  // NON_COMPLIANT: x2's precision is not strictly greater than x4's
  x2 << x5;  // NON_COMPLIANT: x2's precision is not strictly greater than x5's
  x2 << x6;  // NON_COMPLIANT: x2's precision is not strictly greater than x6's
  x2 << x7;  // NON_COMPLIANT: x2's precision is not strictly greater than x7's
  x2 << x8;  // NON_COMPLIANT: x2's precision is not strictly greater than x8's
  x2 << x9;  // NON_COMPLIANT: x2's precision is not strictly greater than x9's
  x2 << x10; // NON_COMPLIANT: x2's precision is not strictly greater than x10's
  x2 << x11; // NON_COMPLIANT: x2's precision is not strictly greater than x11's
  x2 << x12; // NON_COMPLIANT: x2's precision is not strictly greater than x12's
  x2 << x13; // NON_COMPLIANT: x2's precision is not strictly greater than x13's
  x2 << x14; // NON_COMPLIANT: x2's precision is not strictly greater than x14's
  x3 << x0;  // COMPLIANT: x3's precision is strictly greater than x0's
  x3 << x1;  // COMPLIANT: x3's precision is strictly greater than x1's
  x3 << x2;  // COMPLIANT: x3's precision is strictly greater than x2's
  x3 << x3;  // NON_COMPLIANT: x3's precision is not strictly greater than x3's
  x3 << x4;  // COMPLIANT: x3's precision is strictly greater than x4's
  x3 << x5;  // COMPLIANT: x3's precision is strictly greater than x5's
  x3 << x6;  // NON_COMPLIANT: x3's precision is not strictly greater than x6's
  x3 << x7;  // NON_COMPLIANT: x3's precision is not strictly greater than x7's
  x3 << x8;  // NON_COMPLIANT: x3's precision is not strictly greater than x8's
  x3 << x9;  // NON_COMPLIANT: x3's precision is not strictly greater than x9's
  x3 << x10; // NON_COMPLIANT: x3's precision is not strictly greater than x10's
  x3 << x11; // NON_COMPLIANT: x3's precision is not strictly greater than x11's
  x3 << x12; // NON_COMPLIANT: x3's precision is not strictly greater than x12's
  x3 << x13; // NON_COMPLIANT: x3's precision is not strictly greater than x13's
  x3 << x14; // NON_COMPLIANT: x3's precision is not strictly greater than x14's
  x4 << x0;  // COMPLIANT: x4's precision is strictly greater than x0's
  x4 << x1;  // COMPLIANT: x4's precision is strictly greater than x1's
  x4 << x2;  // COMPLIANT: x4's precision is strictly greater than x2's
  x4 << x3;  // NON_COMPLIANT: x4's precision is not strictly greater than x3's
  x4 << x4;  // NON_COMPLIANT: x4's precision is not strictly greater than x4's
  x4 << x5;  // NON_COMPLIANT: x4's precision is not strictly greater than x5's
  x4 << x6;  // NON_COMPLIANT: x4's precision is not strictly greater than x6's
  x4 << x7;  // NON_COMPLIANT: x4's precision is not strictly greater than x7's
  x4 << x8;  // NON_COMPLIANT: x4's precision is not strictly greater than x8's
  x4 << x9;  // NON_COMPLIANT: x4's precision is not strictly greater than x9's
  x4 << x10; // NON_COMPLIANT: x4's precision is not strictly greater than x10's
  x4 << x11; // NON_COMPLIANT: x4's precision is not strictly greater than x11's
  x4 << x12; // NON_COMPLIANT: x4's precision is not strictly greater than x12's
  x4 << x13; // NON_COMPLIANT: x4's precision is not strictly greater than x13's
  x4 << x14; // NON_COMPLIANT: x4's precision is not strictly greater than x14's
  x5 << x0;  // COMPLIANT: x5's precision is strictly greater than x0's
  x5 << x1;  // COMPLIANT: x5's precision is strictly greater than x1's
  x5 << x2;  // COMPLIANT: x5's precision is strictly greater than x2's
  x5 << x3;  // NON_COMPLIANT: x5's precision is not strictly greater than x3's
  x5 << x4;  // NON_COMPLIANT: x5's precision is not strictly greater than x4's
  x5 << x5;  // NON_COMPLIANT: x5's precision is not strictly greater than x5's
  x5 << x6;  // NON_COMPLIANT: x5's precision is not strictly greater than x6's
  x5 << x7;  // NON_COMPLIANT: x5's precision is not strictly greater than x7's
  x5 << x8;  // NON_COMPLIANT: x5's precision is not strictly greater than x8's
  x5 << x9;  // NON_COMPLIANT: x5's precision is not strictly greater than x9's
  x5 << x10; // NON_COMPLIANT: x5's precision is not strictly greater than x10's
  x5 << x11; // NON_COMPLIANT: x5's precision is not strictly greater than x11's
  x5 << x12; // NON_COMPLIANT: x5's precision is not strictly greater than x12's
  x5 << x13; // NON_COMPLIANT: x5's precision is not strictly greater than x13's
  x5 << x14; // NON_COMPLIANT: x5's precision is not strictly greater than x14's
  x6 << x0;  // COMPLIANT: x6's precision is strictly greater than x0's
  x6 << x1;  // COMPLIANT: x6's precision is strictly greater than x1's
  x6 << x2;  // COMPLIANT: x6's precision is strictly greater than x2's
  x6 << x3;  // COMPLIANT: x6's precision is strictly greater than x3's
  x6 << x4;  // COMPLIANT: x6's precision is strictly greater than x4's
  x6 << x5;  // COMPLIANT: x6's precision is strictly greater than x5's
  x6 << x6;  // NON_COMPLIANT: x6's precision is not strictly greater than x6's
  x6 << x7;  // COMPLIANT: x6's precision is strictly greater than x7's
  x6 << x8;  // COMPLIANT: x6's precision is strictly greater than x8's
  x6 << x9;  // NON_COMPLIANT: x6's precision is not strictly greater than x9's
  x6 << x10; // COMPLIANT: x6's precision is strictly greater than x10's
  x6 << x11; // COMPLIANT: x6's precision is strictly greater than x11's
  x6 << x12; // NON_COMPLIANT: x6's precision is not strictly greater than x12's
  x6 << x13; // NON_COMPLIANT: x6's precision is not strictly greater than x13's
  x6 << x14; // NON_COMPLIANT: x6's precision is not strictly greater than x14's
  x7 << x0;  // COMPLIANT: x7's precision is strictly greater than x0's
  x7 << x1;  // COMPLIANT: x7's precision is strictly greater than x1's
  x7 << x2;  // COMPLIANT: x7's precision is strictly greater than x2's
  x7 << x3;  // COMPLIANT: x7's precision is strictly greater than x3's
  x7 << x4;  // COMPLIANT: x7's precision is strictly greater than x4's
  x7 << x5;  // COMPLIANT: x7's precision is strictly greater than x5's
  x7 << x6;  // NON_COMPLIANT: x7's precision is not strictly greater than x6's
  x7 << x7;  // NON_COMPLIANT: x7's precision is not strictly greater than x7's
  x7 << x8;  // NON_COMPLIANT: x7's precision is not strictly greater than x8's
  x7 << x9;  // NON_COMPLIANT: x7's precision is not strictly greater than x9's
  x7 << x10; // NON_COMPLIANT: x7's precision is not strictly greater than x10's
  x7 << x11; // NON_COMPLIANT: x7's precision is not strictly greater than x11's
  x7 << x12; // NON_COMPLIANT: x7's precision is not strictly greater than x12's
  x7 << x13; // NON_COMPLIANT: x7's precision is not strictly greater than x13's
  x7 << x14; // NON_COMPLIANT: x7's precision is not strictly greater than x14's
  x8 << x0;  // COMPLIANT: x8's precision is strictly greater than x0's
  x8 << x1;  // COMPLIANT: x8's precision is strictly greater than x1's
  x8 << x2;  // COMPLIANT: x8's precision is strictly greater than x2's
  x8 << x3;  // COMPLIANT: x8's precision is strictly greater than x3's
  x8 << x4;  // COMPLIANT: x8's precision is strictly greater than x4's
  x8 << x5;  // COMPLIANT: x8's precision is strictly greater than x5's
  x8 << x6;  // NON_COMPLIANT: x8's precision is not strictly greater than x6's
  x8 << x7;  // NON_COMPLIANT: x8's precision is not strictly greater than x7's
  x8 << x8;  // NON_COMPLIANT: x8's precision is not strictly greater than x8's
  x8 << x9;  // NON_COMPLIANT: x8's precision is not strictly greater than x9's
  x8 << x10; // NON_COMPLIANT: x8's precision is not strictly greater than x10's
  x8 << x11; // NON_COMPLIANT: x8's precision is not strictly greater than x11's
  x8 << x12; // NON_COMPLIANT: x8's precision is not strictly greater than x12's
  x8 << x13; // NON_COMPLIANT: x8's precision is not strictly greater than x13's
  x8 << x14; // NON_COMPLIANT: x8's precision is not strictly greater than x14's
  x9 << x0;  // COMPLIANT: x9's precision is strictly greater than x0's
  x9 << x1;  // COMPLIANT: x9's precision is strictly greater than x1's
  x9 << x2;  // COMPLIANT: x9's precision is strictly greater than x2's
  x9 << x3;  // COMPLIANT: x9's precision is strictly greater than x3's
  x9 << x4;  // COMPLIANT: x9's precision is strictly greater than x4's
  x9 << x5;  // COMPLIANT: x9's precision is strictly greater than x5's
  x9 << x6;  // NON_COMPLIANT: x9's precision is not strictly greater than x6's
  x9 << x7;  // COMPLIANT: x9's precision is strictly greater than x7's
  x9 << x8;  // COMPLIANT: x9's precision is strictly greater than x8's
  x9 << x9;  // NON_COMPLIANT: x9's precision is not strictly greater than x9's
  x9 << x10; // COMPLIANT: x9's precision is strictly greater than x10's
  x9 << x11; // COMPLIANT: x9's precision is strictly greater than x11's
  x9 << x12; // NON_COMPLIANT: x9's precision is not strictly greater than x12's
  x9 << x13; // NON_COMPLIANT: x9's precision is not strictly greater than x13's
  x9 << x14; // NON_COMPLIANT: x9's precision is not strictly greater than x14's
  x10 << x0; // COMPLIANT: x10's precision is strictly greater than x0's
  x10 << x1; // COMPLIANT: x10's precision is strictly greater than x1's
  x10 << x2; // COMPLIANT: x10's precision is strictly greater than x2's
  x10 << x3; // COMPLIANT: x10's precision is strictly greater than x3's
  x10 << x4; // COMPLIANT: x10's precision is strictly greater than x4's
  x10 << x5; // COMPLIANT: x10's precision is strictly greater than x5's
  x10 << x6; // NON_COMPLIANT: x10's precision is not strictly greater than x6's
  x10 << x7; // NON_COMPLIANT: x10's precision is not strictly greater than x7's
  x10 << x8; // NON_COMPLIANT: x10's precision is not strictly greater than x8's
  x10 << x9; // NON_COMPLIANT: x10's precision is not strictly greater than x9's
  x10 << x10; // NON_COMPLIANT: x10's precision is not strictly greater than
              // x10's
  x10 << x11; // NON_COMPLIANT: x10's precision is not strictly greater than
              // x11's
  x10 << x12; // NON_COMPLIANT: x10's precision is not strictly greater than
              // x12's
  x10 << x13; // NON_COMPLIANT: x10's precision is not strictly greater than
              // x13's
  x10 << x14; // NON_COMPLIANT: x10's precision is not strictly greater than
              // x14's
  x11 << x0;  // COMPLIANT: x11's precision is strictly greater than x0's
  x11 << x1;  // COMPLIANT: x11's precision is strictly greater than x1's
  x11 << x2;  // COMPLIANT: x11's precision is strictly greater than x2's
  x11 << x3;  // COMPLIANT: x11's precision is strictly greater than x3's
  x11 << x4;  // COMPLIANT: x11's precision is strictly greater than x4's
  x11 << x5;  // COMPLIANT: x11's precision is strictly greater than x5's
  x11 << x6; // NON_COMPLIANT: x11's precision is not strictly greater than x6's
  x11 << x7; // NON_COMPLIANT: x11's precision is not strictly greater than x7's
  x11 << x8; // NON_COMPLIANT: x11's precision is not strictly greater than x8's
  x11 << x9; // NON_COMPLIANT: x11's precision is not strictly greater than x9's
  x11 << x10; // NON_COMPLIANT: x11's precision is not strictly greater than
              // x10's
  x11 << x11; // NON_COMPLIANT: x11's precision is not strictly greater than
              // x11's
  x11 << x12; // NON_COMPLIANT: x11's precision is not strictly greater than
              // x12's
  x11 << x13; // NON_COMPLIANT: x11's precision is not strictly greater than
              // x13's
  x11 << x14; // NON_COMPLIANT: x11's precision is not strictly greater than
              // x14's
  x12 << x0;  // COMPLIANT: x12's precision is strictly greater than x0's
  x12 << x1;  // COMPLIANT: x12's precision is strictly greater than x1's
  x12 << x2;  // COMPLIANT: x12's precision is strictly greater than x2's
  x12 << x3;  // COMPLIANT: x12's precision is strictly greater than x3's
  x12 << x4;  // COMPLIANT: x12's precision is strictly greater than x4's
  x12 << x5;  // COMPLIANT: x12's precision is strictly greater than x5's
  x12 << x6;  // COMPLIANT: x12's precision is strictly greater than x6's
  x12 << x7;  // COMPLIANT: x12's precision is strictly greater than x7's
  x12 << x8;  // COMPLIANT: x12's precision is strictly greater than x8's
  x12 << x9;  // COMPLIANT: x12's precision is strictly greater than x9's
  x12 << x10; // COMPLIANT: x12's precision is strictly greater than x10's
  x12 << x11; // COMPLIANT: x12's precision is strictly greater than x11's
  x12 << x12; // NON_COMPLIANT: x12's precision is not strictly greater than
              // x12's
  x12 << x13; // COMPLIANT: x12's precision is strictly greater than x13's
  x12 << x14; // COMPLIANT: x12's precision is strictly greater than x14's
  x13 << x0;  // COMPLIANT: x13's precision is strictly greater than x0's
  x13 << x1;  // COMPLIANT: x13's precision is strictly greater than x1's
  x13 << x2;  // COMPLIANT: x13's precision is strictly greater than x2's
  x13 << x3;  // COMPLIANT: x13's precision is strictly greater than x3's
  x13 << x4;  // COMPLIANT: x13's precision is strictly greater than x4's
  x13 << x5;  // COMPLIANT: x13's precision is strictly greater than x5's
  x13 << x6;  // COMPLIANT: x13's precision is strictly greater than x6's
  x13 << x7;  // COMPLIANT: x13's precision is strictly greater than x7's
  x13 << x8;  // COMPLIANT: x13's precision is strictly greater than x8's
  x13 << x9;  // COMPLIANT: x13's precision is strictly greater than x9's
  x13 << x10; // COMPLIANT: x13's precision is strictly greater than x10's
  x13 << x11; // COMPLIANT: x13's precision is strictly greater than x11's
  x13 << x12; // NON_COMPLIANT: x13's precision is not strictly greater than
              // x12's
  x13 << x13; // NON_COMPLIANT: x13's precision is not strictly greater than
              // x13's
  x13 << x14; // NON_COMPLIANT: x13's precision is not strictly greater than
              // x14's
  x14 << x0;  // COMPLIANT: x14's precision is strictly greater than x0's
  x14 << x1;  // COMPLIANT: x14's precision is strictly greater than x1's
  x14 << x2;  // COMPLIANT: x14's precision is strictly greater than x2's
  x14 << x3;  // COMPLIANT: x14's precision is strictly greater than x3's
  x14 << x4;  // COMPLIANT: x14's precision is strictly greater than x4's
  x14 << x5;  // COMPLIANT: x14's precision is strictly greater than x5's
  x14 << x6;  // COMPLIANT: x14's precision is strictly greater than x6's
  x14 << x7;  // COMPLIANT: x14's precision is strictly greater than x7's
  x14 << x8;  // COMPLIANT: x14's precision is strictly greater than x8's
  x14 << x9;  // COMPLIANT: x14's precision is strictly greater than x9's
  x14 << x10; // COMPLIANT: x14's precision is strictly greater than x10's
  x14 << x11; // COMPLIANT: x14's precision is strictly greater than x11's
  x14 << x12; // NON_COMPLIANT: x14's precision is not strictly greater than
              // x12's
  x14 << x13; // NON_COMPLIANT: x14's precision is not strictly greater than
              // x13's
  x14 << x14; // NON_COMPLIANT: x14's precision is not strictly greater than
              // x14's

  /* right shift */

  x0 >> x0;  // NON_COMPLIANT: x0's precision is not strictly greater than x0's
  x0 >> x1;  // COMPLIANT: x0's precision is strictly greater than x1's
  x0 >> x2;  // COMPLIANT: x0's precision is strictly greater than x2's
  x0 >> x3;  // NON_COMPLIANT: x0's precision is not strictly greater than x3's
  x0 >> x4;  // NON_COMPLIANT: x0's precision is not strictly greater than x4's
  x0 >> x5;  // NON_COMPLIANT: x0's precision is not strictly greater than x5's
  x0 >> x6;  // NON_COMPLIANT: x0's precision is not strictly greater than x6's
  x0 >> x7;  // NON_COMPLIANT: x0's precision is not strictly greater than x7's
  x0 >> x8;  // NON_COMPLIANT: x0's precision is not strictly greater than x8's
  x0 >> x9;  // NON_COMPLIANT: x0's precision is not strictly greater than x9's
  x0 >> x10; // NON_COMPLIANT: x0's precision is not strictly greater than x10's
  x0 >> x11; // NON_COMPLIANT: x0's precision is not strictly greater than x11's
  x0 >> x12; // NON_COMPLIANT: x0's precision is not strictly greater than x12's
  x0 >> x13; // NON_COMPLIANT: x0's precision is not strictly greater than x13's
  x0 >> x14; // NON_COMPLIANT: x0's precision is not strictly greater than x14's
  x1 >> x0;  // NON_COMPLIANT: x1's precision is not strictly greater than x0's
  x1 >> x1;  // NON_COMPLIANT: x1's precision is not strictly greater than x1's
  x1 >> x2;  // NON_COMPLIANT: x1's precision is not strictly greater than x2's
  x1 >> x3;  // NON_COMPLIANT: x1's precision is not strictly greater than x3's
  x1 >> x4;  // NON_COMPLIANT: x1's precision is not strictly greater than x4's
  x1 >> x5;  // NON_COMPLIANT: x1's precision is not strictly greater than x5's
  x1 >> x6;  // NON_COMPLIANT: x1's precision is not strictly greater than x6's
  x1 >> x7;  // NON_COMPLIANT: x1's precision is not strictly greater than x7's
  x1 >> x8;  // NON_COMPLIANT: x1's precision is not strictly greater than x8's
  x1 >> x9;  // NON_COMPLIANT: x1's precision is not strictly greater than x9's
  x1 >> x10; // NON_COMPLIANT: x1's precision is not strictly greater than x10's
  x1 >> x11; // NON_COMPLIANT: x1's precision is not strictly greater than x11's
  x1 >> x12; // NON_COMPLIANT: x1's precision is not strictly greater than x12's
  x1 >> x13; // NON_COMPLIANT: x1's precision is not strictly greater than x13's
  x1 >> x14; // NON_COMPLIANT: x1's precision is not strictly greater than x14's
  x2 >> x0;  // NON_COMPLIANT: x2's precision is not strictly greater than x0's
  x2 >> x1;  // NON_COMPLIANT: x2's precision is not strictly greater than x1's
  x2 >> x2;  // NON_COMPLIANT: x2's precision is not strictly greater than x2's
  x2 >> x3;  // NON_COMPLIANT: x2's precision is not strictly greater than x3's
  x2 >> x4;  // NON_COMPLIANT: x2's precision is not strictly greater than x4's
  x2 >> x5;  // NON_COMPLIANT: x2's precision is not strictly greater than x5's
  x2 >> x6;  // NON_COMPLIANT: x2's precision is not strictly greater than x6's
  x2 >> x7;  // NON_COMPLIANT: x2's precision is not strictly greater than x7's
  x2 >> x8;  // NON_COMPLIANT: x2's precision is not strictly greater than x8's
  x2 >> x9;  // NON_COMPLIANT: x2's precision is not strictly greater than x9's
  x2 >> x10; // NON_COMPLIANT: x2's precision is not strictly greater than x10's
  x2 >> x11; // NON_COMPLIANT: x2's precision is not strictly greater than x11's
  x2 >> x12; // NON_COMPLIANT: x2's precision is not strictly greater than x12's
  x2 >> x13; // NON_COMPLIANT: x2's precision is not strictly greater than x13's
  x2 >> x14; // NON_COMPLIANT: x2's precision is not strictly greater than x14's
  x3 >> x0;  // COMPLIANT: x3's precision is strictly greater than x0's
  x3 >> x1;  // COMPLIANT: x3's precision is strictly greater than x1's
  x3 >> x2;  // COMPLIANT: x3's precision is strictly greater than x2's
  x3 >> x3;  // NON_COMPLIANT: x3's precision is not strictly greater than x3's
  x3 >> x4;  // COMPLIANT: x3's precision is strictly greater than x4's
  x3 >> x5;  // COMPLIANT: x3's precision is strictly greater than x5's
  x3 >> x6;  // NON_COMPLIANT: x3's precision is not strictly greater than x6's
  x3 >> x7;  // NON_COMPLIANT: x3's precision is not strictly greater than x7's
  x3 >> x8;  // NON_COMPLIANT: x3's precision is not strictly greater than x8's
  x3 >> x9;  // NON_COMPLIANT: x3's precision is not strictly greater than x9's
  x3 >> x10; // NON_COMPLIANT: x3's precision is not strictly greater than x10's
  x3 >> x11; // NON_COMPLIANT: x3's precision is not strictly greater than x11's
  x3 >> x12; // NON_COMPLIANT: x3's precision is not strictly greater than x12's
  x3 >> x13; // NON_COMPLIANT: x3's precision is not strictly greater than x13's
  x3 >> x14; // NON_COMPLIANT: x3's precision is not strictly greater than x14's
  x4 >> x0;  // COMPLIANT: x4's precision is strictly greater than x0's
  x4 >> x1;  // COMPLIANT: x4's precision is strictly greater than x1's
  x4 >> x2;  // COMPLIANT: x4's precision is strictly greater than x2's
  x4 >> x3;  // NON_COMPLIANT: x4's precision is not strictly greater than x3's
  x4 >> x4;  // NON_COMPLIANT: x4's precision is not strictly greater than x4's
  x4 >> x5;  // NON_COMPLIANT: x4's precision is not strictly greater than x5's
  x4 >> x6;  // NON_COMPLIANT: x4's precision is not strictly greater than x6's
  x4 >> x7;  // NON_COMPLIANT: x4's precision is not strictly greater than x7's
  x4 >> x8;  // NON_COMPLIANT: x4's precision is not strictly greater than x8's
  x4 >> x9;  // NON_COMPLIANT: x4's precision is not strictly greater than x9's
  x4 >> x10; // NON_COMPLIANT: x4's precision is not strictly greater than x10's
  x4 >> x11; // NON_COMPLIANT: x4's precision is not strictly greater than x11's
  x4 >> x12; // NON_COMPLIANT: x4's precision is not strictly greater than x12's
  x4 >> x13; // NON_COMPLIANT: x4's precision is not strictly greater than x13's
  x4 >> x14; // NON_COMPLIANT: x4's precision is not strictly greater than x14's
  x5 >> x0;  // COMPLIANT: x5's precision is strictly greater than x0's
  x5 >> x1;  // COMPLIANT: x5's precision is strictly greater than x1's
  x5 >> x2;  // COMPLIANT: x5's precision is strictly greater than x2's
  x5 >> x3;  // NON_COMPLIANT: x5's precision is not strictly greater than x3's
  x5 >> x4;  // NON_COMPLIANT: x5's precision is not strictly greater than x4's
  x5 >> x5;  // NON_COMPLIANT: x5's precision is not strictly greater than x5's
  x5 >> x6;  // NON_COMPLIANT: x5's precision is not strictly greater than x6's
  x5 >> x7;  // NON_COMPLIANT: x5's precision is not strictly greater than x7's
  x5 >> x8;  // NON_COMPLIANT: x5's precision is not strictly greater than x8's
  x5 >> x9;  // NON_COMPLIANT: x5's precision is not strictly greater than x9's
  x5 >> x10; // NON_COMPLIANT: x5's precision is not strictly greater than x10's
  x5 >> x11; // NON_COMPLIANT: x5's precision is not strictly greater than x11's
  x5 >> x12; // NON_COMPLIANT: x5's precision is not strictly greater than x12's
  x5 >> x13; // NON_COMPLIANT: x5's precision is not strictly greater than x13's
  x5 >> x14; // NON_COMPLIANT: x5's precision is not strictly greater than x14's
  x6 >> x0;  // COMPLIANT: x6's precision is strictly greater than x0's
  x6 >> x1;  // COMPLIANT: x6's precision is strictly greater than x1's
  x6 >> x2;  // COMPLIANT: x6's precision is strictly greater than x2's
  x6 >> x3;  // COMPLIANT: x6's precision is strictly greater than x3's
  x6 >> x4;  // COMPLIANT: x6's precision is strictly greater than x4's
  x6 >> x5;  // COMPLIANT: x6's precision is strictly greater than x5's
  x6 >> x6;  // NON_COMPLIANT: x6's precision is not strictly greater than x6's
  x6 >> x7;  // COMPLIANT: x6's precision is strictly greater than x7's
  x6 >> x8;  // COMPLIANT: x6's precision is strictly greater than x8's
  x6 >> x9;  // NON_COMPLIANT: x6's precision is not strictly greater than x9's
  x6 >> x10; // COMPLIANT: x6's precision is strictly greater than x10's
  x6 >> x11; // COMPLIANT: x6's precision is strictly greater than x11's
  x6 >> x12; // NON_COMPLIANT: x6's precision is not strictly greater than x12's
  x6 >> x13; // NON_COMPLIANT: x6's precision is not strictly greater than x13's
  x6 >> x14; // NON_COMPLIANT: x6's precision is not strictly greater than x14's
  x7 >> x0;  // COMPLIANT: x7's precision is strictly greater than x0's
  x7 >> x1;  // COMPLIANT: x7's precision is strictly greater than x1's
  x7 >> x2;  // COMPLIANT: x7's precision is strictly greater than x2's
  x7 >> x3;  // COMPLIANT: x7's precision is strictly greater than x3's
  x7 >> x4;  // COMPLIANT: x7's precision is strictly greater than x4's
  x7 >> x5;  // COMPLIANT: x7's precision is strictly greater than x5's
  x7 >> x6;  // NON_COMPLIANT: x7's precision is not strictly greater than x6's
  x7 >> x7;  // NON_COMPLIANT: x7's precision is not strictly greater than x7's
  x7 >> x8;  // NON_COMPLIANT: x7's precision is not strictly greater than x8's
  x7 >> x9;  // NON_COMPLIANT: x7's precision is not strictly greater than x9's
  x7 >> x10; // NON_COMPLIANT: x7's precision is not strictly greater than x10's
  x7 >> x11; // NON_COMPLIANT: x7's precision is not strictly greater than x11's
  x7 >> x12; // NON_COMPLIANT: x7's precision is not strictly greater than x12's
  x7 >> x13; // NON_COMPLIANT: x7's precision is not strictly greater than x13's
  x7 >> x14; // NON_COMPLIANT: x7's precision is not strictly greater than x14's
  x8 >> x0;  // COMPLIANT: x8's precision is strictly greater than x0's
  x8 >> x1;  // COMPLIANT: x8's precision is strictly greater than x1's
  x8 >> x2;  // COMPLIANT: x8's precision is strictly greater than x2's
  x8 >> x3;  // COMPLIANT: x8's precision is strictly greater than x3's
  x8 >> x4;  // COMPLIANT: x8's precision is strictly greater than x4's
  x8 >> x5;  // COMPLIANT: x8's precision is strictly greater than x5's
  x8 >> x6;  // NON_COMPLIANT: x8's precision is not strictly greater than x6's
  x8 >> x7;  // NON_COMPLIANT: x8's precision is not strictly greater than x7's
  x8 >> x8;  // NON_COMPLIANT: x8's precision is not strictly greater than x8's
  x8 >> x9;  // NON_COMPLIANT: x8's precision is not strictly greater than x9's
  x8 >> x10; // NON_COMPLIANT: x8's precision is not strictly greater than x10's
  x8 >> x11; // NON_COMPLIANT: x8's precision is not strictly greater than x11's
  x8 >> x12; // NON_COMPLIANT: x8's precision is not strictly greater than x12's
  x8 >> x13; // NON_COMPLIANT: x8's precision is not strictly greater than x13's
  x8 >> x14; // NON_COMPLIANT: x8's precision is not strictly greater than x14's
  x9 >> x0;  // COMPLIANT: x9's precision is strictly greater than x0's
  x9 >> x1;  // COMPLIANT: x9's precision is strictly greater than x1's
  x9 >> x2;  // COMPLIANT: x9's precision is strictly greater than x2's
  x9 >> x3;  // COMPLIANT: x9's precision is strictly greater than x3's
  x9 >> x4;  // COMPLIANT: x9's precision is strictly greater than x4's
  x9 >> x5;  // COMPLIANT: x9's precision is strictly greater than x5's
  x9 >> x6;  // NON_COMPLIANT: x9's precision is not strictly greater than x6's
  x9 >> x7;  // COMPLIANT: x9's precision is strictly greater than x7's
  x9 >> x8;  // COMPLIANT: x9's precision is strictly greater than x8's
  x9 >> x9;  // NON_COMPLIANT: x9's precision is not strictly greater than x9's
  x9 >> x10; // COMPLIANT: x9's precision is strictly greater than x10's
  x9 >> x11; // COMPLIANT: x9's precision is strictly greater than x11's
  x9 >> x12; // NON_COMPLIANT: x9's precision is not strictly greater than x12's
  x9 >> x13; // NON_COMPLIANT: x9's precision is not strictly greater than x13's
  x9 >> x14; // NON_COMPLIANT: x9's precision is not strictly greater than x14's
  x10 >> x0; // COMPLIANT: x10's precision is strictly greater than x0's
  x10 >> x1; // COMPLIANT: x10's precision is strictly greater than x1's
  x10 >> x2; // COMPLIANT: x10's precision is strictly greater than x2's
  x10 >> x3; // COMPLIANT: x10's precision is strictly greater than x3's
  x10 >> x4; // COMPLIANT: x10's precision is strictly greater than x4's
  x10 >> x5; // COMPLIANT: x10's precision is strictly greater than x5's
  x10 >> x6; // NON_COMPLIANT: x10's precision is not strictly greater than x6's
  x10 >> x7; // NON_COMPLIANT: x10's precision is not strictly greater than x7's
  x10 >> x8; // NON_COMPLIANT: x10's precision is not strictly greater than x8's
  x10 >> x9; // NON_COMPLIANT: x10's precision is not strictly greater than x9's
  x10 >>
      x10; // NON_COMPLIANT: x10's precision is not strictly greater than x10's
  x10 >>
      x11; // NON_COMPLIANT: x10's precision is not strictly greater than x11's
  x10 >>
      x12; // NON_COMPLIANT: x10's precision is not strictly greater than x12's
  x10 >>
      x13; // NON_COMPLIANT: x10's precision is not strictly greater than x13's
  x10 >>
      x14; // NON_COMPLIANT: x10's precision is not strictly greater than x14's
  x11 >> x0; // COMPLIANT: x11's precision is strictly greater than x0's
  x11 >> x1; // COMPLIANT: x11's precision is strictly greater than x1's
  x11 >> x2; // COMPLIANT: x11's precision is strictly greater than x2's
  x11 >> x3; // COMPLIANT: x11's precision is strictly greater than x3's
  x11 >> x4; // COMPLIANT: x11's precision is strictly greater than x4's
  x11 >> x5; // COMPLIANT: x11's precision is strictly greater than x5's
  x11 >> x6; // NON_COMPLIANT: x11's precision is not strictly greater than x6's
  x11 >> x7; // NON_COMPLIANT: x11's precision is not strictly greater than x7's
  x11 >> x8; // NON_COMPLIANT: x11's precision is not strictly greater than x8's
  x11 >> x9; // NON_COMPLIANT: x11's precision is not strictly greater than x9's
  x11 >>
      x10; // NON_COMPLIANT: x11's precision is not strictly greater than x10's
  x11 >>
      x11; // NON_COMPLIANT: x11's precision is not strictly greater than x11's
  x11 >>
      x12; // NON_COMPLIANT: x11's precision is not strictly greater than x12's
  x11 >>
      x13; // NON_COMPLIANT: x11's precision is not strictly greater than x13's
  x11 >>
      x14; // NON_COMPLIANT: x11's precision is not strictly greater than x14's
  x12 >> x0;  // COMPLIANT: x12's precision is strictly greater than x0's
  x12 >> x1;  // COMPLIANT: x12's precision is strictly greater than x1's
  x12 >> x2;  // COMPLIANT: x12's precision is strictly greater than x2's
  x12 >> x3;  // COMPLIANT: x12's precision is strictly greater than x3's
  x12 >> x4;  // COMPLIANT: x12's precision is strictly greater than x4's
  x12 >> x5;  // COMPLIANT: x12's precision is strictly greater than x5's
  x12 >> x6;  // COMPLIANT: x12's precision is strictly greater than x6's
  x12 >> x7;  // COMPLIANT: x12's precision is strictly greater than x7's
  x12 >> x8;  // COMPLIANT: x12's precision is strictly greater than x8's
  x12 >> x9;  // COMPLIANT: x12's precision is strictly greater than x9's
  x12 >> x10; // COMPLIANT: x12's precision is strictly greater than x10's
  x12 >> x11; // COMPLIANT: x12's precision is strictly greater than x11's
  x12 >>
      x12; // NON_COMPLIANT: x12's precision is not strictly greater than x12's
  x12 >> x13; // COMPLIANT: x12's precision is strictly greater than x13's
  x12 >> x14; // COMPLIANT: x12's precision is strictly greater than x14's
  x13 >> x0;  // COMPLIANT: x13's precision is strictly greater than x0's
  x13 >> x1;  // COMPLIANT: x13's precision is strictly greater than x1's
  x13 >> x2;  // COMPLIANT: x13's precision is strictly greater than x2's
  x13 >> x3;  // COMPLIANT: x13's precision is strictly greater than x3's
  x13 >> x4;  // COMPLIANT: x13's precision is strictly greater than x4's
  x13 >> x5;  // COMPLIANT: x13's precision is strictly greater than x5's
  x13 >> x6;  // COMPLIANT: x13's precision is strictly greater than x6's
  x13 >> x7;  // COMPLIANT: x13's precision is strictly greater than x7's
  x13 >> x8;  // COMPLIANT: x13's precision is strictly greater than x8's
  x13 >> x9;  // COMPLIANT: x13's precision is strictly greater than x9's
  x13 >> x10; // COMPLIANT: x13's precision is strictly greater than x10's
  x13 >> x11; // COMPLIANT: x13's precision is strictly greater than x11's
  x13 >>
      x12; // NON_COMPLIANT: x13's precision is not strictly greater than x12's
  x13 >>
      x13; // NON_COMPLIANT: x13's precision is not strictly greater than x13's
  x13 >>
      x14; // NON_COMPLIANT: x13's precision is not strictly greater than x14's
  x14 >> x0;  // COMPLIANT: x14's precision is strictly greater than x0's
  x14 >> x1;  // COMPLIANT: x14's precision is strictly greater than x1's
  x14 >> x2;  // COMPLIANT: x14's precision is strictly greater than x2's
  x14 >> x3;  // COMPLIANT: x14's precision is strictly greater than x3's
  x14 >> x4;  // COMPLIANT: x14's precision is strictly greater than x4's
  x14 >> x5;  // COMPLIANT: x14's precision is strictly greater than x5's
  x14 >> x6;  // COMPLIANT: x14's precision is strictly greater than x6's
  x14 >> x7;  // COMPLIANT: x14's precision is strictly greater than x7's
  x14 >> x8;  // COMPLIANT: x14's precision is strictly greater than x8's
  x14 >> x9;  // COMPLIANT: x14's precision is strictly greater than x9's
  x14 >> x10; // COMPLIANT: x14's precision is strictly greater than x10's
  x14 >> x11; // COMPLIANT: x14's precision is strictly greater than x11's
  x14 >>
      x12; // NON_COMPLIANT: x14's precision is not strictly greater than x12's
  x14 >>
      x13; // NON_COMPLIANT: x14's precision is not strictly greater than x13's
  x14 >>
      x14; // NON_COMPLIANT: x14's precision is not strictly greater than x14's

  /* negative shift */

  x0 << -1;  // NON_COMPLIANT: shifting by a negative operand
  x1 << -1;  // NON_COMPLIANT: shifting by a negative operand
  x2 << -1;  // NON_COMPLIANT: shifting by a negative operand
  x3 << -1;  // NON_COMPLIANT: shifting by a negative operand
  x4 << -1;  // NON_COMPLIANT: shifting by a negative operand
  x5 << -1;  // NON_COMPLIANT: shifting by a negative operand
  x6 << -1;  // NON_COMPLIANT: shifting by a negative operand
  x7 << -1;  // NON_COMPLIANT: shifting by a negative operand
  x8 << -1;  // NON_COMPLIANT: shifting by a negative operand
  x9 << -1;  // NON_COMPLIANT: shifting by a negative operand
  x10 << -1; // NON_COMPLIANT: shifting by a negative operand
  x11 << -1; // NON_COMPLIANT: shifting by a negative operand
  x12 << -1; // NON_COMPLIANT: shifting by a negative operand
  x13 << -1; // NON_COMPLIANT: shifting by a negative operand
  x14 << -1; // NON_COMPLIANT: shifting by a negative operand

  return 0;
}