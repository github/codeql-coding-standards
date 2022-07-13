#include <stdio.h>

void fn(void) {
  FILE *fp;
  FILE *p;

  fp = fopen("tmp", "w");
  if (fp == NULL) {
    error_action();
  }
  fclose(fp);

  fprintf(fp, "?"); /* Non-compliant */
  p = fp;           /* Non-compliant */
}