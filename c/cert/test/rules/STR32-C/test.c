#include <stdio.h>
#include <string.h>
#include <wchar.h>

void f1() {
  char a1_nt[7] = "CodeQL"; // is null terminated
  char a1_nnt[3] = "Cod";   // is NOT null termianted

  char a1[9];
  char a2[10];
  char a9[10];

  strncpy(a2, a1, 5);  // not null terminated because n < length(src)
  strncpy(a9, a1, 10); // is null terminated; n > length(src)

  printf("%s", a1_nt); // COMPLIANT
  printf(a1_nt);       // COMPLIANT

  printf("%s", a1_nnt); // NON_COMPLIANT
  printf(a1_nnt);       // NON_COMPLIANT

  printf("%s", a2); // NON_COMPLIANT
  printf(a2);       // NON_COMPLIANT
  strlen(a2);       // NON_COMPLIANT

  printf(a9); // COMPLIANT
  printf(a9); // COMPLIANT

  wchar_t wa1_nt[7] = L"CodeQL"; // is null terminated
  wchar_t wa1_nnt[3] = L"Cod";   // is NOT null termianted

  wprintf(wa1_nt);  // COMPLIANT
  wprintf(wa1_nnt); // NON_COMPLIANT
}

void f2() {
  char a1[10];
  char a2[10];

  snprintf(a1, 10, "CodeQL %d", 3); // will be null terminated
  snprintf(a2, 11, "CodeQL %d", 3); // will not be null terminated

  printf("%s", a1); // COMPLIANT
  printf(a1);       // COMPLIANT

  printf("%s", a2); // NON_COMPLIANT
  printf(a2);       // NON_COMPLIANT
}

void f3() {
  char a1[2];

  strncat(a1, "CodeQL", 5); // will not be null terminated

  printf(a1);       // NON_COMPLIANT
  printf("%s", a1); // NON_COMPLIANT
}

void f4() {
  char a1_nnt[3] = "Cod"; // is NOT null termianted

  printf("%s", a1_nnt); // NON_COMPLIANT
  printf(a1_nnt);       // NON_COMPLIANT

  a1_nnt[2] = '\0';

  printf("%s", a1_nnt); // COMPLIANT
  printf(a1_nnt);       // COMPLIANT
}

f5() {
  char a1_nnt[3] = "Cod"; // is NOT null termianted
  char a2[10] = "CodeQL";

  printf("%s", a1_nnt); // NON_COMPLIANT
  printf(a1_nnt);       // NON_COMPLIANT

  a1_nnt[2] = '\0';

  printf("%s", a1_nnt); // COMPLIANT
  printf(a1_nnt);       // COMPLIANT

  strncpy(a1_nnt, a2, 1); // not null terminated because n < length(src)

  printf("%s", a1_nnt); // NON_COMPLIANT
  printf(a1_nnt);       // NON_COMPLIANT
}