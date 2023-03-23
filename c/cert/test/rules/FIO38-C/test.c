#include <stdio.h>
// Workaround for the Musl implementing FILE as an incomplete type.
#if !defined(__DEFINED_struct__IO_FILE)
struct _IO_FILE {
  char __x;
};
#define __DEFINED_struct__IO_FILE
#endif

int f1(void) {
  FILE my_stdout = *stdout; // NON_COMPLIANT
  return fputs("Hello, World!\n", &my_stdout);
}

int f2(void) {
  FILE *my_stdout;
  my_stdout = stdout;           // COMPLIANT
  FILE my_stdout2 = *my_stdout; // NON_COMPLIANT
  return fputs("Hello, World!\n", my_stdout);
}

int f3(void) {
  FILE my_stdout;
  my_stdout = *stdout; // NON_COMPLIANT
  return fputs("Hello, World!\n", &my_stdout);
}

int f4(void) {
  FILE *my_stdout;
  my_stdout = fopen("file.txt", "w"); // COMPLIANT
  return fputs("Hello, World!\n", my_stdout);
}

int f5helper(FILE my_stdout) { return fputs("Hello, World!\n", &my_stdout); }
int f5(void) {
  FILE *my_stdout = fopen("file.txt", "w"); // COMPLIANT
  return f5helper(*my_stdout);              // NON_COMPLIANT
}

int f6helper(FILE *my_stdout) { return fputs("Hello, World!\n", my_stdout); }
int f6(void) {
  FILE *my_stdout = fopen("file.txt", "w"); // COMPLIANT
  return f6helper(my_stdout);               // COMPLIANT
}
