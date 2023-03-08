#include <stdio.h>
#include <string.h>

void f1(void) {
  FILE *fw = fopen("tmp1", "r+");
  FILE *fr = fopen("tmp1", "r"); // NON_COMPLIANT
}

void f2(void) {
  FILE *fw = fopen("tmp2", "r+");
  fclose(fw);
  FILE *fr = fopen("tmp2", "r"); // COMPLIANT
}

void f3(void) {
  FILE *fr = fopen("tmp3", "r");
  FILE *fw = fopen("tmp3", "r+"); // NON_COMPLIANT
  fclose(fw);
}

void f4(void) {
  FILE *fw = fopen("tmp4", "r");
  FILE *fr = fopen("tmp4", "r"); // COMPLIANT
}

void f5(void) {
  FILE *fr = fopen("tmp5a", "r");
  FILE *fw = fopen("tmp5b", "r+"); // COMPLIANT
}

void f6(void) {
  FILE *fw = fopen("tmp6", "w");
  FILE *fr = fopen("tmp6", "r"); // NON_COMPLIANT
}

void f7(void) {
  FILE *fw = fopen("tmp1", "r"); // COMPLIANT
}

void f8(void) {
  char file[] = "tmp8";
  FILE *fw = fopen(file, "r+");
  FILE *fr = fopen(file, "r"); // NON_COMPLIANT
}

void f9(void) {
  char name[50] = "tmp9";
  char ext[] = "txt";
  char *file = strcat(name, ext);
  FILE *fw = fopen(file, "r+");
  FILE *fr = fopen(strcat(name, ext), "r"); // NON_COMPLIANT[FALSE_NEGATIVE]
}

void f10(void) {
  char name[50] = "tmp10";
  char ext[] = "txt";
  strcat(name, ext);
  FILE *fw = fopen(name, "r+");
  FILE *fr = fopen(name, "r"); // NON_COMPLIANT
}
