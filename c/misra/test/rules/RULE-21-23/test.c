#include <stdint.h>
#include <tgmath.h>

void f1() {
  signed char c = 0;
  unsigned char uc = 0;
  short s = 0;
  unsigned short us = 0;
  int i = 0;
  unsigned int ui = 0;
  long l = 0;
  unsigned long ul = 0;
  float f = 0.0f;
  double d = 0.0;
  long double ld = 0.0;
  uint8_t u8 = 0;
  int8_t i8 = 0;
  uint16_t u16 = 0;
  int16_t i16 = 0;
  uint32_t u32 = 0;
  int32_t i32 = 0;
  uint64_t u64 = 0;
  int64_t i64 = 0;

  /**
   * Test exact types
   */
  atan2(c, c);     // COMPLIANT
  atan2(uc, uc);   // COMPLIANT
  atan2(s, s);     // COMPLIANT
  atan2(us, us);   // COMPLIANT
  atan2(i, i);     // COMPLIANT
  atan2(ui, ui);   // COMPLIANT
  atan2(ui, ui);   // COMPLIANT
  atan2(l, l);     // COMPLIANT
  atan2(ul, ul);   // COMPLIANT
  atan2(f, f);     // COMPLIANT
  atan2(d, d);     // COMPLIANT
  atan2(ld, ld);   // COMPLIANT
  atan2(u8, u8);   // COMPLIANT
  atan2(i8, i8);   // COMPLIANT
  atan2(u16, u16); // COMPLIANT
  atan2(i16, i16); // COMPLIANT
  atan2(u32, u32); // COMPLIANT
  atan2(i32, i32); // COMPLIANT
  atan2(u64, u64); // COMPLIANT
  atan2(i64, i64); // COMPLIANT

  /** Test equivalent types */
  atan2(c, i8);   // COMPLIANT
  atan2(i8, c);   // COMPLIANT
  atan2(uc, u8);  // COMPLIANT
  atan2(u8, uc);  // COMPLIANT
  atan2(s, i16);  // COMPLIANT
  atan2(i16, s);  // COMPLIANT
  atan2(us, u16); // COMPLIANT
  atan2(u16, us); // COMPLIANT
  atan2(i, i32);  // COMPLIANT
  atan2(i32, i);  // COMPLIANT
  atan2(ui, u32); // COMPLIANT
  atan2(u32, ui); // COMPLIANT
  atan2(l, i64);  // COMPLIANT
  atan2(i64, l);  // COMPLIANT
  atan2(ul, u64); // COMPLIANT
  atan2(u64, ul); // COMPLIANT

  /** Types are the same after integer promotion */
  atan2(c, i8);   // COMPLIANT
  atan2(c, u8);   // COMPLIANT
  atan2(c, i16);  // COMPLIANT
  atan2(c, u16);  // COMPLIANT
  atan2(c, i32);  // COMPLIANT
  atan2(uc, i8);  // COMPLIANT
  atan2(uc, u8);  // COMPLIANT
  atan2(uc, i16); // COMPLIANT
  atan2(uc, u16); // COMPLIANT
  atan2(uc, i32); // COMPLIANT
  atan2(s, i8);   // COMPLIANT
  atan2(s, u8);   // COMPLIANT
  atan2(s, i16);  // COMPLIANT
  atan2(s, u16);  // COMPLIANT
  atan2(s, i32);  // COMPLIANT
  atan2(us, i8);  // COMPLIANT
  atan2(us, u8);  // COMPLIANT
  atan2(us, i16); // COMPLIANT
  atan2(us, u16); // COMPLIANT
  atan2(us, i32); // COMPLIANT
  atan2(i, i8);   // COMPLIANT
  atan2(i, u8);   // COMPLIANT
  atan2(i, i16);  // COMPLIANT
  atan2(i, u16);  // COMPLIANT
  atan2(i, i32);  // COMPLIANT

  /** Integer promotion makes a signed int, not an unsigned int */
  atan2(c, ui);    // NON-COMPLIANT
  atan2(c, u32);   // NON-COMPLIANT
  atan2(i8, ui);   // NON-COMPLIANT
  atan2(i8, u32);  // NON-COMPLIANT
  atan2(uc, ui);   // NON-COMPLIANT
  atan2(uc, u32);  // NON-COMPLIANT
  atan2(u8, ui);   // NON-COMPLIANT
  atan2(u8, u32);  // NON-COMPLIANT
  atan2(s, ui);    // NON-COMPLIANT
  atan2(s, u32);   // NON-COMPLIANT
  atan2(i16, ui);  // NON-COMPLIANT
  atan2(i16, u32); // NON-COMPLIANT
  atan2(us, ui);   // NON-COMPLIANT
  atan2(us, u32);  // NON-COMPLIANT
  atan2(u16, ui);  // NON-COMPLIANT
  atan2(u16, u32); // NON-COMPLIANT
  atan2(i, ui);    // NON-COMPLIANT
  atan2(i, u32);   // NON-COMPLIANT
  atan2(i32, ui);  // NON-COMPLIANT
  atan2(i32, u32); // NON-COMPLIANT
  atan2(ui, ui);   // COMPLIANT
  atan2(ui, u32);  // COMPLIANT
  atan2(u32, ui);  // COMPLIANT
  atan2(u32, u32); // COMPLIANT

  /** Integer promotion makes int, not long */
  atan2(c, l);   // NON-COMPLIANT
  atan2(i8, l);  // NON-COMPLIANT
  atan2(uc, l);  // NON-COMPLIANT
  atan2(u8, l);  // NON-COMPLIANT
  atan2(s, l);   // NON-COMPLIANT
  atan2(i16, l); // NON-COMPLIANT
  atan2(us, l);  // NON-COMPLIANT
  atan2(u16, l); // NON-COMPLIANT

  /** Integer vs long */
  atan2(i, l);     // NON-COMPLIANT
  atan2(i32, l);   // NON-COMPLIANT
  atan2(ui, l);    // NON-COMPLIANT
  atan2(u32, l);   // NON-COMPLIANT
  atan2(l, i);     // NON-COMPLIANT
  atan2(l, ui);    // NON-COMPLIANT
  atan2(l, i32);   // NON-COMPLIANT
  atan2(l, u32);   // NON-COMPLIANT
  atan2(i, ul);    // NON-COMPLIANT
  atan2(i32, ul);  // NON-COMPLIANT
  atan2(ui, ul);   // NON-COMPLIANT
  atan2(u32, ul);  // NON-COMPLIANT
  atan2(ul, i);    // NON-COMPLIANT
  atan2(ul, ui);   // NON-COMPLIANT
  atan2(ul, i32);  // NON-COMPLIANT
  atan2(ul, u32);  // NON-COMPLIANT
  atan2(i, i64);   // NON-COMPLIANT
  atan2(i32, i64); // NON-COMPLIANT
  atan2(ui, i64);  // NON-COMPLIANT
  atan2(u32, i64); // NON-COMPLIANT
  atan2(i64, i);   // NON-COMPLIANT
  atan2(i64, ui);  // NON-COMPLIANT
  atan2(i64, i32); // NON-COMPLIANT
  atan2(i64, u32); // NON-COMPLIANT
  atan2(i, u64);   // NON-COMPLIANT
  atan2(i32, u64); // NON-COMPLIANT
  atan2(ui, u64);  // NON-COMPLIANT
  atan2(u32, u64); // NON-COMPLIANT
  atan2(u64, i);   // NON-COMPLIANT
  atan2(u64, ui);  // NON-COMPLIANT
  atan2(u64, i32); // NON-COMPLIANT
  atan2(u64, u32); // NON-COMPLIANT

  /** Signed vs unsigned long, since those don't promote */
  atan2(l, ul);    // NON-COMPLIANT
  atan2(l, u64);   // NON-COMPLIANT
  atan2(i64, ul);  // NON-COMPLIANT
  atan2(i64, u64); // NON-COMPLIANT
  atan2(ul, l);    // NON-COMPLIANT
  atan2(ul, i64);  // NON-COMPLIANT
  atan2(u64, l);   // NON-COMPLIANT
  atan2(u64, i64); // NON-COMPLIANT

  /** Mismatched float sizes */
  atan2(f, d);  // NON-COMPLIANT
  atan2(f, ld); // NON-COMPLIANT
  atan2(d, f);  // NON-COMPLIANT
  atan2(d, ld); // NON-COMPLIANT
  atan2(ld, f); // NON-COMPLIANT
  atan2(ld, d); // NON-COMPLIANT

  /** Float vs int */
  atan2(c, f);    // NON-COMPLIANT
  atan2(c, d);    // NON-COMPLIANT
  atan2(c, ld);   // NON-COMPLIANT
  atan2(i8, f);   // NON-COMPLIANT
  atan2(i8, d);   // NON-COMPLIANT
  atan2(i8, ld);  // NON-COMPLIANT
  atan2(uc, f);   // NON-COMPLIANT
  atan2(uc, d);   // NON-COMPLIANT
  atan2(uc, ld);  // NON-COMPLIANT
  atan2(u8, f);   // NON-COMPLIANT
  atan2(u8, d);   // NON-COMPLIANT
  atan2(u8, ld);  // NON-COMPLIANT
  atan2(s, f);    // NON-COMPLIANT
  atan2(s, d);    // NON-COMPLIANT
  atan2(s, ld);   // NON-COMPLIANT
  atan2(i16, f);  // NON-COMPLIANT
  atan2(i16, d);  // NON-COMPLIANT
  atan2(i16, ld); // NON-COMPLIANT
  atan2(us, f);   // NON-COMPLIANT
  atan2(us, d);   // NON-COMPLIANT
  atan2(us, ld);  // NON-COMPLIANT
  atan2(u16, f);  // NON-COMPLIANT
  atan2(u16, d);  // NON-COMPLIANT
  atan2(u16, ld); // NON-COMPLIANT
  atan2(i, f);    // NON-COMPLIANT
  atan2(i, d);    // NON-COMPLIANT
  atan2(i, ld);   // NON-COMPLIANT
  atan2(i32, f);  // NON-COMPLIANT
  atan2(i32, d);  // NON-COMPLIANT
  atan2(i32, ld); // NON-COMPLIANT
  atan2(ui, f);   // NON-COMPLIANT
  atan2(ui, d);   // NON-COMPLIANT
  atan2(ui, ld);  // NON-COMPLIANT
  atan2(u32, f);  // NON-COMPLIANT
  atan2(u32, d);  // NON-COMPLIANT
  atan2(u32, ld); // NON-COMPLIANT
  atan2(l, f);    // NON-COMPLIANT
  atan2(l, d);    // NON-COMPLIANT
  atan2(l, ld);   // NON-COMPLIANT
  atan2(i64, f);  // NON-COMPLIANT
  atan2(i64, d);  // NON-COMPLIANT
  atan2(i64, ld); // NON-COMPLIANT
  atan2(ul, f);   // NON-COMPLIANT
  atan2(ul, d);   // NON-COMPLIANT
  atan2(ul, ld);  // NON-COMPLIANT
  atan2(u64, f);  // NON-COMPLIANT
  atan2(u64, d);  // NON-COMPLIANT
  atan2(u64, ld); // NON-COMPLIANT

  /** Casts and conversions */
  atan2((float)i, f);        // COMPLIANT
  atan2(i, (int)f);          // COMPLIANT
  atan2((i), f);             // NON-COMPLIANT
  atan2(((float)i), f);      // COMPLIANT
  atan2((float)((int)l), f); // COMPLIANT

  /** Other functions */
  copysign(f, f);   // COMPLIANT
  copysign(i, i);   // COMPLIANT
  copysign(i, f);   // NON-COMPLIANT
  fdim(f, f);       // COMPLIANT
  fdim(i, i);       // COMPLIANT
  fdim(i, f);       // NON-COMPLIANT
  fma(f, f, f);     // COMPLIANT
  fma(i, i, i);     // COMPLIANT
  fma(f, i, i);     // NON-COMPLIANT
  fma(i, f, i);     // NON-COMPLIANT
  fma(i, i, f);     // NON-COMPLIANT
  fmax(f, f);       // COMPLIANT
  fmax(i, i);       // COMPLIANT
  fmax(i, f);       // NON-COMPLIANT
  fmin(f, f);       // COMPLIANT
  fmin(i, i);       // COMPLIANT
  fmin(i, f);       // NON-COMPLIANT
  fmod(f, f);       // COMPLIANT
  fmod(i, i);       // COMPLIANT
  fmod(i, f);       // NON-COMPLIANT
  hypot(f, f);      // COMPLIANT
  hypot(i, i);      // COMPLIANT
  hypot(i, f);      // NON-COMPLIANT
  ldexp(f, f);      // COMPLIANT
  ldexp(i, i);      // COMPLIANT
  ldexp(i, f);      // NON-COMPLIANT
  nextafter(f, f);  // COMPLIANT
  nextafter(i, i);  // COMPLIANT
  nextafter(i, f);  // NON-COMPLIANT
  nexttoward(f, f); // COMPLIANT
  nexttoward(i, i); // COMPLIANT
  nexttoward(i, f); // NON-COMPLIANT
  remainder(f, f);  // COMPLIANT
  remainder(i, i);  // COMPLIANT
  remainder(i, f);  // NON-COMPLIANT
  remquo(f, f, 0);  // COMPLIANT
  remquo(i, i, 0);  // COMPLIANT
  remquo(i, f, 0);  // NON-COMPLIANT
  scalbln(f, f);    // COMPLIANT
  scalbln(i, i);    // COMPLIANT
  scalbln(i, f);    // NON-COMPLIANT
  scalbn(f, f);     // COMPLIANT
  scalbn(i, i);     // COMPLIANT
  scalbn(i, f);     // NON-COMPLIANT

  // `frexp` has two parameters, but the second is an output parameter, and
  // should not be covered by this rule.
  frexp(f, 0); // COMPLIANT
}