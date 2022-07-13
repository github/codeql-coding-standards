#include <stdio.h>

void f1() {
  FILE *fp;
  getc(fp = fopen("file.txt", "r")); // NON_COMPLIANT
}

void f2() {
  FILE *fp = fopen("file.txt", "r");
  getc(fp); // COMPLIANT
}

void f3() {
  FILE *fp = NULL;
  putc('a', fp ? fp : (fp = fopen("file.txt", "w"))); // NON_COMPLIANT
}

void f4() {
  FILE *fp = fopen("file.txt", "w");
  putc('a', fp); // COMPLIANT
}