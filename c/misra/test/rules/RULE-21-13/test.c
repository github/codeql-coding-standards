#include <stdio.h>
#include <ctype.h>

void sample() {
  unsigned char c1 = 'c';
  int r1 = isalnum(c1); // compliant
  unsigned char c2 = EOF;
  int r2 = isalnum(c2); // compliant
}

int main() { return 0; }
