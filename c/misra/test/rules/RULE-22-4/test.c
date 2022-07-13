#include <stdio.h>
void f0() {
  FILE *fp = fopen("file", "r+");
  fprintf(fp, "text"); // COMPLIANT
  fclose(fp);
}

void f1() {
  FILE *fp = fopen("file", "r");
  fprintf(fp, "text"); // NON_COMPLIANT
  fclose(fp);
}

void f2help(FILE *fp) {
  fprintf(fp, "text"); // NON_COMPLIANT
}
void f2() {
  FILE *fp = fopen("file", "r");
  f2help(fp);
  fclose(fp);
}
