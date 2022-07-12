#include <stdio.h>

int f1(void) {
  fclose(stdout);

  printf(""); // NON_COMPLIANT
  puts("");   // NON_COMPLIANT
  perror(""); // COMPLIANT
  return 0;
}

int f2(void) {
  fclose(stderr);

  puts("");          // COMPLIANT
  fputs("", stderr); // NON_COMPLIANT
  perror("");        // NON_COMPLIANT
  return 0;
}

int f3(void) {
  fclose(stdin);

  getc(stdin); // NON_COMPLIANT
  getchar();   // NON_COMPLIANT
  return 0;
}

int f4(void) {
  FILE *f = fopen("myfile", "rw");
  fclose(f);

  printf("");        // COMPLIANT
  fputs("write", f); // NON_COMPLIANT
  return getc(f);    // NON_COMPLIANT
}

int f5(void) {
  FILE *f = fopen("myfile", "rw");

  int c;
  while ((c = getchar())) { // COMPLIANT
    if (c == EOF) {
      fclose(f);
      break;
    }
  }

  return 0;
}

int f6(void) {
  FILE *f = fopen("myfile1", "rw");
  FILE *g = fopen("myfile2", "rw");
  fclose(f);
  f = g; // COMPLIANT

  fputs("write", f); // COMPLIANT
  return 0;
}

int f7(void) {
  FILE *fp;
  void *p;
  fp = fopen("myfile", "w");
  if (fp == NULL) {
    return -1;
  }
  fclose(fp);
  fprintf(fp, ""); // NON_COMPLIANT
  p = fp;          // NON_COMPLIANT
  return 0;
}

void finter_helper(FILE *f) {
  fputs("write", f); // NON_COMPLIANT
}
int finter(void) {
  FILE *f = fopen("myfile", "rw");
  fclose(f);
  finter_helper(f);
}

FILE *g_f;
void fglobal_helper() {
  fputs("write", g_f); // NON_COMPLIANT[FALSE_NEGATIVE]
}
int fglobal(void) {
  g_f = fopen("myfile", "rw");
  fclose(g_f);
  fglobal_helper();
}