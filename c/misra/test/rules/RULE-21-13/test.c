#include <stdio.h>
#include <ctype.h>

void sample() {
  unsigned char c1 = 'c';
  int r1 = isalnum(c1); // COMPLIANT: ASCII 99 is within unsigned char range of [0, 255]
  unsigned char x1 = EOF;
  unsigned char x2 = x1;
  unsigned char c2 = x2;
  int r2 = isdigit(c2); // COMPLIANT: EOF (-1)

  int x3 = 256;
  int x4 = x3;
  int c3 = x4;
  int r3 = islower(c3); // NON_COMPLIANT: is outside unsigned char range of[0, 255]

  unsigned char x5 = EOF;
  unsigned char x6 = x5;
  int c4 = x6 + 10000;
  int r4 = isdigit(c4); // NON_COMPLIANT: is outside unsigned char range of[0, 255]
}

int main() { return 0; }