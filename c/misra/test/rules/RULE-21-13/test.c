#include <ctype.h>
#include <stdio.h>

void sample() {
  unsigned char c1 = 'c';
  int r1 = isalnum(
      c1); // COMPLIANT: ASCII 99 is within unsigned char range of [0, 255]
  int r2 = isdigit(EOF); // COMPLIANT: EOF (-1)

  int x3 = 256;
  int x4 = x3;
  int c3 = x4;
  int r3 =
      islower(c3); // NON_COMPLIANT: is outside unsigned char range of [0, 255]

  unsigned char x5 = EOF;
  unsigned char x6 = x5;
  int c4 = x6 + 10000;
  int r4 =
      isdigit(c4); // NON_COMPLIANT: is outside unsigned char range of [0, 255]

  int c5 = getchar();
  int r5 = isdigit(c5); // COMPLIANT[FALSE_POSITIVE]: library functions like
                        // getchar needs to be modelled

  unsigned char x7 = 1;
  char c6;
  if (x7 == 1) {
    c6 = EOF;
  } else {
    c6 = 'c';
  }
  int r6 =
      isdigit(c6); // COMPLIANT: either control branch make this call compliant.
}

int main() { return 0; }