// This test does nothing useful on a standard LP64 system, because 'long' and
// 'long long' are the same size. Unfortunately, adding '-m32' to the
// '--semmle-extractor-options' does nothing as it gets overridden by the
// 'codeql test' command.
//
// However, we can use our compatibility testing framework to compile this with
// '-m32' and test the case where 'long' is 32 bits and 'long long' is 64 bits.
// The important expectations are defined there.

void f1() {
  // Boundary conditions for signed long (32-bit)
  2147483647L; // COMPLIANT - max value for 32-bit long
  2147483647l; // COMPLIANT - max value for 32-bit long

  // Long long literals with single l or L suffix (NON_COMPLIANT)
  2147483648L; // NON_COMPLIANT - single L suffix, too large for 32-bit long
  2147483648l; // NON_COMPLIANT - single l suffix, too large for 32-bit long

  // Boundary conditions for unsigned long (32-bit)
  4294967295UL; // COMPLIANT - max value for 32-bit unsigned long
  4294967295Ul; // COMPLIANT - max value for 32-bit unsigned long
  4294967295uL; // COMPLIANT - max value for 32-bit unsigned long
  4294967295ul; // COMPLIANT - max value for 32-bit unsigned long

  // Unsigned long long literals with single l or L suffix
  4294967296UL; // NON_COMPLIANT - single L suffix, too large for 32-bit
                // unsigned long
  4294967296Ul; // NON_COMPLIANT - single l suffix, too large for 32-bit
                // unsigned long
  4294967296uL; // NON_COMPLIANT - single L suffix, too large for 32-bit
                // unsigned long
  4294967296ul; // NON_COMPLIANT - single l suffix, too large for 32-bit
                // unsigned long

  // High-range long long literals with single L suffix
  9223372036854775807L; // NON_COMPLIANT - near LONG_LONG_MAX, single L
  9223372036854775807l; // NON_COMPLIANT - near LONG_LONG_MAX, single l

  // High-range unsigned long long literals with single L suffix
  18446744073709551615UL; // NON_COMPLIANT - ULONG_LONG_MAX, single L
  18446744073709551615Ul; // NON_COMPLIANT - ULONG_LONG_MAX, single l

  // Long long literals with double l or L suffix (COMPLIANT)
  2147483648LL;  // COMPLIANT
  2147483648ll;  // COMPLIANT
  4294967296ULL; // COMPLIANT
  4294967296Ull; // COMPLIANT
  4294967296uLL; // COMPLIANT
  4294967296ull; // COMPLIANT

  // High-range compliant literals
  9223372036854775807LL;   // COMPLIANT - LONG_LONG_MAX
  9223372036854775808ULL;  // COMPLIANT - beyond LONG_LONG_MAX
  18446744073709551615ULL; // COMPLIANT - ULONG_LONG_MAX

  // Long literals with double L (COMPLIANT - overkill but allowed)
  123LL;         // COMPLIANT - overkill but allowed
  123ll;         // COMPLIANT - overkill but allowed
  123ULL;        // COMPLIANT - overkill but allowed
  2147483647LL;  // COMPLIANT - overkill for long value
  4294967295ULL; // COMPLIANT - overkill for unsigned long value

  // Small literals with single L (COMPLIANT - these are actually of type long)
  123L;  // COMPLIANT - type is long, not long long
  123l;  // COMPLIANT - type is long, not long long
  123UL; // COMPLIANT - type is unsigned long, not unsigned long long
  123Ul; // COMPLIANT - type is unsigned long, not unsigned long long

  // Unsuffixed literals of all sizes (COMPLIANT)
  123;        // COMPLIANT - unsuffixed
  2147483647; // COMPLIANT - unsuffixed (max 32-bit signed)
  2147483648; // COMPLIANT - unsuffixed

  // Literals suffixed with 'u' only (COMPLIANT)
  123u;        // COMPLIANT - 'u' suffix only
  123U;        // COMPLIANT - 'U' suffix only
  4294967295U; // COMPLIANT - 'U' suffix only (max 32-bit unsigned)
  4294967296U; // COMPLIANT - 'U' suffix only
}

void f2() {
  // Hex literals - boundary conditions
  0x7FFFFFFFL; // COMPLIANT - max value for 32-bit signed long
  0x7FFFFFFFl; // COMPLIANT - max value for 32-bit signed long

  // Hex literals - boundary for unsigned long
  0x80000000L; // COMPLIANT - fits in 32-bit unsigned long
  0x80000000l; // COMPLIANT - fits in 32-bit unsigned long
  0xFFFFFFFFL; // COMPLIANT - max value for 32-bit unsigned long
  0xFFFFFFFFl; // COMPLIANT - max value for 32-bit unsigned long

  // Hex literals - long long with single L (NON_COMPLIANT)
  0x100000000L; // NON_COMPLIANT - single L suffix, too large for 32-bit
                // unsigned long
  0x100000000l; // NON_COMPLIANT - single l suffix, too large for 32-bit
                // unsigned long

  // High-range hex literals
  0x7FFFFFFFFFFFFFFFL; // NON_COMPLIANT - LONG_LONG_MAX with single L
  0x8000000000000000L; // NON_COMPLIANT - beyond LONG_LONG_MAX with single L
  0xFFFFFFFFFFFFFFFFL; // NON_COMPLIANT - beyond LONG_LONG_MAX with single L
                       // (unsigned)

  // Hex literals - with double L (COMPLIANT)
  0x80000000LL;          // COMPLIANT
  0x80000000ll;          // COMPLIANT
  0x100000000LL;         // COMPLIANT
  0x100000000ll;         // COMPLIANT
  0xFFFFFFFFLL;          // COMPLIANT - overkill for 32-bit unsigned long
  0xFFFFFFFFll;          // COMPLIANT - overkill for 32-bit unsigned long
  0x7FFFFFFFFFFFFFFFLL;  // COMPLIANT - LONG_LONG_MAX
  0xFFFFFFFFFFFFFFFFULL; // COMPLIANT - ULONG_LONG_MAX

  // Small hex literals with single L (COMPLIANT - these are actually long)
  0x123L;  // COMPLIANT - type is long
  0xABCUL; // COMPLIANT - type is unsigned long
}

void f3() {
  // Octal literals - boundary conditions
  017777777777L; // COMPLIANT - max value for 32-bit long
  017777777777l; // COMPLIANT - max value for 32-bit long

  // Octal literals - boundary for unsigned long
  020000000000L; // COMPLIANT - fits in 32-bit unsigned long
  020000000000l; // COMPLIANT - fits in 32-bit unsigned long
  037777777777L; // COMPLIANT - max value for 32-bit unsigned long
  037777777777l; // COMPLIANT - max value for 32-bit unsigned long

  // Octal literals - long long with single L (NON_COMPLIANT)
  040000000000L; // NON_COMPLIANT - single L suffix, too large for 32-bit
                 // unsigned long
  040000000000l; // NON_COMPLIANT - single l suffix, too large for 32-bit
                 // unsigned long

  // High-range octal literals
  0777777777777777777777L;  // NON_COMPLIANT - LONG_LONG_MAX with single L
  01000000000000000000000L; // NON_COMPLIANT - beyond LONG_LONG_MAX with single
                            // L

  // Octal literals - with double L (COMPLIANT)
  020000000000LL;             // COMPLIANT
  020000000000ll;             // COMPLIANT
  040000000000LL;             // COMPLIANT
  040000000000ll;             // COMPLIANT
  0777777777777777777777LL;   // COMPLIANT - LONG_LONG_MAX
  01777777777777777777777ULL; // COMPLIANT - ULONG_LONG_MAX

  // Small octal literals with single L (COMPLIANT - these are actually long)
  0123L;  // COMPLIANT - type is long
  0123UL; // COMPLIANT - type is unsigned long
}

void f4() {
  // Binary literals - boundary conditions
  0b01111111111111111111111111111111L; // COMPLIANT - max value for 32-bit long
  0b01111111111111111111111111111111l; // COMPLIANT - max value for 32-bit long

  // Binary literals - boundary for unsigned long
  0b10000000000000000000000000000000L; // COMPLIANT - fits in 32-bit unsigned
                                       // long
  0b10000000000000000000000000000000l; // COMPLIANT - fits in 32-bit unsigned
                                       // long
  0b11111111111111111111111111111111L; // COMPLIANT - max value for 32-bit
                                       // unsigned long
  0b11111111111111111111111111111111l; // COMPLIANT - max value for 32-bit
                                       // unsigned long

  // Binary literals - long long with single L (NON_COMPLIANT)
  0b100000000000000000000000000000000L; // NON_COMPLIANT - single L suffix,
                                        // beyond unsigned long
  0b100000000000000000000000000000000l; // NON_COMPLIANT - single l suffix,
                                        // beyond unsigned long

  // High-range binary literals
  0b0111111111111111111111111111111111111111111111111111111111111111L; // NON_COMPLIANT
                                                                       // -
                                                                       // LONG_LONG_MAX
  0b1000000000000000000000000000000000000000000000000000000000000000L; // NON_COMPLIANT

  // Binary literals - with double L (COMPLIANT)
  0b10000000000000000000000000000000LL;  // COMPLIANT
  0b10000000000000000000000000000000ll;  // COMPLIANT
  0b100000000000000000000000000000000LL; // COMPLIANT
  0b100000000000000000000000000000000ll; // COMPLIANT
  0b0111111111111111111111111111111111111111111111111111111111111111LL; // COMPLIANT
                                                                        // -
                                                                        // LONG_LONG_MAX
  0b1111111111111111111111111111111111111111111111111111111111111111ULL; // COMPLIANT
                                                                         // -
                                                                         // ULONG_LONG_MAX

  // Small binary literals with single L (COMPLIANT - these are actually long)
  0b1010L;  // COMPLIANT - type is long
  0b1010UL; // COMPLIANT - type is unsigned long
}

void f5() {
  // Testing variable declarations
  // These are COMPLIANT because the type of the literal is not long long
  long long x1 = 123L;    // COMPLIANT - 123L is of type long
  long long x2 = 0xABCL;  // COMPLIANT - 0xABCL is of type long
  long long x3 = 0123L;   // COMPLIANT - 0123L is of type long
  long long x4 = 0b1010L; // COMPLIANT - 0b1010L is of type long

  // Boundary testing in variable assignments
  long long x5 = 0x7FFFFFFFL; // COMPLIANT - 0x7FFFFFFFL is of type long
  long long x6 =
      0x80000000L; // COMPLIANT - 0x80000000L is of type unsigned long
  long long x7 =
      0xFFFFFFFFL; // COMPLIANT - 0xFFFFFFFFL is of type unsigned long

  // These literals are of long long type but properly use LL suffix
  long long x8 = 2147483648LL;           // COMPLIANT - uses LL
  long long x9 = 0x100000000LL;          // COMPLIANT - uses LL
  long long x10 = 040000000000LL;        // COMPLIANT - uses LL
  long long x11 = 9223372036854775807LL; // COMPLIANT - LONG_LONG_MAX with LL

  // These are NON_COMPLIANT because the literal is of type long long but uses
  // single L
  long long x12 = 2147483648L;           // NON_COMPLIANT - should use LL
  unsigned long long x13 = 4294967296UL; // NON_COMPLIANT - should use ULL
  long long x14 = 0x100000000L;          // NON_COMPLIANT - should use LL
  long long x15 = 040000000000L;         // NON_COMPLIANT - should use LL
  long long x16 = 9223372036854775807L;  // NON_COMPLIANT - should use LL
}

void f6() {
  // With digit separators
  long long y1 = 2'147'483'647L;  // COMPLIANT - fits in long
  long long y2 = 2'147'483'648L;  // NON_COMPLIANT - requires long long
  long long y3 = 2'147'483'648LL; // COMPLIANT - correct suffix
  long long y4 =
      9'223'372'036'854'775'807L; // NON_COMPLIANT - LONG_LONG_MAX with single L
  long long y5 =
      9'223'372'036'854'775'807LL; // COMPLIANT - LONG_LONG_MAX with LL

  // Test auto type deduction
  auto a1 = 123L;         // COMPLIANT - deduces to long
  auto a2 = 2147483648L;  // NON_COMPLIANT - single L for long long value
  auto a3 = 2147483648LL; // COMPLIANT - correct suffix
  auto a4 = 0x80000000L;  // COMPLIANT - deduces to unsigned long
  auto a5 = 0x100000000L; // NON_COMPLIANT - deduces to long long with single L
  auto a6 = 9223372036854775807L; // NON_COMPLIANT - LONG_LONG_MAX with single L
  auto a7 = 9223372036854775807LL; // COMPLIANT - LONG_LONG_MAX with LL
}