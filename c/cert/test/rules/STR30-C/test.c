#include <stdlib.h>
#include <string.h>

// explicit string literals
void f1_explicit() {
  char *a = "codeql";
  a[0] = 'a'; // NON_COMPLIANT
}

void f2_explicit() {
  char a[] = "codeql";
  a[0] = 'a'; // COMPLIANT
}

void f3_explicit() {
  char a[7] = "codeql";
  a[0] = 'a'; // COMPLIANT
}

void f4_explicit() {
  char *a = "codeql";
  if (a[0] == 'a') { // COMPLIANT
    ;
  }
}

// implicit string literals
void f1_implicit() {
  char *a = strchr("codeql", 'c');
  a[0] = 'a'; // NON_COMPLIANT
}

void f2_implicit() {
  char *a = strchr("codeql", 'c');
  char *b = strchr(a, 'c');
  b[0] = 'a'; // NON_COMPLIANT - implicitly literal
}

void f3_implicit() {
  char a_base[7];
  char *a = strchr(a_base, 'c');
  char *b = strchr(a, 'c');
  b[0] = 'a'; // COMPLIANT -- not implicitly literal
}

void f4_implicit() {
  char *a = strchr("codeql", 'c');
  if (a[0] == 'a') { // COMPLIANT
    ;
  }
}

void f5_implicit() {
  char *a_base = "codeql";
  char *a = strchr(a_base, 'c');
  char *b = strchr(a, 'c');

  b[0] = 'a'; // NON_COMPLIANT - implicitly literal
}

void f7_implicit(const char *a) {
  char *b;
  b = strrchr(a, 'c');
  if (b) {
    *b = '\0'; // NON_COMPLIANT
  }
}

// local scope
void f5_local(const char *aa) {

  // allowed cases
  {
    char a[] = "codeql";
    mkstemp(a);           // COMPLIANT
    memset(a, '0', 100);  // COMPLIANT
    memcpy(a, "0", 100);  // COMPLIANT
    memmove(a, "0", 100); // COMPLIANT
    strcat(a, "0");       // COMPLIANT
    strncat(a, "0", 100); // COMPLIANT
    strcpy(a, "0");       // COMPLIANT
    strncpy(a, "0", 100); // COMPLIANT
  }

  // explicit 1
  {
    mkstemp("codeql");           // NON_COMPLIANT
    memset("codeql", '0', 100);  // NON_COMPLIANT
    memcpy("codeql", "0", 100);  // NON_COMPLIANT
    memmove("codeql", "0", 100); // NON_COMPLIANT
    strcat("codeql", "0");       // NON_COMPLIANT
    strncat("codeql", "0", 100); // NON_COMPLIANT
    strcpy("codeql", "0");       // NON_COMPLIANT
    strncpy("codeql", "0", 100); // NON_COMPLIANT
  }

  // explicit 2
  {
    char *a = "codeql";
    mkstemp(a);           // NON_COMPLIANT
    memset(a, '0', 100);  // NON_COMPLIANT
    memcpy(a, "0", 100);  // NON_COMPLIANT
    memmove(a, "0", 100); // NON_COMPLIANT
    strcat(a, "0");       // NON_COMPLIANT
    strncat(a, "0", 100); // NON_COMPLIANT
    strcpy(a, "0");       // NON_COMPLIANT
    strncpy(a, "0", 100); // NON_COMPLIANT
  }

  {
    // implicit
    char *a = strchr("codeql", 'c');
    mkstemp(a);           // NON_COMPLIANT
    memset(a, '0', 100);  // NON_COMPLIANT
    memcpy(a, "0", 100);  // NON_COMPLIANT
    memmove(a, "0", 100); // NON_COMPLIANT
    strcat(a, "0");       // NON_COMPLIANT
    strncat(a, "0", 100); // NON_COMPLIANT
    strcpy(a, "0");       // NON_COMPLIANT
    strncpy(a, "0", 100); // NON_COMPLIANT
  }

  {
    // implicit
    mkstemp(aa);           // NON_COMPLIANT
    memset(aa, '0', 100);  // NON_COMPLIANT
    memcpy(aa, "0", 100);  // NON_COMPLIANT
    memmove(aa, "0", 100); // NON_COMPLIANT
    strcat(aa, "0");       // NON_COMPLIANT
    strncat(aa, "0", 100); // NON_COMPLIANT
    strcpy(aa, "0");       // NON_COMPLIANT
    strncpy(aa, "0", 100); // NON_COMPLIANT
  }
}
// flow scope
void f5_flow(char *a) {
  mkstemp(a);           // NON_COMPLIANT
  memset(a, '0', 100);  // NON_COMPLIANT
  memcpy(a, "0", 100);  // NON_COMPLIANT
  memmove(a, "0", 100); // NON_COMPLIANT
  strcat(a, "0");       // NON_COMPLIANT
  strncat(a, "0", 100); // NON_COMPLIANT
  strcpy(a, "0");       // NON_COMPLIANT
  strncpy(a, "0", 100); // NON_COMPLIANT
}

void f5_explicit() {
  char *a = "codeql";
  f5_flow(a);
  f5_flow("codeql");
}

void f6_flow(char *a) {
  mkstemp(a);           // NON_COMPLIANT
  memset(a, '0', 100);  // NON_COMPLIANT
  memcpy(a, "0", 100);  // NON_COMPLIANT
  memmove(a, "0", 100); // NON_COMPLIANT
  strcat(a, "0");       // NON_COMPLIANT
  strncat(a, "0", 100); // NON_COMPLIANT
  strcpy(a, "0");       // NON_COMPLIANT
  strncpy(a, "0", 100); // NON_COMPLIANT
}

void f6_implicit() {
  char *a = strchr("codeql", 'c');
  f6_flow(a);
  f6_flow("codeql");
}

void f7_flow(char *a) {
  mkstemp(a);           // COMPLIANT
  memset(a, '0', 100);  // COMPLIANT
  memcpy(a, "0", 100);  // COMPLIANT
  memmove(a, "0", 100); // COMPLIANT
  strcat(a, "0");       // COMPLIANT
  strncat(a, "0", 100); // COMPLIANT
  strcpy(a, "0");       // COMPLIANT
  strncpy(a, "0", 100); // COMPLIANT
}

void f7_ok() {
  char a[10] = "codeql";
  f7_flow(a);
}