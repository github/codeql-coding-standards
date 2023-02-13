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