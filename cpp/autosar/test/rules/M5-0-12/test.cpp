#include <cstdint>

class C1 {
public:
  C1(unsigned char y) : x(y) {}

private:
  unsigned char x;
};

class C2 {
public:
  C2(signed char y) : x(y) {}

private:
  signed char x;
};

/* Twin classes for std::uint8_t and std::int8_t */
class C5 {
public:
  C5(unsigned char y) : x(y) {}

private:
  std::uint8_t x;
};

class C6 {
public:
  C6(signed char y) : x(y) {}

private:
  std::int8_t x;
};

void f1(unsigned char x) {}
void f2(signed char x) {}

/* Twin functions for std::uint8_t and std::int8_t */
void f9(std::uint8_t x) {}
void f10(std::int8_t x) {}

int main() {

  /* ========== 1. Assigning a char to another char ========== */

  /* ===== 1-1. Assigning a char to a char variable ===== */

  unsigned char x1 = 1;
  unsigned char y1 =
      x1; // COMPLIANT: unsigned char assigned to an unsigned char

  signed char x2 = 1;
  signed char y2 = x2; // COMPLIANT: signed char assigned to a signed char

  char x3 = 'x';
  unsigned char y3 =
      x3; // NON-COMPLIANT: plain char assigned to a unsigned char

  char x4 = 'x';
  signed char y4 = x4; // NON-COMPLIANT: plain char assigned to a signed char

  /* Twin cases with std::uint8_t and std::int8_t */
  std::uint8_t x5 = 1;
  std::uint8_t y5 = x5; // COMPLIANT: std::uint8_t assigned to a std::uint8_t

  std::int8_t x6 = 1;
  std::int8_t y6 = x6; // COMPLIANT: std::int8_t assigned to a std::int8_t

  char x7 = 'x';
  std::uint8_t y7 = x7; // NON-COMPLIANT: plain char assigned to a std::uint8_t

  char x8 = 'x';
  std::int8_t y8 = x8; // NON-COMPLIANT: plain char assigned to a std::int8_t

  /* ===== 1-2. Assigning a char to a char member ===== */

  C1 c1(1); // COMPLIANT: unsigned char arg passed to an unsigned
            // char member

  C2 c2(1); // COMPLIANT: signed char arg passed to a signed char
            // member

  C1 c3('x'); // NON-COMPLIANT: plain char arg passed to an unsigned char
              // member

  C2 c4('x'); // NON-COMPLIANT: plain char arg passed to a signed char
              // member

  /* Twin cases with std::uint8_t and std::int8_t */
  C5 c5(1); // COMPLIANT: std::uint8_t arg passed to a
            // std::uint8_t member

  C6 c6(1); // COMPLIANT: std::int8_t arg passed to a std::int8_t
            // member

  C5 c7('x'); // NON-COMPLIANT: plain char arg passed to a
              // std::uint8_t member

  C6 c8('x'); // NON-COMPLIANT: plain char arg passed to a std::int8_t
              // member

  /* ========== 1-3. Assigning a char to a char through a pointer ========== */

  unsigned char x9 = 1;
  unsigned char *y9 = &x9;
  unsigned char z1 =
      *y9; // COMPLIANT: unsigned char assigned to an *&unsigned char

  signed char x10 = 1;
  signed char *y10 = &x10;
  signed char z2 = *y10; // COMPLIANT: signed char assigned to an *&signed char

  char x11 = 1;
  char *y11 = &x11;
  unsigned char z3 =
      *y11; // NON-COMPLIANT: plain char assigned to an *&unsigned char

  char x12 = 1;
  char *y12 = &x12;
  signed char z4 =
      *y12; // NON-COMPLIANT: plain char assigned to an *&signed char

  /* Twin cases with std::uint8_t and std::int8_t */
  std::uint8_t x13 = 1;
  std::uint8_t *y13 = &x13;
  std::uint8_t z5 =
      *y13; // COMPLIANT: std::uint8_t assigned to a *&std::uint8_t

  std::int8_t x14 = 1;
  std::int8_t *y14 = &x14;
  std::int8_t z6 = *y14; // COMPLIANT: std::int8_t assigned to an *&std::int8_t

  char x15 = 1;
  char *y15 = &x15;
  std::uint8_t z7 =
      *y15; // NON-COMPLIANT: plain char assigned to an *&std::uint8_t

  char x16 = 1;
  char *y16 = &x16;
  std::int8_t z8 =
      *y16; // NON-COMPLIANT: plain char assigned to an *&std::int8_t

  /* ========== 2. Passing a char argument to a char parameter ========== */

  unsigned char a1 = 1;
  f1(a1); // COMPLIANT: unsigned char arg passed to an unsigned char parameter

  signed char a2 = 1;
  f2(a2); // COMPLIANT: signed char arg passed to a signed char parameter

  char a3 = 'a';
  f1(a3); // NON-COMPLIANT: plain char arg passed to an unsigned char parameter

  char a4 = 'a';
  f2(a4); // NON-COMPLIANT: plain char arg passed to a signed char parameter

  /* Twin cases with std::uint8_t and std::int8_t */
  std::uint8_t a5 = 1;
  f9(a5); // COMPLIANT: std::uint8_t arg passed to a std::uint8_t parameter

  std::int8_t a6 = 1;
  f10(a6); // COMPLIANT: std::int8_t arg passed to a std::int8_t parameter

  char a7 = 'a';
  f9(a7); // NON-COMPLIANT: plain char arg passed to a std::uint8_t parameter

  char a8 = 'a';
  f10(a8); // NON-COMPLIANT: plain char arg passed to a std::int8_t parameter
}
