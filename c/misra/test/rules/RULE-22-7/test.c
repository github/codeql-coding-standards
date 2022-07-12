#include <stdio.h>

void f1a(void) {
  char ch;
  ch = (char)getchar();
  if (EOF != (int)ch) { // NON_COMPLIANT
  }
}

void f1b(void) {
  int ch;
  ch = (char)getchar();
  if (EOF != ch) { // NON_COMPLIANT
  }
}

void f2(void) {
  char ch;
  ch = (char)getchar();
  if (!feof(stdin)) { // COMPLIANT
  }
}

void f3(void) {
  int i_ch;
  i_ch = getchar();
  if (EOF != i_ch) { // COMPLIANT
    char ch;
    ch = (char)i_ch;
  }
}
