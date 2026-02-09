#include <stdbool.h>

void testConditional() {
  unsigned int u = 1;
  unsigned short us = 1;
  signed int s = 1;
  signed short ss = 1;
  _Bool b = true;

  b ? u : u;  // unsigned int
  b ? s : s;  // signed int
  b ? s : ss; // signed int
  b ? ss : s; // signed int
  b ? us : u; // unsigned int

  b ? s : u; // unsigned int
}

void testCategoriesForComplexTypes() {
  typedef float float32_t;
  typedef const float cfloat32_t;
  const float f;
  const float32_t f32;
  cfloat32_t cf32;

  f;    // Should be essentially Floating type
  f32;  // Should be essentially Floating type
  cf32; // Should be essentially Floating type
}

void testConstants() {
  1;   // Essentially signed char
  1U;  // Essentially unsigned char
  1UL; // Essentially unsigned long
}

void testUnary() {
  _Bool b = true;
  unsigned int u = 1;
  unsigned short us = 1;
  signed int s = 1;
  signed short ss = 1;

  !b;  // Should be boolean
  !u;  // Should be boolean
  !us; // Should be boolean
  !s;  // Should be boolean
  !ss; // Should be boolean

  ~b;  // Should be essentially signed
  ~u;  // Should be essentially unsigned
  ~us; // Should be essentially unsigned
  ~s;  // Should be essentially signed
  ~ss; // Should be essentially signed
}

enum { EC1 };
enum E1 { EC2 };
typedef enum { EC3 } E2;

enum { EC4 } g;

enum { EC5 } test() { return EC5; }

struct S1 {
  enum { EC6 } m;
};

void testEnums() {
  EC1; // Should be essentially signed
  EC2; // Should be essentially enum
  EC3; // Should be essentially enum
  EC4; // Should be essentially enum
  EC5; // Should be essentially enum
  EC6; // Should be essentially enum
}

void testControlChar() {
  'a';  // Essentially char
  '\n'; // Essentially char
  '\0'; // Essentially char
}

#include <stdint.h>
// clang-format off
void testBitwise() { // Clang format disabled to avoid confusion with variable declarations
  uint8_t u8 = 0;
  uint16_t u16 = 0;
  uint32_t u32 = 0;
  int8_t s8 = 0;
  int16_t s16 = 0;
  int32_t s32 = 0;

  u8 & u8;   // Essentially unsigned, char
  u16 & u8;  // Essentially unsigned, short
  u8 & u16;  // Essentially unsigned, short
  u32 & u8;  // Essentially unsigned, int
  u8 & u32;  // Essentially unsigned, int
  u32 & u16; // Essentially unsigned, int
  u16 & u32; // Essentially unsigned, int

  u8 | u8;   // Essentially unsigned, char
  u16 | u8;  // Essentially unsigned, short
  u8 | u16;  // Essentially unsigned, short
  u32 | u8;  // Essentially unsigned, int
  u8 | u32;  // Essentially unsigned, int
  u32 | u16; // Essentially unsigned, int
  u16 | u32; // Essentially unsigned, int

  u8 ^ u8;   // Essentially unsigned, char
  u16 ^ u8;  // Essentially unsigned, short
  u8 ^ u16;  // Essentially unsigned, short
  u32 ^ u8;  // Essentially unsigned, int
  u8 ^ u32;  // Essentially unsigned, int
  u32 ^ u16; // Essentially unsigned, int
  u16 ^ u32; // Essentially unsigned, int

  s8 & s8;   // Essentially signed, char
  s16 & s8;  // Essentially signed, short
  s8 & s16;  // Essentially signed, short
  s32 & s8;  // Essentially signed, int
  s8 & s32;  // Essentially signed, int
  s32 & s16; // Essentially signed, int
  s16 & s32; // Essentially signed, int

  s8 | s8;   // Essentially signed, char
  s16 | s8;  // Essentially signed, short
  s8 | s16;  // Essentially signed, short
  s32 | s8;  // Essentially signed, int
  s8 | s32;  // Essentially signed, int
  s32 | s16; // Essentially signed, int
  s16 | s32; // Essentially signed, int

  s8 ^ s8;   // Essentially signed, char
  s16 ^ s8;  // Essentially signed, short
  s8 ^ s16;  // Essentially signed, short
  s32 ^ s8;  // Essentially signed, int
  s8 ^ s32;  // Essentially signed, int
  s32 ^ s16; // Essentially signed, int
  s16 ^ s32; // Essentially signed, int

  u32 & s32; // Essentially unsigned, int
  s32 & u32; // Essentially unsigned, int
  u8 & s32;  // Essentially signed, int
  s32 & u8;  // Essentially signed, int
  u8 & s8;   // Essentially signed, int
  s8 & u8;   // Essentially signed, int

  u32 | s32; // Essentially signed, int
  s32 | u32; // Essentially signed, int
  u8 | s32;  // Essentially signed, int
  s32 | u8;  // Essentially signed, int
  u8 | s8;   // Essentially signed, int
  s8 | u8;   // Essentially signed, int

  u32 ^ s32; // Essentially signed, int
  s32 ^ u32; // Essentially signed, int
  u8 ^ s32;  // Essentially signed, int
  s32 ^ u8;  // Essentially signed, int
  u8 ^ s8;   // Essentially signed, int
  s8 ^ u8;   // Essentially signed, int
}
// clang-format on
void testShifts() {
  int32_t s32 = 1;

  // Left hand is unsigned and both are constants, so UTLR
  // In these cases the UTLR is the same as the essential type of
  // the left operand
  1U << 1;           // Essentially unsigned char
  256U << 1;         // Essentially unsigned short
  65536U << 1;       // Essentially unsigned int
  2U >> 1;           // Essentially unsigned char
  32768U >> 1;       // Essentially unsigned short - 2^15 >> 1 = 2^14
  2147483648U >> 1;  // Essentially unsigned int - 2^31 >> 1 = 2^30
  4294967295LU << 1; // Essentially unsigned long

  // Left hand is unsigned and both are constants, so UTLR
  // In these cases the UTLR is not the same as the essential type of
  // the left operand
  256U >> 1;        // Essentially unsigned char
  65536U >> 1;      // Essentially unsigned short
  4294967296U >> 1; // Essentially unsigned int
  255U << 1;        // Essentially unsigned short
  65535U << 1;      // Essentially unsigned int

  // Left hand is unsigned, but left isn't a constant, so essential type of left
  // operand
  255U >> s32;        // Essentially unsigned char
  65535U >> s32;      // Essentially unsigned short
  4294967295U >> s32; // Essentially unsigned int
  255U << s32;        // Essentially unsigned char
  65535U << s32;      // Essentially unsigned short
  4294967295U << s32; // Essentially unsigned int

  // Left hand operand signed int, so result is standard type
  257 >> 1;        // Essentially signed int
  65537 >> 1;      // Essentially signed int
  4294967297 >> 1; // Essentially signed long
}