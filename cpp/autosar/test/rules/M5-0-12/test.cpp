#include <cstdint>

template <typename T, T y> class C1 {
public:
  C1() : x(y) {}

private:
  unsigned char x;
};

template <typename T, T y> class C2 {
public:
  C2() : x(y) {}

private:
  signed char x;
};

/* Twin templates for std::uint8_t and std::int8_t */
template <typename T, T y> class C5 {
public:
  C5() : x(y) {}

private:
  std::uint8_t x;
};

template <typename T, T y> class C6 {
public:
  C6() : x(y) {}

private:
  std::int8_t x;
};

void f1(unsigned char x) {}
void f2(signed char x) {}

/* Twin functions for std::uint8_t and std::int8_t */
void f9(std::uint8_t x) {}
void f10(std::int8_t x) {}

template <typename T> void f5(T x) { unsigned char y = x; }
template <typename T> void f6(T x) { signed char y = x; }

/* Twin template functions for std::uint8_t and std::int8_t */
template <typename T> void f13(T x) { std::uint8_t y = x; }
template <typename T> void f14(T x) { std::int8_t y = x; }

template <typename T> class C9 {
public:
  C9(T y) : x(y) {}

private:
  unsigned char x;
};

template <typename T> class C10 {
public:
  C10(T y) : x(y) {}

private:
  signed char x;
};

/* Twin template classes for std::uint8_t and std::int8_t */
template <typename T> class C13 {
public:
  C13(T y) : x(y) {}

private:
  std::uint8_t x;
};

template <typename T> class C14 {
public:
  C14(T y) : x(y) {}

private:
  std::int8_t x;
};

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

  C1<unsigned char, 1> c1; // COMPLIANT: unsigned char arg passed to an unsigned
                           // char member through a template

  C2<signed char, 1> c2; // COMPLIANT: signed char arg passed to a signed char
                         // member through a template

  C1<char, 'x'> c3; // NON-COMPLIANT: plain char arg passed to an unsigned char
                    // member through a template

  C2<char, 'x'> c4; // NON-COMPLIANT: plain char arg passed to a signed char
                    // member through a template

  /* Twin cases with std::uint8_t and std::int8_t */
  C5<std::uint8_t, 1> c5; // COMPLIANT: std::uint8_t arg passed to a
                          // std::uint8_t member through a template

  C6<std::int8_t, 1> c6; // COMPLIANT: std::int8_t arg passed to a std::int8_t
                         // member through a template

  C5<char, 1> c7; // NON-COMPLIANT: plain char arg passed to a
                  // std::uint8_t member through a template

  C6<char, 1> c8; // NON-COMPLIANT: plain char arg passed to a std::int8_t
                  // member through a template

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

  /* ===== 2-1. Passing char argument to a char parameter of a regular function
   * ===== */

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

  /* ===== 2-2. Passing char argument to a char parameter through a template
   * ===== */

  unsigned char a9 = 1;
  f5(a9); // COMPLIANT: unsigned char arg passed to an unsigned char parameter
          // through a template

  signed char a10 = 1;
  f6(a10); // COMPLIANT: signed char arg passed to a signed char parameter
           // through a template

  char a11 = 'a';
  f5(a11); // NON-COMPLIANT: plain char arg passed to an unsigned char parameter
           // through a template

  char a12 = 'a';
  f6(a12); // NON-COMPLIANT: plain char arg passed to a signed char parameter
           // through a template

  /* Twin cases with std::uint8_t and std::int8_t */
  std::uint8_t a13 = 1;
  f13(a13); // COMPLIANT: std::uint8_t arg passed to a std::uint8_t parameter
            // through a template

  std::int8_t a14 = 1;
  f14(a14); // COMPLIANT: std::int8_t arg passed to a std::int8_t parameter
            // through a template

  char a15 = 'a';
  f13(a15); // NON-COMPLIANT: plain char arg passed to a std::uint8_t parameter
            // through a template

  char a16 = 'a';
  f14(a16); // NON-COMPLIANT: plain char arg passed to a std::int8_t parameter
            // through a template

  /* ========== 2-3. Passing a char argument to a char parameter through a
   * template ========== */

  unsigned char a17 = 1;
  C9<unsigned char> c9(
      a17); // COMPLIANT: unsigned char arg passed to an unsigned char parameter
            // of a constructor through a template

  signed char a18 = 1;
  C10<signed char> c10(
      a18); // COMPLIANT: signed char arg passed to an signed
            // char parameter of a constructor through a template

  char a19 = 'a';
  C9<char> c11(
      a19); // NON-COMPLIANT: plain char arg passed to an unsigned signed char
            // parameter of a constructor through a template

  char a20 = 'a';
  C10<char> c12(a20); // NON-COMPLIANT: plain char arg passed to an signed char
                      // parameter of a constructor through a template

  /* Twin cases with std::uint8_t and std::int8_t */
  std::uint8_t a21 = 1;
  C13<std::uint8_t> c13(
      a21); // COMPLIANT: std::uint8_t arg passed to a std::uint8_t parameter
            // of a constructor through a template

  std::int8_t a22 = 1;
  C14<std::int8_t> c14(
      a22); // COMPLIANT: std::int8_t arg passed to a std::int8_t
            // parameter of a constructor through a template

  char a23 = 'a';
  C13<char> c15(a23); // NON-COMPLIANT: plain char arg passed to a std::uint8_t
                      // parameter of a constructor through a template

  char a24 = 'a';
  C14<char> c16(a24); // NON-COMPLIANT: plain char arg passed to a std::int8_t
                      // parameter of a constructor through a template
}
