#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *gets(char *s); // Needs to be forward declared because it is an inherently
                     // dangerous function

void f1() {
  char a1_nt[7] = "CodeQL"; // COMPLIANT
  char a1_nnt[3] = "Cod";   // NON_COMPLIANT

  char a1[9];
  char a2[10];
  char a9[10];

  strncpy(a2, a1,
          5); // NON_COMPLIANT - not null terminated because n < length(src)
  strncpy(a9, a1, 10); // COMPLIANT - is null terminated; n > length(src)
}

void f2() {
  char a1[10];
  char a2[10];

  snprintf(a1, 10, "CodeQL %d", 3); // COMPLIANT - will be null terminated
  snprintf(a2, 11, "CodeQL %d",
           3); // NON_COMPLIANT - will not be null terminated
}

void f3() {
  char a1[2];
  strncat(a1, "CodeQL", 5); // NON_COMPLIANT - will not be null terminated
}

void f4() {
  char s2[10];
  if (gets(s2) == NULL) { // NON_COMPLIANT
  }
}

void f5() {
  char a1[100];
  char *a2 = getenv("editor");
}

void f6() {
  char a1[100];
  char *a2 = getenv("editor"); // NON_COMPLIANT
  strcpy(a1, a2);
}

int main(int argc, char *argv[]) {
  char *const a1 = argv[0]; // NON_COMPLIANT
  char a2[100];
  strcpy(a2, a1);

  return 0;
}