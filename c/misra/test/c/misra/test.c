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